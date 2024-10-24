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


const PointSmall XORGATE_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, XORGATE_SIZE, event_queue, id, XORGATE, {.xorgate = {{component::new_input(id, {0, 0}), component::new_input(id, {XORGATE_SIZE.x, 0})}, {component::new_output(id, {XORGATE_SIZE.x / 2, XORGATE_SIZE.y}, false)}}}};
}

struct Xorgate
{
  Input[2] inputs;
  Output[1] outputs;
}

fn void Xorgate.handle_event(&self, GameEvent* event, EventQueue* event_queue)
{
  switch (event.type)
  {
    case PRESSED:
      break;
    case COMPONENT_REMOVED:
      component::connected_removed(self, event);
      nextcase;
    case POWER_STATE_CHANGE:
      self.recalculate_state(event_queue);
  }
}

fn Output[] Xorgate.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Xorgate.get_inputs(&self)
{
  return &self.inputs;
}

fn void Xorgate.recalculate_state(&self, EventQueue* event_queue) @private
{
  bool old = self.outputs[0].on;
  component::@input_state(self; bool[] state)
  {
    self.outputs[0].on = (state[0] && !state[1]) || (!state[0] && state[1]);
  };
  if (old != self.outputs[0].on && self.outputs[0].in != null)
  {
    event_queue.push(component::power_change_event(self.outputs[0].in.parent_id));
  }
}

fn void Xorgate.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
}
