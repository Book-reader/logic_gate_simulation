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
import raylib5;


const Point NORGATE_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, usz id)
{
  return {pos, NORGATE_SIZE, event_queue, id, NORGATE, {.norgate = {{{id, null}, {id, null}}, {{true, {0, 1}, 0}}}}};
}

struct Norgate
{
  Input[2] inputs;
  Output[1] outputs;
}

fn void Norgate.handle_event(&self, GameEvent* event, EventQueue* event_queue)
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

fn Output[] Norgate.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Norgate.get_inputs(&self)
{
  return &self.inputs;
}
import std::io;
fn void Norgate.recalculate_state(&self, EventQueue* event_queue) @private
{
  bool old = self.outputs[0].on;
  component::@input_state(self; bool[] state)
  {
    self.outputs[0].on = !(state[0] || state[1]);
  };
  if (old != self.outputs[0].on && self.outputs[0].connected_id != 0)
  {
    event_queue.push(component::power_change_event(self.outputs[0].connected_id));
  }
}

fn void Norgate.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
}
