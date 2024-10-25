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


const PointSmall ANDGATE_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, ANDGATE_SIZE, event_queue, id, ANDGATE, {.andgate = {{component::new_input(id, {0, 0}), component::new_input(id, {ANDGATE_SIZE.x, 0})}, {component::new_output(id, {ANDGATE_SIZE.x / 2, ANDGATE_SIZE.y}, false)}}}};
}

struct Andgate
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
    case COMPONENT_REMOVED:
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
  if (self.inputs[0].out != null && self.inputs[1].out != null)
  {
    bool tmp = self.outputs[0].on;
    self.outputs[0].on = self.inputs[0].out.on && self.inputs[1].out.on;
    if (tmp != self.outputs[0].on && self.outputs[0].in != null)
    {
      event_queue.push(component::power_change_event(self.outputs[0].in.parent_id));
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
}
