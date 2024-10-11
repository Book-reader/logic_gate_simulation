module logic_gate_simulation::component::lever;
/*
 *
 *
 *
 * Lever definition
 *
 *
 *
*/
import sdl2;

import std::io;

const Point LEVER_SIZE = {20, 20};

fn Lever new(EventQueue* event_queue, Point pos, usz id)
{
  return {{false, {0, 1}, 0}, event_queue, LEVER_SIZE, pos, id};
}

struct Lever (Component)
{
  Output main_output;
  EventQueue* event_queue;
  Point size;
  Point pos;
  usz id;
}

fn void Lever.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case PRESSED:
      self.main_output.on = !self.main_output.on;
      if (self.main_output.connected_id != 0)
      {
        self.event_queue.push({POWER_STATE_CHANGE, self.main_output.connected_id, {}});
      }
      else
      {
        io::printfn("not connected to anything");
      }
    default:
  }
}

import std::collections::list;

fn Output*[] Lever.get_outputs(&self) @dynamic
{
  // return {&self.main_output};
  // FIXME: this leaks memory
  List(<Output*>) o;
  o.new_init();
  o.push(&self.main_output);
  return o.array_view();
}

fn Input*[] Lever.get_inputs(&self) @dynamic
{
  return {};
}

fn Point Lever.get_size(&self) @dynamic
{
  return self.size;
}

fn void Lever.draw(&self, SDLRenderer renderer, Point offset) @dynamic
{
  // fun compiler SIGSEV in c3 0.6.3
  sdl2::set_draw_color(renderer, self.main_output.on ? {0xcc, 0x00, 0x00, 0xff} : {0xff, 0x00, 0x00, 0xff});
  sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  sdl2::draw_text(renderer, self.main_output.on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + LEVER_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
}

fn Point Lever.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Lever.get_id(&self) @dynamic
{
  return self.id;
}

