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
  world.set(++id_counter, lever::new(&event_queue, {200, 100}, id_counter));

  world.set(++id_counter, xorgate::new(&event_queue, {150, 150}, id_counter));

  world.set(++id_counter, bulb::new(&event_queue, {150, 200}, id_counter));
  world_mutex.unlock()!!;

  component::connect(&event_queue, world.get_ref(1)!!, 0, world.get_ref(3)!!, 0);
  component::connect(&event_queue, world.get_ref(2)!!, 0, world.get_ref(3)!!, 1);

  component::connect(&event_queue, world.get_ref(3)!!, 0, world.get_ref(4)!!, 0);

  Component new_component;

  while (!rl::windowShouldClose())
  {
    if (rl::isMouseButtonReleased(MouseButton.LEFT))
    {
      Vector2 mouse_pos = rl::getMousePosition();
      if (new_component.type != NONE)
      {
        world_mutex.lock()!!;
        world.set(id_counter, new_component);
        world_mutex.unlock()!!;
        new_component.type = NONE;
      }
      else if (try Tuple(<Id, Point>) component = get_component_id_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world))
      {
        if (!removing)
        {
          event_queue.push(component::pressed_event(component.first,component.second));
        }
        else
        {
          event_queue.push(component::removed_event(component.first));
          removing = false;
        }
      }
      else if (removing)
      {
        removing = false;
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
          draw_between_points(component.get_pos(), world.get(output.in.parent_id)!!.get_pos());
        }
      }
      component.draw();
    }
    if (new_component.type != NONE)
    {
      Vector2 pos = rl::getMousePosition();
      new_component.set_pos({(int)pos.x, (int)pos.y});
      new_component.draw();
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
      removing = false;
    }
    else
    {
      rg::guiToggle({110, 20, 50, 20}, "REMOVE", &removing);
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

fn Tuple(<Id, Point>)! get_component_id_near_point(Point point, WorldMap* world)
{
  foreach (val : world.value_tlist())
  {
    Point key = val.get_pos();
    Point dif = point - key;
    if ((dif).comp_ge({0, 0}) == {true, true} && (dif).comp_le(val.get_size()) == {true, true})
    {
      return {val.get_id(), dif};
    }
  };

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

    event_queue_mutex.lock()!!;
    // Stress test
    if (do_spam)
    {
      for (int i = 0; i < spam; i++)
      {
        event_queue.push(component::pressed_event(1, {0, 0}));
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
          world_mutex.lock()!!;
          world.get_ref(event.target_id)!!.handle_event(&event);
          world_mutex.unlock()!!;
        }
        else
        {
          world_mutex.lock()!!;
          foreach (id : world.tcopy_keys())
          {
            world.get_ref(id)!!.handle_event(&event);
          }
          if (event.type == COMPONENT_REMOVED)
          {
            world.remove(event.data.id);
          }
          world_mutex.unlock()!!;
        }
      }
    }
    event_queue_mutex.unlock()!!;

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
