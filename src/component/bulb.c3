module logic_gate_simulation::component::bulb;
/*
 *
 *
 *
 * Bulb definition
 *
 *
 *
*/
import sdl2;

import std::collections::list;

const Point BULB_SIZE = {20, 20};

fn Bulb new(EventQueue* event_queue, Point pos, usz id)
{
  return {{id, null}, event_queue, BULB_SIZE, false, pos, id};
}

struct Bulb (Component)
{
  Input main_input;
  EventQueue* event_queue;
  Point size;
  bool on;
  Point pos;
  usz id;
}

fn void Bulb.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case POWER_STATE_CHANGE:
      self.recalculate_state();
    case CONNECTED_COMPONENT_REMOVED:
      self.main_input.on = null;
      self.recalculate_state();
    case PRESSED:
      break;
  }
}

fn Output*[] Bulb.get_outputs(&self) @dynamic
{
  return {};
}

fn Input*[] Bulb.get_inputs(&self) @dynamic
{
  // return {&self.main_input};
  // FIXME: this leaks memory
  List(<Input*>) o;
  o.new_init();
  o.push(&self.main_input);
  return o.array_view();
}

fn Point Bulb.get_size(&self) @dynamic
{
  return self.size;
}

fn void Bulb.recalculate_state(&self)
{
  if (self.main_input.on != null)
  {
    self.on = *self.main_input.on;
  }
  else
  {
    self.on = false;
  }
}

fn void Bulb.draw(&self, SDLRenderer renderer, Point offset) @dynamic
{
  sdl2::set_draw_color(renderer, self.on ? {0xff, 0x00, 0xff, 0xff} : {0x00, 0x00, 0x00, 0xff});
  sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  sdl2::draw_text(renderer, self.on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + BULB_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0xff, 0xff, 0xff, 0xff});
}

fn Point Bulb.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Bulb.get_id(&self) @dynamic
{
  return self.id;
}
