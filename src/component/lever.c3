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

const PointSmall LEVER_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, LEVER_SIZE, event_queue, id, LEVER, {.lever = {{component::new_output(id, {LEVER_SIZE.x / 2 - component::OUTPUT_SIZE.x / 2 , LEVER_SIZE.y}, false)}}}};
}

struct Lever
{
  Output[1] outputs;
}

fn void Lever.handle_event(&self, GameEvent* event, EventQueue* event_queue)
{
  switch (event.type)
  {
    case COMPONENT_REMOVED:
      component::connected_removed(self, event);
    case PRESSED:
      self.outputs[0].on = !self.outputs[0].on;
      if (self.outputs[0].in != null)
      {
        event_queue.push(component::power_change_event(self.outputs[0].in.parent_id));
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
