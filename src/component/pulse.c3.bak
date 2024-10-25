module logic_gate_simulation::component::pulse;
/*
 *
 *
 *
 * Pulse definition
 *
 *
 *
*/
import raylib5;


const PointSmall PULSE_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, PULSE_SIZE, event_queue, id, PULSE, {.pulse = {{component::new_input(id)}, {component::new_output(id, {0, 1}, false)}, false}}};
}

struct Pulse
{
  Input[1] inputs;
  Output[1] outputs;
  bool old_state;
}

fn void Pulse.handle_event(&self, GameEvent* event, EventQueue* event_queue)
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

fn Output[] Pulse.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Pulse.get_inputs(&self)
{
  return &self.inputs;
}

fn void Pulse.recalculate_state(&self, EventQueue* event_queue) @private
{
  bool old_output = self.outputs[0].on;
  component::@input_state(self; bool[] input_state)
  {
    if (input_state[0])
    {
      self.outputs[0].on = !self.outputs[0].on;
    }
  };
  if (old_output != self.outputs[0].on && self.outputs[0].in != null)
  {
    event_queue.push(component::power_change_event(self.outputs[0].in.parent_id));
    if (!old_output)
    {
      event_queue.push(component::power_change_event(self.outputs[0].parent_id));
      old_output = false;
    }
  }
}

fn void Pulse.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
}
