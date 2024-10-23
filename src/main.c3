module logic_gate_simulation;

import raylib5;
import raygui;

import logic_gate_simulation::component;

import std::io;
import std::math;

import std::collections::list;
import std::collections::map;
import std::collections::tuple;

import std::thread;
import std::time;

def WorldMap = HashMap(<Id, Component>);
Id id_counter = 0;

const Point SCREEN_SIZE = {800, 600};

const MAX_TPS = 200;
const Duration MIN_DELAY_US = (usz)1e6 / MAX_TPS;

usz tps_avg @private;
const TPS_SAMPLES @private = 10;

WorldMap world @private;
EventQueue event_queue @private;
usz event_num @private;

Mutex world_mutex;
Mutex event_queue_mutex;

bool do_spam;
bool show_uncapped_tps;
bool uncap_tps;

fn int main(String[] args)
{
  rl::initWindow(...SCREEN_SIZE, "Game Window");
  defer rl::closeWindow();
  rl::setTargetFPS(60);

  bool show_full_ui = false;
  bool removing = false;
  Tuple(<Id, usz>) new_connection_from = {};
  Id moving_id = 0;
  bool dragging = false;
  Point old_pos;
  Point moving_offset;

  /*
   *
   * Main game loop
   *
  */
  Camera2D camera;
  camera.target = {0, 0};
  camera.offset = {0, 0};
  camera.rotation = 0;
  camera.zoom = 1;

  world.new_init();
  defer world.free();

  event_queue.new_init();
  defer event_queue.free();

  world_mutex.init()!!;
  defer world_mutex.destroy()!!;
  event_queue_mutex.init()!!;
  defer event_queue_mutex.destroy()!!;

  bool running = true;
  Thread tick_thread;
  if (catch error = tick_thread.create(&component_thread, &running))
  {
    io::printfn("Thread creation error: %s", error);
  }
  defer
  {
    running = false;
    if (catch error = tick_thread.join()) io::printfn("Thread join error: %s", error);
  }

  world_mutex.lock()!!;
  world.set(++id_counter, lever::new(&event_queue, {100, 100}, id_counter));
  world_mutex.unlock()!!;

  Component new_component;

  // TODO: fix strange issues when connecting components
  while (!rl::windowShouldClose())
  {
    Vector2 mouse_pos = rl::getMousePosition();
    defer old_pos = {(int)mouse_pos.x, (int)mouse_pos.y};
    {
      Vector2 mouse_scroll = rl::getMouseWheelMoveV();
      camera.zoom += mouse_scroll.y / 10;
    }
    if (rl::isMouseButtonReleased(MouseButton.MIDDLE))
    {
      camera.zoom = 1;
    }
    if (rl::isMouseButtonPressed(MouseButton.LEFT))
    {
      if (try Tuple(<Id, Point>) component = get_component_id_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world, &camera))
      {
        moving_id = component.first;
        moving_offset = world.get(component.first)!!.get_pos() - (Point)(float[<2>]{(int)mouse_pos.x, (int)mouse_pos.y} / camera.zoom);
        dragging = false;
      }
      else
      {
        dragging = true;
      }
    }
    else if ((moving_id != 0 || dragging) && rl::isMouseButtonDown(MouseButton.LEFT) && ((int)mouse_pos.x != old_pos.x || (int)mouse_pos.y != old_pos.y))
    {
      if (!dragging)
      {
        world.get_ref(moving_id)!!.set_pos({(int)(mouse_pos.x / camera.zoom), (int)(mouse_pos.y / camera.zoom)} + moving_offset);
      }
      else
      {
        camera.offset = {camera.offset.x + mouse_pos.x - old_pos.x, camera.offset.y + mouse_pos.y - old_pos.y};
      }
    }
    else if (rl::isMouseButtonReleased(MouseButton.LEFT))
    {
      if (moving_id != 0)
      {
        moving_id = 0;
      }
      if (((int)mouse_pos.x != old_pos.x || (int)mouse_pos.y != old_pos.y))
      {}
      else if (new_component.type != NONE)
      {
        world_mutex.lock()!!;
        world.set(id_counter, new_component);
        world_mutex.unlock()!!;
        new_component.type = NONE;
      }
      else if (removing)
      {
        new_connection_from = {};
        if (try Tuple(<Id, Point>) component = get_component_id_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world, &camera))
        {
          event_queue.push(component::removed_event(component.first));
        }
        else if(try Tuple(<Id, usz>) component = get_component_input_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world, &camera))
        {
          Input* in = &world.get_ref(component.first)!!.get_inputs()[component.second];
          if (in.out != null)
          {
            in.out.disconnect_input();
          }
        }
        else if(try Tuple(<Id, usz>) component = get_component_output_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world, &camera))
        {
          Output* out = &world.get_ref(component.first)!!.get_outputs()[component.second];
          if (out.in != null)
          {
            out.disconnect_input();
          }
        }
        removing = false;
      }
      else if (new_connection_from.first != 0)
      {
        if(try Tuple(<Id, usz>) component = get_component_input_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world, &camera))
        {
          world_mutex.lock()!!;
          Output* from = &world.get_ref(new_connection_from.first)!!.get_outputs()[new_connection_from.second];
          Input* to = &world.get_ref(component.first)!!.get_inputs()[component.second];

          if (from.in != null)
          {
            from.disconnect_input();
          }
          if (to.out != null)
          {
            to.out.disconnect_input();
          }
          from.connect_input(to);
          event_queue.push(component::power_change_event(to.parent_id));
          world_mutex.unlock()!!;
        }
        new_connection_from = {};
      }
      else if (try Tuple(<Id, usz>) component = get_component_output_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world, &camera))
      {
        new_connection_from = component;
      }
      else if (try Tuple(<Id, Point>) component = get_component_id_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world, &camera))
      {
        event_queue.push(component::pressed_event(component.first, component.second));
      }
    }
    /*
     *
     * Clear the background
     *
    */
    rl::beginDrawing();
    rl::clearBackground(rl::RAYWHITE);

    /*
     *
     * Paint main things
     *
    */
    // Mode2D makes drawn things follow the camera
    rl::beginMode2D(camera);
    foreach (component : world.value_tlist())
    {
      foreach (output : component.get_outputs())
      {
        if (output.in != null)
        {
          draw_between_points(component.get_pos() + (Point)output.position, world.get(output.in.parent_id)!!.get_pos() + (Point)output.in.position);
        }
      }
      component.draw();
      foreach (input : component.get_inputs())
      {
        rl::drawRectangle(...(component.get_pos() + (Point)input.position - 1), ...component::INPUT_SIZE + 2, rl::BLACK);
        rl::drawRectangle(...(component.get_pos() + (Point)input.position), ...component::INPUT_SIZE, rl::GREEN);
      }
      foreach (output : component.get_outputs())
      {
        rl::drawRectangle(...(component.get_pos() + (Point)output.position - 1), ...component::OUTPUT_SIZE + 2, rl::BLACK);
        rl::drawRectangle(...(component.get_pos() + (Point)output.position), ...component::OUTPUT_SIZE, rl::YELLOW);
      }
    }
    if (new_component.type != NONE)
    {
      new_component.set_pos({(int)((mouse_pos.x - camera.offset.x) / camera.zoom), (int)((mouse_pos.y - camera.offset.y) / camera.zoom)});
      new_component.draw();
    }
    if (new_connection_from.first != 0)
    {
      draw_between_points(world.get_ref(new_connection_from.first)!!.get_pos() + (Point)world.get_ref(new_connection_from.first)!!.get_outputs()[new_connection_from.second].position, {(int)((mouse_pos.x - camera.offset.x) / camera.zoom), (int)((mouse_pos.y - camera.offset.y) / camera.zoom)});
    }

    rl::endMode2D();
    /*
     *
     * Paint UI
     *
    */

    rg::guiToggle({50, 20, 50, 20}, "NEW", &show_full_ui);

    if (show_full_ui)
    {
      @new_button(0, "lever", show_full_ui, event_queue, new_component);
      @new_button(1, "bulb", show_full_ui, event_queue, new_component);
      @new_button(2, "and", show_full_ui, event_queue, new_component);
      @new_button(3, "or", show_full_ui, event_queue, new_component);
      @new_button(4, "not", show_full_ui, event_queue, new_component);
      @new_button(5, "nor", show_full_ui, event_queue, new_component);
      @new_button(6, "xor", show_full_ui, event_queue, new_component);
      @new_button(7, "xnor", show_full_ui, event_queue, new_component);
      @new_button(8, "splitter", show_full_ui, event_queue, new_component);
      @new_button(9, "latch", show_full_ui, event_queue, new_component);
      @new_button(10, "pulse", show_full_ui, event_queue, new_component);
      removing = false;
    }
    else
    {
      rg::guiToggle({110, 20, 50, 20}, "REMOVE", &removing);
      // rg::guiToggle({170, 20, 50, 20}, "MOVE", &moving);
    }

    rg::guiCheckBox({20, 40, 20, 20}, "Stress Test", &do_spam);

    rg::guiCheckBox({20, 60, 20, 20}, "Show uncapped TPS", &show_uncapped_tps);
    if (show_uncapped_tps)
    {
      rg::guiCheckBox({20, 80, 20, 20}, "Uncap TPS", &uncap_tps);
    }

    /*
     *
     * Show the frame & fps counter
     *
    */
    rl::drawText(rl::textFormat("FPS: %d", rl::getFPS()), 0, 0, 20, rl::DARKGREEN);
    rl::drawText(rl::textFormat("TPS: %d", tps_avg), 90, 0, 20, rl::DARKGREEN);
    rl::drawText(rl::textFormat("Events this tick: %d", event_num), 200, 0, 20, rl::DARKGREEN);
    rl::endDrawing();

  }
  return 0;
}

