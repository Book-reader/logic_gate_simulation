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

// usz is id
def WorldMap = HashMap(<usz, Component>);
usz id_counter = 0;

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

fn int main(String[] args)
{
  rl::initWindow(...SCREEN_SIZE, "Game Window");
  defer rl::closeWindow();
  rl::setTargetFPS(60);

  bool show_full_ui = false;

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
  // world.set(++id_counter, lever::new(&event_queue, {200, 100}, id_counter));

  // world.set(++id_counter, &&xorgate::new(&event_queue, {150, 150}, id_counter));
  // world.set(++id_counter, orgate::new(&event_queue, {150, 150}, id_counter));

  for (int i = 0; i < 10; i++)
  {
    world.set(++id_counter, orgate::new(&event_queue, {160 + (i * 25), 150}, id_counter));
  }

  // world.set(++id_counter, bulb::new(&event_queue, {150, 200}, id_counter));
  world_mutex.unlock()!!;

  component::connect(&event_queue, world.get_ref(1)!!, 0, world.get_ref(3)!!, 0);
  component::connect(&event_queue, world.get_ref(2)!!, 0, world.get_ref(3)!!, 1);

  for (usz i = 2; i < 12; i++)
  {
    component::connect(&event_queue, world.get_ref(i - 1)!!, 0, world.get_ref(i)!!, 0);
  }

  // component::connect(&event_queue, world.get_ref(3)!!, 0, world.get_ref(4)!!, 0);

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
      else if (try Tuple(<usz, Point>) component = get_component_id_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world))
      {
        event_queue.push(component::pressed_event(component.first,component.second));
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
        if (output.connected_id != 0)
        {
          draw_between_points(component.get_pos(), world.get(output.connected_id)!!.get_pos());
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
      if (rg::guiButton({110, 20, 50, 20}, "SWITCH"))
      {
        show_full_ui = false;
        new_component = lever::new(&event_queue, {0, 0}, ++id_counter);
      }
      if (rg::guiButton({170, 20, 50, 20}, "LAMP"))
      {
        show_full_ui = false;
        new_component = bulb::new(&event_queue, {0, 0}, ++id_counter);
      }
      if (rg::guiButton({230, 20, 50, 20}, "AND"))
      {
        show_full_ui = false;
        new_component = andgate::new(&event_queue, {0, 0}, ++id_counter);
      }
    }

    rg::guiCheckBox({20, 40, 20, 20}, "Stress Test", &do_spam);

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

fn Tuple(<usz, Point>)! get_component_id_near_point(Point point, WorldMap* world)
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
          io::printfn("WARNING: found event without target, this is not implemented yet. type: %s", event.type);
          // TODO: might will be used for deleting components
        }
      }
    }
    event_queue_mutex.unlock()!!;

    Time end_time = time::now();
    Duration delta_time = end_time.diff_us(start_time);
    // io::printfn("%s, %s, %s", delta_time, MIN_DELAY_US - delta_time, MIN_DELAY_US);

    usz tps = MIN_DELAY_US - delta_time > 0 ? MAX_TPS : (usz)1e6 / (usz)delta_time;

    tps_avg -= tps_avg / TPS_SAMPLES;
    tps_avg += tps / TPS_SAMPLES;

    thread::sleep(MIN_DELAY_US - delta_time > 0 ? MIN_DELAY_US - delta_time : 0);
  }
  return 0;
}
