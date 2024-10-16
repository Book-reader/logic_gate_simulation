module logic_gate_simulation;

import raylib5;
import raygui;

import logic_gate_simulation::component;

import std::io;
import std::math;

import std::collections::list;
import std::collections::map;
import std::collections::tuple;

// usz is id
def WorldMap = HashMap(<usz, Component>);
usz id_counter = 0;

bitstruct Modifiers : char
{
  bool shift : 0;
  bool alt : 1;
  bool ctrl : 2;
}

const Point SCREEN_SIZE = {800, 600};

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

  WorldMap world;
  world.new_init();
  defer world.free();
  EventQueue event_queue;
  event_queue.new_init();
  defer event_queue.free();

  world.set(++id_counter, &&lever::new(&event_queue, {100, 100}, id_counter));
  world.set(++id_counter, &&lever::new(&event_queue, {200, 100}, id_counter));

  world.set(++id_counter, &&xorgate::new(&event_queue, {150, 150}, id_counter));
  world.set(++id_counter, &&bulb::new(&event_queue, {150, 200}, id_counter));

  component::connect(&event_queue, world.get_ref(1)!!, 0, world.get_ref(3)!!, 0);
  component::connect(&event_queue, world.get_ref(2)!!, 0, world.get_ref(3)!!, 1);

  component::connect(&event_queue, world.get_ref(3)!!, 0, world.get_ref(4)!!, 0);

  Component new_component;

  while (!rl::windowShouldClose())
  {
    rl::drawFPS(20, 20);
    if (rl::isMouseButtonReleased(MouseButton.LEFT))
    {
      Vector2 mouse_pos = rl::getMousePosition();
      if (new_component != null)
      {
        world.set(id_counter, new_component);
        new_component = null;
      }
      else if (try Tuple(<usz, Point>) component = get_component_id_near_point({(int)mouse_pos.x, (int)mouse_pos.y}, &world))
      {
        event_queue.push(component::pressed_event(component.first,component.second));
      }
    }
    /*
     *
     * Handle events
     *
    */

    usz event_num = event_queue.len();
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
          world.get(event.target_id)!!.handle_event(&event);
        }
        else
        {
          io::printfn("WARNING: found event without target, this is not implemented yet. type: %s", event.type);
          // TODO: might will be used for deleting components
        }
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
    foreach (value : world.value_tlist())
    {
      foreach (output : value.get_outputs())
      {
        if (output.connected_id != 0)
        {
          draw_between_points(value.get_pos(), world.get(output.connected_id)!!.get_pos());
        }
      }

      value.draw();
    };
    if (new_component != null)
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

    rg::guiToggle({50, 20, 50, 20}, "new", &show_full_ui);

    if (show_full_ui)
    {
      if (rg::guiButton({110, 20, 50, 20}, "SWITCH"))
      {
        show_full_ui = false;
        new_component = &&lever::new(&event_queue, {0, 0}, ++id_counter);
      }
      if (rg::guiButton({170, 20, 50, 20}, "LAMP"))
      {
        show_full_ui = false;
      }
      if (rg::guiButton({230, 20, 50, 20}, "AND"))
      {
        show_full_ui = false;
      }
    }

    /*
     *
     * Show the frame and set 60 fps
     *
    */
    rl::endDrawing();

  }
  return 0;
}

fn void draw_between_points(Point start, Point end)
{
  rl::drawLineEx({start.x, start.y}, {end.x, end.y}, 2, rl::RED);
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

// fn UIElement*! get_ui_elem_near_point(Point point, List(<UIElement>)* elems)
// {
//   foreach (&val : elems)
//   {
//     Point key = val.get_pos();
//     Point dif = point - key;
//     if (val.is_visible() && val.is_clickable() && (dif).comp_ge({0, 0}) == {true, true} && (dif).comp_le(val.get_size()) == {true, true})
//     {
//       return val;
//     }
//   };

//   return ComponentFault.NONE_NEARBY?;
// }

