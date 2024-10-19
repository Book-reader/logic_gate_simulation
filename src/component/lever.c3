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
import raylib5::rl;

import std::io;

const Point LEVER_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, LEVER_SIZE, event_queue, id, LEVER, {.lever = {{{false, {0, 1}, 0}}}}};
}

struct Lever
{
  Output[1] outputs;
}

fn void Lever.handle_event(&self, GameEvent* event, EventQueue* event_queue)
{
  switch (event.type)
  {
    case PRESSED:
      self.outputs[0].on = !self.outputs[0].on;
      if (self.outputs[0].connected_id != 0)
      {
        event_queue.push(component::power_change_event(self.outputs[0].connected_id));
      }
      else
      {
        io::printfn("not connected to anything");
      }
    default:
  }
}

fn Output[] Lever.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Lever.get_inputs(&self)
{
  return {};
}

fn void Lever.draw(&self, Point pos, Point size)
{
  // fun compiler SIGSEV in c3 0.6.3
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0xcc, 0x00, 0x00, 0xff} : {0xff, 0x00, 0x00, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
  // sdl2::set_draw_color(renderer, self.outputs[0].on ? {0xcc, 0x00, 0x00, 0xff} : {0xff, 0x00, 0x00, 0xff});
  // sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  // sdl2::draw_text(renderer, self.outputs[0].on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + LEVER_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
}