fn void draw_between_points(Point start, Point end, Color color = rl::RED)
{
  rl::drawLineEx({start.x, start.y}, {end.x, end.y}, 2, color);
}

fault ComponentFault
{
  NONE_NEARBY
}

fn Tuple(<Id, Point>)! get_component_id_near_point(Point point, WorldMap* world, Camera2D* camera, uint tolerance = 0)
{
  foreach (val : world.value_tlist())
  {
    Point key = (Point)((float[<2>])val.get_pos() * camera.zoom) + {(int)camera.offset.x, (int)camera.offset.y};
    Point diff = point - key;
    Point size = (Point)((float[<2>])val.get_size() * camera.zoom);
    if (diff.comp_ge({0, 0} - (size * tolerance)) == {true, true} && diff.comp_le((Point)((float[<2>])val.get_size() * camera.zoom) + size * tolerance) == {true, true})
    {
      return {val.get_id(), diff};
    }
  };
  return ComponentFault.NONE_NEARBY?;
}

// TODO: scale input position & size using camera
fn Tuple(<Id, usz>)! get_component_input_near_point(Point point, WorldMap* world, Camera2D* camera)
{
  if (try Tuple(<Id, Point>) result = get_component_id_near_point(point, world, camera, 1))
  {
    foreach (id, &input : world.get_ref(result.first)!!.get_inputs())
    {
      Point diff = result.second - (Point)((float[<2>])input.position * camera.zoom);
      if (diff.comp_ge({0, 0}) == {true, true} && diff.comp_le((Point)((float[<2>])component::INPUT_SIZE * camera.zoom)) == {true, true})
      {
        return {result.first, id};
      }
    }
  }
  return ComponentFault.NONE_NEARBY?;
}

