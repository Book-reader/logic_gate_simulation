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
  defer world.free();

  char pressing;
  Component temp_wire = {};
  Component* current_wire = &temp_wire;
  Point start_point;

  
  Point mouse_pos;
  Point mouse_grid_pos;
  
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
			pressing = pressing | (char)(1 << 0x01);
			io::printfn("Pressed left mouse at %s, %s, grid %s, %s", mouse_pos.x, mouse_pos.y, mouse_grid_pos.x, mouse_grid_pos.y);

			if (current_wire.equals({}) && start_point == {})
			{
			  temp_wire = {WIRE, {}};
			  current_wire = &temp_wire;
			  io::printn("a");
			  start_point = mouse_grid_pos;
			}
			else if (!current_wire.equals({}) && start_point != {})
			{
			  if (world.data.last_ref() != current_wire)
			  {
				world.data.push(temp_wire);
				temp_wire = {};
				current_wire = world.data.last_ref();
			  }
			  List(<Point>) points = get_wire_points(start_point, mouse_grid_pos);
			  defer points.free();
			  bool do_ = true;
			  foreach (cell : points)
			  {
				if (world.get_at(cell).type != NULL) do_ = false;
			  }
			  if (do_)
			  {
				foreach (cell : points)
				{
				  world.set_at(cell, current_wire);
				}
				start_point = mouse_grid_pos;
			  }
			}
		  }
		  else if (event.button.button == sdl2::mouse::BUTTON_RIGHT)
		  {
			start_point = {};
			temp_wire = {};
			current_wire = &temp_wire;
		   }
		case event_type::MOUSEBUTTONUP:
		  if (event.button.button == sdl2::mouse::BUTTON_LEFT)
		  {
			pressing = pressing & (char)~(1 << 0x01);
			io::printfn("Released left mouse at %s, %s", mouse_pos.x, mouse_pos.y);
		  }

		case event_type::MOUSEMOTION:
		  mouse_pos = {event.button.x, event.button.y};
		  mouse_grid_pos = world.world_to_grid(mouse_pos);

		  if (pressing & (char)(1 << 0x01) != 0)
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
		  if (world.get_at(mouse_grid_pos).type == NULL)
		  {
			world.data.push({BUTTON, {}});
			world.set_at(mouse_grid_pos, world.data.last_ref());
		  }
		case scancode::BACKSPACE:
		  if (world.get_at(mouse_grid_pos).type != NULL)
		  {
			*world.get_at(mouse_grid_pos) = world::null_component;
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

	/*
	 *
	 * Paint main things
	 *
   */
	sdl2::set_draw_color(renderer, 0xff, 0x00, 0x00, 0xff);
	sdl2::fill_rect(renderer, &&Rectangle {pos.x, pos.y, 50, 50});

	if (start_point != {} && !current_wire.equals({}))
	{
	  Point corner = get_corner_between_points(start_point, mouse_grid_pos);
	  draw_between_grid_points(renderer, world, start_point, corner);
	  draw_between_grid_points(renderer, world, corner, mouse_grid_pos);
	}

	foreach (x, row : world.grid)
	{
	  foreach (y, cell : row)
	  {
		switch (cell.type)
		{
		  case WIRE:
			if (cell.data.as_button.enabled)
			{
			  sdl2::set_draw_color(renderer, 0xff, 0x00, 0x00, 0xff);
			}
			else
			{
			  sdl2::set_draw_color(renderer, 0xaa, 0x00, 0x00, 0xff);
			}
			sdl2::fill_rect(renderer, &&Rectangle {world.grid_to_world({(int)x, 0}).x, world.grid_to_world({0, (int)y}).y, world.scale, world.scale});
		  case BUTTON:
			sdl2::set_draw_color(renderer, 0x00, 0xff, 0x00, 0xff);
			sdl2::fill_rect(renderer, &&Rectangle {world.grid_to_world({(int)x, 0}).x, world.grid_to_world({0, (int)y}).y, world.scale, world.scale});
		  default:
		}
	  }
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

fn bool within_radius_of(int radius, Point p1, Point p2)
{
  return (math::abs(p1 - p2)).comp_le({radius, radius}) == {true, true};
}
