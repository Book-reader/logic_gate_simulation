module logic_gate_simulation::component::orgate;
/*
 *
 *
 *
 * Orgate definition
 *
 *
 *
*/
import raylib5;


const Point ORGATE_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, ORGATE_SIZE, event_queue, id, ORGATE, {.orgate = {{{id, null}, {id, null}}, {{false, {0, 1}, 0}}}}};
}

struct Orgate
{
  Input[2] inputs;
  Output[1] outputs;
}

fn void Orgate.handle_event(&self, GameEvent* event, EventQueue* event_queue)
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

fn Output[] Orgate.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Orgate.get_inputs(&self)
{
  return &self.inputs;
}

fn void Orgate.recalculate_state(&self, EventQueue* event_queue) @private
{
  bool old = self.outputs[0].on;
  component::@input_state(self; bool[] state)
  {
    self.outputs[0].on = state[0] || state[1];
  };
  if (old != self.outputs[0].on && self.outputs[0].connected_id != 0)
  {
    event_queue.push(component::power_change_event(self.outputs[0].connected_id));
  }
}

fn void Orgate.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
}
