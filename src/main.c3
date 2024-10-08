module electronics_game;

import electronics_game::sdl2;
import electronics_game::sdl2::event_type;
import electronics_game::sdl2::scancode;

import electronics_game::world;

import std::io;
import std::math;

import std::collections::list;
import std::collections::map;

// def WorldMap = HashMap(<Point, Component>);

bitstruct Modifiers : char
{
  bool shift : 0;
  bool alt : 1;
  bool ctrl : 2;
}


/*
***REMOVED***
*/
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
  Window window = sdl2::create_window("Game", 0, 0, 800, 600, 0);
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
  Renderer renderer = sdl2::create_renderer(window, -1, sdl2::render_flags::ACCELERATED);
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
  Event event;

  bool running = true;

  // Point pos = {10, 10};

  List(<ushort>) key_buffer;
  key_buffer.new_init();
  defer key_buffer.free();
  Modifiers modifiers;

  bool pressing;


  Point mouse_pos;
  Point offset = {0, 0};
  Point mouse_world_pos;
  HashMap(<Point, Component>) world;
  world.new_init();
  defer world.free();
  Queue(<GameEvent>) event_queue;
  event_queue.new_init();
  defer event_queue.free();



  while (running)
  {
    /*
     *
     * Handle events
     *
   */
    while (sdl2::poll_event(&event))
    {
      switch (event.type)
      {
        case event_type::QUIT:
          running = false;
        case event_type::KEYDOWN:
          io::printfn("Keycode: %s", event.key.keysym.scancode);
          switch (event.key.keysym.scancode) {
            case scancode::LSHIFT:
            case scancode::RSHIFT:
              modifiers.shift = true;
            case scancode::LCTRL:
            case scancode::RCTRL:
              modifiers.ctrl = true;

            default:
              if (!key_buffer.contains(event.key.keysym.scancode))
              {
                key_buffer.push(event.key.keysym.scancode);
              }
          }
        case event_type::KEYUP:
          switch (event.key.keysym.scancode) {
            case scancode::LSHIFT:
            case scancode::RSHIFT:
              modifiers.shift = false;
            case scancode::LCTRL:
            case scancode::RCTRL:
              modifiers.ctrl = false;

            default:
              key_buffer.remove_item(event.key.keysym.scancode);
          }
        case event_type::MOUSEBUTTONDOWN:
          if (event.button.button == sdl2::mouse::BUTTON_LEFT)
          {
            pressing = true;
          }
          else if (event.button.button == sdl2::mouse::BUTTON_RIGHT)
          {
          }
        case event_type::MOUSEBUTTONUP:
          if (event.button.button == sdl2::mouse::BUTTON_LEFT)
          {
            pressing = false;
            io::printfn("Released left mouse at %s, %s", mouse_pos.x, mouse_pos.y);
          }

        case event_type::MOUSEMOTION:
          mouse_pos = {event.button.x, event.button.y};
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
    sdl2::set_draw_color(renderer, {0xff, 0x00, 0x00, 0xff});

    // if (start_point != {} && current_wire != 0)
    // {
    //   Point corner = get_corner_between_points(start_point, mouse_grid_pos);
    //   draw_between_grid_points(renderer, world, start_point, corner);
    //   draw_between_grid_points(renderer, world, corner, mouse_grid_pos);
    // }

    // draw_debug_info(renderer, &world, modifiers);

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

// fn void draw_between_grid_points(Renderer renderer, World world, Point start, Point end)
// {
//   draw_between_points(renderer, world.grid_to_world(start), world.grid_to_world(end));
// }

// fn void draw_between_points(Renderer renderer, Point start, Point end)
// {
//   sdl2::fill_rect(renderer, &&Rect {start.x, start.y, end.x - start.x + 2, end.y - start.y + 2});
// }

// fn Point get_corner_between_points(Point start, Point end)
// {
//   Point curr = start;
//   if (curr.x != end.x)
//   {
//     while (curr.x > end.x) curr.x --;
//     while (curr.x < end.x) curr.x ++;

//     return curr;
//   }
//   if (curr.y != end.y)
//   {
//     while (curr.y > end.y) curr.y --;
//     while (curr.y < end.y) curr.y ++;

//     return curr;
//   }
//   // Both are the same already
//   return end;
// }

fn List(<Point>) get_wire_points(Point start, Point end)
{
  List(<Point>) points;
  points.new_init();

  Point curr = start;

  while (curr.x != end.x)
  {
    if (curr.x > end.x) curr.x --;
    if (curr.x < end.x) curr.x ++;

    points.push(curr);
  }
  while (curr.y != end.y)
  {
    if (curr.y > end.y) curr.y --;
    if (curr.y < end.y) curr.y ++;

    points.push(curr);
  }

  return points;
}

// fn bool within_radius_of(int radius, Point p1, Point p2)
// {
//   return (math::abs(p1 - p2)).comp_le({radius, radius}) == {true, true};
// }

// fn void draw_debug_info(Renderer renderer, World* world, Modifiers modifiers)
// {
//   // TODO: show size of world.data, etc
//   sdl2::draw_text(renderer, "Debug", {0, 0});
//   DString buf;
//   Formatter fmt;
//   fmt.init(&push_buf, &buf);
//   // the \0 is VERY important as it null-terminates the string for C to interpret
//   fmt.printf("objects: %d\0", world.data.len() - 1)!!;
//   sdl2::draw_text(renderer, (ZString)buf.str_view(), {0, 20});
//   buf = {};
//   fmt.printf("modifiers: shift:%d, ctrl:%d, alt:%d\0", modifiers.shift, modifiers.ctrl, modifiers.alt)!!;
//   sdl2::draw_text(renderer, (ZString)buf.str_view(), {0, 40});
// }

// fn void! push_buf(void* buffer, char c)
// {
//   ((DString*)buffer).append_char(c);
// }


// // TODO: this leaves behind objects
// // related creating a wire and clicking on the same space causes new wire to create that is never removed
// fn void flood_fill(World* world, Point point, usz data_idx)
// {
//   // Only works on wires
//   if (world.data[data_idx].type != WIRE) return;

//   Point point_to_replace;

//   usz new_data_idx = world.data.len();
//   world.data.push({WIRE, {}});

//   if (world.get_idx_at(point + {0, 1}) == data_idx)
//   {
//     point_to_replace = point + {0, 1};
//   }
//   else if (world.get_idx_at(point - {0, 1}) == data_idx)
//   {
//     point_to_replace = point - {0, 1};
//   }
//   else if (world.get_idx_at(point + {1, 0}) == data_idx)
//   {
//     point_to_replace = point + {1, 0};
//   }
//   else if (world.get_idx_at(point - {1, 0}) == data_idx)
//   {
//     point_to_replace = point - {1, 0};
//   }
//   else
//   {
//     io::printn("Was unable to split wire!");
//     return;
//   }

//   // Depth first search
//   dfs(world, point_to_replace, data_idx, new_data_idx);

//   bool still_exists = false;
//   bool new_exists = false;
//   foreach OUTER: (row : world.grid)
//   {
//     if (row.contains(data_idx))
//     {
//       still_exists = true;
//     }
//     if (row.contains(new_data_idx))
//     {
//       new_exists = true;
//     }
//     if (new_exists && still_exists)
//     {
//       break OUTER;
//     }
//   }
//   if (!still_exists)
//   {
//     world.remove(data_idx);
//   }
//   if (!new_exists)
//   {
//     world.remove(new_data_idx);
//   }
// }

// fn void dfs(World* world, Point point, usz data_idx, usz new_data_idx)
// {
//   if (world.get_idx_at(point) != data_idx) return;

//   world.set_at(point, new_data_idx);

//   if (world.get_idx_at(point + {0, 1}) == data_idx)
//   {
//     dfs(world, point + {0, 1}, data_idx, new_data_idx);
//   }
//   if (world.get_idx_at(point - {0, 1}) == data_idx)
//   {
//     dfs(world, point - {0, 1}, data_idx, new_data_idx);
//   }
//   if (world.get_idx_at(point + {1, 0}) == data_idx)
//   {
//     dfs(world, point + {1, 0}, data_idx, new_data_idx);
//   }
//   if (world.get_idx_at(point - {1, 0}) == data_idx)
//   {
//     dfs(world, point - {1, 0}, data_idx, new_data_idx);
//   }
// }
