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
import raylib5;


const PointSmall NOTGATE_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, NOTGATE_SIZE, event_queue, id, NOTGATE, {.notgate = {{component::new_input(id)}, {component::new_output(id, {0, 1}, true)}}}};
}

struct Notgate
{
  Input[1] inputs;
  Output[1] outputs;
}

fn void Notgate.handle_event(&self, GameEvent* event, EventQueue* event_queue)
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

fn Output[] Notgate.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Notgate.get_inputs(&self)
{
  return &self.inputs;
}
import std::io;
fn void Notgate.recalculate_state(&self, EventQueue* event_queue) @private
{
  bool old = self.outputs[0].on;
  component::@input_state(self; bool[] state)
  {
    self.outputs[0].on = !state[0];
  };
  if (old != self.outputs[0].on && self.outputs[0].in != null)
  {
    event_queue.push(component::power_change_event(self.outputs[0].in.parent_id));
  }
}

fn void Notgate.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
}