// TODO: scale output position & size using camera
fn Tuple(<Id, usz>)! get_component_output_near_point(Point point, WorldMap* world, Camera2D* camera)
{
  if (try Tuple(<Id, Point>) result = get_component_id_near_point(point, world, camera, 1))
  {
    foreach (id, &output : world.get_ref(result.first)!!.get_outputs())
    {
      Point diff = result.second - (Point)((float[<2>])output.position * camera.zoom);
      if (diff.comp_ge({0, 0}) == {true, true} && diff.comp_le((Point)((float[<2>])component::OUTPUT_SIZE * camera.zoom)) == {true, true})
      {
        return {result.first, id};
      }
    }
  }
  return ComponentFault.NONE_NEARBY?;
}

macro void @new_button(int $idx, String $type, bool* &show_full_ui, EventQueue* &event_queue, Component* &new_component)
{
  if (rg::guiButton({(float)(110 + 60 * $idx), 20, 50, 20}, $type.temp_ascii_to_upper()))
  {
    *show_full_ui = false;
    $if (!$defined($eval($type +++ "gate"))):
      *new_component = $eval($type +++ "::new")(event_queue, {0, 0}, ++id_counter);
    $else
      *new_component = $eval($type +++ "gate::new")(event_queue, {0, 0}, ++id_counter);
    $endif
  }
}

