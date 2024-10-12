module logic_gate_simulation;

import sdl2;
import sdl2::event_type;
import sdl2::scancode;

import sdl2_ui;

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

fn int main(String[] args)
{
  /*
   *
   * Initialize sdl2
   *
  */
  if (sdl2::init(sdl2::INIT_EVERYTHING) < 0)
  {
    io::printfn("Failed to init SDL: %s", sdl2::get_error());
    return 1;
  }
  defer sdl2::quit();

  if (sdl2::ttf_init() < 0)
  {
    io::printfn("Failed to init SDL_ttf: %s", sdl2::get_error());
    return 1;
  }
  defer sdl2::ttf_quit();

  /*
   *
   * Initialize the main window
   *
  */
  SDLWindow window = sdl2::create_window("Game", 0, 0, 800, 600, 0);
  defer sdl2::destroy_window(window);


  if (!window)
  {
    io::printfn("Failed to open window: %s", sdl2::get_error());
    return 1;
  }

  /*
   *
   * Initialize the renderer
   *
  */
  SDLRenderer renderer = sdl2::create_renderer(window, -1, sdl2::render_flags::ACCELERATED);
  defer sdl2::destroy_renderer(renderer);

  if (!renderer)
  {
    io::printfn("Failed to create renderer: %s", sdl2::get_error());
    return 1;
  }

  /*
   *
   * Main game loop
   *
  */
  SDLEvent sdl_event;

  bool running = true;

  List(<ushort>) key_buffer;
  key_buffer.new_init();
  defer key_buffer.free();
  Modifiers modifiers;

  bool pressing;


  Point mouse_pos;
  Point offset = {0, 0};
  Point mouse_world_pos;
  WorldMap world;
  world.new_init();
  defer world.free();
  EventQueue event_queue;
  event_queue.new_init();
  defer event_queue.free();

  world.set(++id_counter, &&lever::new(&event_queue, {100, 100}, id_counter));
  world.set(++id_counter, &&lever::new(&event_queue, {200, 100}, id_counter));

  world.set(++id_counter, &&xnorgate::new(&event_queue, {150, 150}, id_counter));
  world.set(++id_counter, &&bulb::new(&event_queue, {150, 200}, id_counter));

  component::connect(&event_queue, world.get_ref(1)!!, 0, world.get_ref(3)!!, 0);
  component::connect(&event_queue, world.get_ref(2)!!, 0, world.get_ref(3)!!, 1);

  component::connect(&event_queue, world.get_ref(3)!!, 0, world.get_ref(4)!!, 0);

  List(<UIElement>) ui_elements;
  ui_elements.new_init();
  defer ui_elements.free();

  ui_elements.push(&&sdl2_ui::new_button({10, 10}, "XNOR", fn () => {|
    io::printn("XNOR");
  |}).set_size({40, 20}));

  while (running)
  {
    /*
     *
     * Handle events
     *
    */
    while (sdl2::poll_event(&sdl_event))
    {
      switch (sdl_event.type)
      {
        case event_type::QUIT:
          running = false;
        case event_type::KEYDOWN:
          io::printfn("Keycode: %s", sdl_event.key.keysym.scancode);
          switch (sdl_event.key.keysym.scancode) {
            case scancode::LSHIFT:
            case scancode::RSHIFT:
              modifiers.shift = true;
            case scancode::LCTRL:
            case scancode::RCTRL:
              modifiers.ctrl = true;

            default:
              if (!key_buffer.contains(sdl_event.key.keysym.scancode))
              {
                key_buffer.push(sdl_event.key.keysym.scancode);
              }
          }
        case event_type::KEYUP:
          switch (sdl_event.key.keysym.scancode) {
            case scancode::LSHIFT:
            case scancode::RSHIFT:
              modifiers.shift = false;
            case scancode::LCTRL:
            case scancode::RCTRL:
              modifiers.ctrl = false;

            default:
              key_buffer.remove_item(sdl_event.key.keysym.scancode);
          }
        case event_type::MOUSEBUTTONDOWN:
          if (sdl_event.button.button == sdl2::mouse::BUTTON_LEFT)
          {
            pressing = true;
          }
          else if (sdl_event.button.button == sdl2::mouse::BUTTON_RIGHT)
          {
          }
        case event_type::MOUSEBUTTONUP:
          if (sdl_event.button.button == sdl2::mouse::BUTTON_LEFT)
          {
            pressing = false;
          }
          if (try Tuple(<usz, Point>) component = get_component_id_near_point(mouse_pos, &world))
          {
            event_queue.push({PRESSED, component.first, {.pos = component.second}});
          }
          else if (try UIElement* elem = get_ui_elem_near_point(mouse_pos, &ui_elements))
          {
            elem.on_click();
          }

        case event_type::MOUSEMOTION:
          mouse_pos = {sdl_event.button.x, sdl_event.button.y};
          mouse_world_pos = mouse_pos + offset;

          if (pressing)
          {
            io::printfn("dragged left mouse!");
          }
        default:
      }
    }

    /*
     *
     * Handle keys
     *
    */
    foreach (key : key_buffer)
    {
      switch (key)
      {
        case scancode::ESCAPE:
          running = false;
        case scancode::SPACE:
        case scancode::BACKSPACE:
          break;
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
    sdl2::set_draw_color(renderer, {0xff, 0xff, 0xff, 0xff});
    sdl2::clear(renderer);

    /*
     *
     * Paint main things
     *
    */

    foreach (value : world.value_tlist())
    {
      value.draw(renderer, offset);

      foreach (output : value.get_outputs())
      {
        draw_between_points(renderer, value.get_pos(), world.get(output.connected_id)!!.get_pos());
      }
    };

    /*
     *
     * Paint UI
     *
    */

    // TODO: layering by using multiple arrays (ui_elements_0, ui_elements_1, etc)
    foreach (elem : ui_elements)
    {
      elem.draw(renderer, offset);
    }

    /*
     *
     * Show the frame and set 60 fps
     *
    */
    sdl2::present(renderer);
    sdl2::delay(16);
  }
  return 0;
}

fn void draw_between_points(SDLRenderer renderer, Point start, Point end)
{
  sdl2::draw_line(renderer, ...start, ...end);
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

fn UIElement*! get_ui_elem_near_point(Point point, List(<UIElement>)* elems)
{
  foreach (&val : elems)
  {
    Point key = val.get_pos();
    Point dif = point - key;
    if (val.is_clickable() && (dif).comp_ge({0, 0}) == {true, true} && (dif).comp_le(val.get_size()) == {true, true})
    {
      return val;
    }
  };

  return ComponentFault.NONE_NEARBY?;
}
