module logic_gate_simulation::component::splitter;
/*
 *
 *
 *
 * Splitter definition
 *
 *
 *
*/
import raylib5;


const PointSmall SPLITTER_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, SPLITTER_SIZE, event_queue, id, SPLITTER, {.splitter = {{component::new_input(id, {SPLITTER_SIZE.x / 2, -component::INPUT_SIZE.y})}, {component::new_output(id, {-component::INPUT_SIZE.x, SPLITTER_SIZE.y / 2}, false), component::new_output(id, {SPLITTER_SIZE.x, SPLITTER_SIZE.y / 2}, false), component::new_output(id, {SPLITTER_SIZE.x / 2, SPLITTER_SIZE.y}, false)}}}};
}

struct Splitter
{
  Input[1] inputs;
  Output[3] outputs;
}

fn void Splitter.handle_event(&self, GameEvent* event, EventQueue* event_queue)
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

fn Output[] Splitter.get_outputs(&self)
{
  return &self.outputs;
}

fn Input[] Splitter.get_inputs(&self)
{
  return &self.inputs;
}

fn void Splitter.recalculate_state(&self, EventQueue* event_queue) @private
{
  bool old = self.outputs[0].on;
  component::@input_state(self; bool[] state)
  {
    foreach (&output : self.outputs)
    {
      output.on = state[0];
    }
  };
  // if (old != self.outputs[0].on && self.outputs[0].in != null)
  // {
  foreach (&output : self.outputs)
  {
    if (output.in != null)
    {
      event_queue.push(component::power_change_event(output.in.parent_id));
    }
  }
  // }
}

fn void Splitter.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.outputs[0].on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  rl::drawText(self.outputs[0].on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, rl::BLACK);
}
