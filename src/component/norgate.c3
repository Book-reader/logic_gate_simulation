module logic_gate_simulation::component::norgate;
/*
 *
 *
 *
 * Norgate definition
 *
 *
 *
*/
//import sdl2;

// TODO remove (hack that causes memory leak)


const Point NORGATE_SIZE = {20, 20};

fn Norgate new(EventQueue* event_queue, Point pos, usz id)
{
  return {{{id, null}, {id, null}}, {{true, {0, 1}, 0}}, event_queue, NORGATE_SIZE, pos, id};
}

struct Norgate (Component)
{
  Input[2] inputs;
  Output[1] outputs;
  EventQueue* event_queue;
  Point size;
  Point pos;
  usz id;
}

fn void Norgate.handle_event(&self, GameEvent* event) @dynamic
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
      if (self.inputs[1].parent_id == event.data.id)
      {
        self.inputs[1].parent_id = 0;
      }
      nextcase;
    case POWER_STATE_CHANGE:
      self.recalculate_state();
  }
}

fn Output[] Norgate.get_outputs(&self) @dynamic
{
  return &self.outputs;
}

fn Input[] Norgate.get_inputs(&self) @dynamic
{
  return &self.inputs;
}

fn Point Norgate.get_size(&self) @dynamic
{
  return self.size;
}

fn void Norgate.recalculate_state(&self)
{
  if (self.inputs[0].on != null && self.inputs[1].on != null)
  {
    bool tmp = self.outputs[0].on;
    self.outputs[0].on = !(*self.inputs[0].on || *self.inputs[1].on);
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

fn void Norgate.draw(&self) @dynamic
{
  // sdl2::set_draw_color(renderer, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  // sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  // sdl2::draw_text(renderer, self.outputs[0].on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + NORGATE_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
}

fn Point Norgate.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Norgate.get_id(&self) @dynamic
{
  return self.id;
}

fn void Norgate.set_pos(&self, Point pos) @dynamic
{
  self.pos = pos;
}
