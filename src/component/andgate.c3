module logic_gate_simulation::component::andgate;
/*
 *
 *
 *
 * Andgate definition
 *
 *
 *
*/
import raylib5;


const Point ANDGATE_SIZE = {20, 20};

// fn Andgate new(EventQueue* event_queue, Point pos, usz id)
// {
//   return {event_queue, ANDGATE_SIZE, pos, id};
// }

fn Component new(EventQueue* event_queue, Point pos, usz id)
{
  return {pos, ANDGATE_SIZE, event_queue, id, ANDGATE, {.andgate = {{{id, null}, {id, null}}, {{false, {0, 1}, 0}}}}};
}

struct Andgate// (Component)
{
  Input[2] inputs;
  Output[1] outputs;
}

fn void Andgate.handle_event(&self, GameEvent* event, EventQueue* event_queue)
{
  switch (event.type)
  {
    case PRESSED:
      break;
    case CONNECTED_COMPONENT_REMOVED:
      component::connected_removed(self, event);
      nextcase;
    case POWER_STATE_CHANGE:
      self.recalculate_state(event_queue);
  }
}

fn Output[] Andgate.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Andgate.get_inputs(&self)
{
  return &self.inputs;
}

fn void Andgate.recalculate_state(&self, EventQueue* event_queue) @private
{
  if (self.inputs[0].on != null && self.inputs[1].on != null)
  {
    bool tmp = self.outputs[0].on;
    self.outputs[0].on = *self.inputs[0].on && *self.inputs[1].on;
    if (tmp != self.outputs[0].on)
    {
      event_queue.push(component::power_change_event(self.outputs[0].connected_id));
    }
  }
  else
  {
    self.outputs[0].on = false;
  }
}

fn void Andgate.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
  // sdl2::set_draw_color(renderer, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  // sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  // sdl2::draw_text(renderer, self.outputs[0].on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + ANDGATE_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
}
