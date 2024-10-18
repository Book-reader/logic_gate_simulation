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


const Point NOTGATE_SIZE = {20, 20};

fn Notgate new(EventQueue* event_queue, Point pos, usz id)
{
  return {{{id, null}}, {{true, {0, 1}, 0}}, event_queue, NOTGATE_SIZE, pos, id};
}

struct Notgate (Component)
{
  Input[1] inputs;
  Output[1] outputs;
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
      if (self.inputs[0].parent_id == event.data.id)
      {
        self.inputs[0].parent_id = 0;
      }
      nextcase;
    case POWER_STATE_CHANGE:
      self.recalculate_state();
  }
}

fn Output[] Notgate.get_outputs(&self) @dynamic
{
  return &self.outputs;
}

fn Input[] Notgate.get_inputs(&self) @dynamic
{
  return &self.inputs;
}

fn Point Notgate.get_size(&self) @dynamic
{
  return self.size;
}

fn void Notgate.recalculate_state(&self)
{
  if (self.inputs[0].on != null)
  {
    bool tmp = self.outputs[0].on;
    self.outputs[0].on = !*self.inputs[0].on;
    if (tmp != self.outputs[0].on)
    {
      self.event_queue.push(component::power_change_event(self.outputs[0].connected_id));
    }
  }
  else
  {
    self.outputs[0].on = false;
  }
}

fn void Notgate.draw(&self) @dynamic
{
  // sdl2::set_draw_color(renderer, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  // sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  // sdl2::draw_text(renderer, self.outputs[0].on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + NOTGATE_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
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
