module logic_gate_simulation::component::notgate;
/*
 *
 *
 *
 * Notgate definition
 *
 *
 *
*/
//import sdl2;

// TODO remove (hack that causes memory leak)
import std::collections::list;

const Point NOTGATE_SIZE = {20, 20};

fn Notgate new(EventQueue* event_queue, Point pos, usz id)
{
  return {{id, null}, {true, {0, 1}, 0}, event_queue, NOTGATE_SIZE, pos, id};
}

struct Notgate (Component)
{
  Input main_input;
  Output main_output;
  EventQueue* event_queue;
  Point size;
  Point pos;
  usz id;
}

fn void Notgate.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case PRESSED:
      break;
    case CONNECTED_COMPONENT_REMOVED:
      if (self.main_input.parent_id == event.data.id)
      {
        self.main_input.parent_id = 0;
      }
      nextcase;
    case POWER_STATE_CHANGE:
      self.recalculate_state();
  }
}

fn Output*[] Notgate.get_outputs(&self) @dynamic
{
  // return {&self.main_output};
  List(<Output*>) o;
  o.new_init();
  o.push(&self.main_output);
  return o.array_view();
}

fn Input*[] Notgate.get_inputs(&self) @dynamic
{
  // return {&self.left_input, &self.right_input};
  List(<Input*>) o;
  o.new_init();
  o.push(&self.main_input);
  return o.array_view();
}

fn Point Notgate.get_size(&self) @dynamic
{
  return self.size;
}

fn void Notgate.recalculate_state(&self)
{
  if (self.main_input.on != null)
  {
    bool tmp = self.main_output.on;
    self.main_output.on = !*self.main_input.on;
    if (tmp != self.main_output.on)
    {
      self.event_queue.push({POWER_STATE_CHANGE, self.main_output.connected_id, {}});
    }
  }
  else
  {
    self.main_output.on = false;
  }
}

fn void Notgate.draw(&self) @dynamic
{
  // sdl2::set_draw_color(renderer, self.main_output.on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  // sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  // sdl2::draw_text(renderer, self.main_output.on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + NOTGATE_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
}

fn Point Notgate.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Notgate.get_id(&self) @dynamic
{
  return self.id;
}

fn void Notgate.set_pos(&self, Point pos) @dynamic
{
  self.pos = pos;
}
