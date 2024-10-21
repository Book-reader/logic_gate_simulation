module logic_gate_simulation::component::latch;
/*
 *
 *
 *
 * Latch definition
 *
 *
 *
*/
import raylib5;


const Point LATCH_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, LATCH_SIZE, event_queue, id, LATCH, {.latch = {{component::new_input(id)}, {component::new_output(id, {0, 1}, false)}}}};
}

struct Latch
{
  Input[1] inputs;
  Output[1] outputs;
}

fn void Latch.handle_event(&self, GameEvent* event, EventQueue* event_queue)
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

fn Output[] Latch.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Latch.get_inputs(&self)
{
  return &self.inputs;
}

fn void Latch.recalculate_state(&self, EventQueue* event_queue) @private
{
  component::@input_state(self; bool[] input_state)
  {
    if (input_state[0])
    {
      self.outputs[0].on = !self.outputs[0].on;
    }
  };
  if (self.outputs[0].in != null)
  {
    event_queue.push(component::power_change_event(self.outputs[0].in.parent_id));
  }
}

fn void Latch.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
}
