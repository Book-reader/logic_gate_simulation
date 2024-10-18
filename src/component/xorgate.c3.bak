module logic_gate_simulation::component::xorgate;
/*
 *
 *
 *
 * Xorgate definition
 *
 *
 *
*/
import raylib5;


const Point XORGATE_SIZE = {20, 20};

fn Xorgate new(EventQueue* event_queue, Point pos, usz id)
{
  return {{{id, null}, {id, null}}, {{false, {0, 1}, 0}}, event_queue, XORGATE_SIZE, pos, id};
}

struct Xorgate (Component)
{
  Input[2] inputs;
  Output[1] outputs;
  EventQueue* event_queue;
  Point size;
  Point pos;
  usz id;
}

fn void Xorgate.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case PRESSED:
      break;
    case CONNECTED_COMPONENT_REMOVED:
      component::connected_removed(self, event);
      nextcase;
    case POWER_STATE_CHANGE:
      self.recalculate_state();
  }
}

fn Output[] Xorgate.get_outputs(&self) @dynamic
{
  return &self.outputs;
}

fn Input[] Xorgate.get_inputs(&self) @dynamic
{
  return &self.inputs;
}

fn Point Xorgate.get_size(&self) @dynamic
{
  return self.size;
}

fn void Xorgate.recalculate_state(&self)
{
  if (self.inputs[0].on != null && self.inputs[1].on != null)
  {
    bool old_output = self.outputs[0].on;
    self.outputs[0].on = (*self.inputs[0].on && !*self.inputs[1].on) || (!*self.inputs[0].on && *self.inputs[1].on);
    if (old_output != self.outputs[0].on)
    {
      self.event_queue.push(component::power_change_event(self.outputs[0].connected_id));
    }
  }
  else
  {
    self.outputs[0].on = false;
  }
}

fn void Xorgate.draw(&self) @dynamic
{
  rl::drawRectangle(...self.pos, ...self.size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...self.pos + {4, 0}, 24, rl::BLACK);
  // sdl2::set_draw_color(renderer, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  // sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  // sdl2::draw_text(renderer, self.outputs[0].on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + XORGATE_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
}

fn Point Xorgate.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Xorgate.get_id(&self) @dynamic
{
  return self.id;
}

fn void Xorgate.set_pos(&self, Point pos) @dynamic
{
  self.pos = pos;
}