usz spam;

// I have a feeling that no more than 24 components will be removed in a single tick.
Id[24] recently_removed;
fn bool Id[24].contains(&self, Id id)
{
  foreach (i : self)
  {
    if (i == id) return true;
  }
  return false;
}
usz recently_removed_idx;

fn int component_thread(void* arg)
{
  while (*(bool*)arg)
  {
    Time start_time = time::now();
    /*
     *
     * Handle events
     *
    */

    // Stress test
    if (do_spam)
    {
      for (int i = 0; i < spam; i++)
      {
        if (try world.get(1))
        {
          event_queue.push(component::pressed_event(1, {0, 0}));
        }
        else
        {
          io::printn("Cannot stress test when component id 1 does not exist, you may have removed the initial lever");
          do_spam = false;
        }
      }
      spam += 1;
    }
    else
    {
      spam = 0;
    }

    // TODO: some sort of automatic free for the event queue when the peak is really high and the curent average is really low
    event_num = event_queue.len();

    for (int i = 0; i < event_num; i++)
    {
      GameEvent! event = event_queue.pop();

      if (catch error = event)
      {
        io::printfn("ERROR: unable to handle event with message: %s", error);
      }
      else
      {
        if (event.target_id != 0)
        {
          if (!recently_removed.contains(event.target_id))
          {
            world_mutex.lock()!!;
            world.get_ref(event.target_id)!!.handle_event(&event);
            world_mutex.unlock()!!;
          }
        }
        else
        {
          // TODO: this causes everything to freese for some reason
          world_mutex.lock()!!;
          foreach (id : world.tcopy_keys())
          {
            world.get_ref(id)!!.handle_event(&event);
          }
          if (event.type == COMPONENT_REMOVED)
          {
            recently_removed[recently_removed_idx] = event.data.id;
            recently_removed_idx = (recently_removed_idx + 1) % recently_removed.len;
            world.remove(event.data.id);
          }
          world_mutex.unlock()!!;
        }
      }
    }

    Time end_time = time::now();
    Duration delta_time = end_time.diff_us(start_time);

    usz tps;
    if (!show_uncapped_tps)
    {
      tps = MIN_DELAY_US - delta_time > 0 ? MAX_TPS : (usz)1e6 / (usz)delta_time;
    }
    else
    {
      tps = delta_time > 0 ? (usz)1e6 / (usz)delta_time : 10000000;
    }

    tps_avg -= tps_avg / TPS_SAMPLES;
    tps_avg += tps / TPS_SAMPLES;

    if (!uncap_tps)
    {
      thread::sleep(MIN_DELAY_US - delta_time > 0 ? MIN_DELAY_US - delta_time : 0);
    }
  }
  return 0;
}
