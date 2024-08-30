module electronics_game;

import electronics_game::sdl2;
import electronics_game::sdl2::event_type;
import electronics_game::sdl2::scancode;

import electronics_game::world;

import std::io;
import std::math;

import std::collections::list;
import std::collections::map;

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

  Point pos = {10, 10};

  List(<ushort>) key_buffer;
  key_buffer.new_init();
  defer key_buffer.free();

  World world;
  world.new_init();

  char flipped;

  bool dragging;

  Point mouse_pos;
  Point mouse_grid_pos;
  Point start_point;

  List(<Wire>) wires;
  wires.new_init();
  defer
  {
	foreach (wire : wires)
	{
	  wire.free();
	}
	wires.free();
  }

  HashMap(<Point, Button>) buttons;
  buttons.new_init();
  defer buttons.free();

  
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
		  if (!key_buffer.contains(event.key.keysym.scancode))
		  {
			key_buffer.push(event.key.keysym.scancode);
		  }
		case event_type::KEYUP:
		  key_buffer.remove_item(event.key.keysym.scancode);
		case event_type::MOUSEBUTTONDOWN:
		  if (event.button.button == sdl2::mouse::BUTTON_LEFT)
		  {
			if (buttons.has_key(mouse_grid_pos))
			{
			  io::printn("button pressed!");
			  if (start_point != {})
			  {
				Point corner = get_corner_between_points(start_point, mouse_grid_pos);
				if (corner != mouse_grid_pos)
				{
				  wires.get_ref(wires.len() - 1).points.push(corner);
				}
				wires.get_ref(wires.len() - 1).points.push(mouse_grid_pos);
				List(<Point>) points = get_wire_points(&&wires.last()!!);
				defer points.free();
				wires.get_ref(wires.len() - 1).points.pop()!!;
				points.pop()!!;
				wires.get_ref(wires.len() - 1).points.push(points.pop()!!);
				// buttons.get(mouse_grid_pos);
				// TODO: connect the wire to the button
				start_point = {};
			  }
			}
			else if (start_point == {})
			{
			  Wire wire;
			  wire.new_init();
			  start_point = mouse_grid_pos;
			  wire.points.push(start_point);
			  wires.push(wire);
			}
			else
			{
			  if (wires.get_ref(wires.len() - 1).points.last()!! == mouse_grid_pos) break;
			  Point corner = get_corner_between_points(start_point, mouse_grid_pos);
			  if (corner != mouse_grid_pos)
			  {
				wires.get_ref(wires.len() - 1).points.push(corner);
			  }
			  wires.get_ref(wires.len() - 1).points.push(mouse_grid_pos);
			  start_point = mouse_grid_pos;
			}

			flipped = flipped | (char)(1 << 0x01);
			io::printfn("Pressed left mouse at %s, %s, grid %s, %s", mouse_pos.x, mouse_pos.y, mouse_grid_pos.x, mouse_grid_pos.y);
		  }
		  else if (event.button.button == sdl2::mouse::BUTTON_RIGHT)
		  {
			if (wires.last()!!.points.len() == 1) wires.pop()!!;
			start_point = {};
		  }
		case event_type::MOUSEBUTTONUP:
		  if (event.button.button == sdl2::mouse::BUTTON_LEFT)
		  {
			flipped = flipped & (char)~(1 << 0x01);
			io::printfn("Released left mouse at %s, %s", mouse_pos.x, mouse_pos.y);
		  }

		case event_type::MOUSEMOTION:
		  mouse_pos = {event.button.x, event.button.y};
		  mouse_grid_pos = world.world_to_grid(mouse_pos);

		  if (flipped & (char)(1 << 0x01) != 0)
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
		case scancode::A:
		  pos.x -= 2;
		case scancode::D:
		  pos.x += 2;
		case scancode::W:
		  pos.y -= 2;
		case scancode::S:
		  pos.y += 2;
		case scancode::SPACE:
		  if (!buttons.has_key(mouse_grid_pos))
		  {
			buttons.set(mouse_grid_pos, {mouse_grid_pos, false, null, null, null, null});
		  }
	  }
	}	  
	
	/*
	 *
	 * Clear the background
	 *
   */
	sdl2::set_draw_color(renderer, 0xff, 0xff, 0xff, 0xff);
	sdl2::clear(renderer);

	// io::printfn("%s, %b", mouse_pos, within_radius_of(50, mouse_pos, {200, 200}));
	/*
	 *
	 * Paint main things
	 *
   */
	sdl2::set_draw_color(renderer, 0xff, 0x00, 0x00, 0xff);
	sdl2::fill_rect(renderer, &&Rectangle {pos.x, pos.y, 50, 50});

	foreach (i, wire : wires)
	{
	  if (wire.powered)
	  {
		sdl2::set_draw_color(renderer, 0xff, 0x00, 0x00, 0xff);
	  }
	  else
	  {
		sdl2::set_draw_color(renderer, 0xaf, 0x00, 0x00, 0xff);
	  }
	  for (usz j = 1; j < wire.points.len(); j++)
	  {
		draw_between_grid_points(renderer, world, wire.points[j -1], wire.points[j]);
	  }
	  if (start_point != {} && i == wires.len() - 1)
	  {
		Point corner = get_corner_between_points(wire.points.last()!!, mouse_grid_pos);
		draw_between_grid_points(renderer, world, wire.points.last()!!, corner);
		draw_between_grid_points(renderer, world, corner, mouse_grid_pos);
	  }
	}

	sdl2::set_draw_color(renderer, 0x00, 0xff, 0x00, 0xff);
	foreach (button_pos : buttons.key_tlist())
	{
	  Button button = buttons.get(button_pos)!!;
	  Button temp = {world.grid_to_world(button_pos), button.enabled, button.top, button.bottom, button.left, button.right};
	  sdl2::fill_rect(renderer, &&Rectangle {temp.position.x, temp.position.y, world.scale, world.scale}); 
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

fn void draw_between_grid_points(Renderer renderer, World world, Point start, Point end)
{
  draw_between_points(renderer, world.grid_to_world(start), world.grid_to_world(end));
}

fn void draw_between_points(Renderer renderer, Point start, Point end)
{
  sdl2::fill_rect(renderer, &&Rectangle {start.x, start.y, end.x - start.x + 2, end.y - start.y + 2});
}

fn Point get_corner_between_points(Point start, Point end)
{
  Point curr = start;
  if (curr.x != end.x)
  {
	while (curr.x > end.x) curr.x --;
	while (curr.x < end.x) curr.x ++;

	return curr;
  }
  if (curr.y != end.y)
  {
	while (curr.y > end.y) curr.y --;
	while (curr.y < end.y) curr.y ++;

	return curr;
  }
  // Both are the same already
  return end;
}

fn List(<Point>) get_wire_points(Wire* wire)
{
  List(<Point>) points;
  points.new_init();

  for (usz i = 1; i < wire.points.len(); i++)
  {
	Point start = wire.points[i - 1];
	Point end = wire.points[i];
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
  }

  return points;
}

// fn void spawn_button(World world, Wire[] wires, List(<Button>) buttons, Point position)
// {
//   foreach (wire : wires)
//   {
// 	List(<Point>) wire_points = get_wire_points(wire);
// 	defer wire_points.free();
// 	io::printfn("%s", wire_points.array_view());
// 	if (wire_points.contains(position)) return;
// 	foreach (point : wire_points)
// 	{
// 	  if (within_radius_of(1, position, point))
// 	  {
		
// 	  }
// 	}
//   }
// }

fn bool within_radius_of(int radius, Point p1, Point p2)
{
  return (math::abs(p1 - p2)).comp_le({radius, radius}) == {true, true};
}
