module logic_gate_simulation::component::bulb;
/*
 *
 *
 *
 * Bulb definition
 *
 *
 *
*/
import raylib5::rl;



const Point BULB_SIZE = {20, 20};

fn Component new(EventQueue* event_queue, Point pos, Id id)
{
  return {pos, BULB_SIZE, event_queue, id, BULB, {.bulb = {{component::new_input(id, {BULB_SIZE.x / 2 - component::INPUT_SIZE.x / 2, (- BULB_SIZE.y / 4)})}, false}}};
}

struct Bulb
{
  Input[1] inputs;
  bool on;
}

fn void Bulb.handle_event(&self, GameEvent* event, EventQueue* event_queue)
{
  switch (event.type)
  {
    case POWER_STATE_CHANGE:
      self.recalculate_state();
    case COMPONENT_REMOVED:
      component::connected_removed(self, event);
    case PRESSED:
      break;
  }
}

fn Output[] Bulb.get_outputs(&self)
{
  return {};
}

fn Input[] Bulb.get_inputs(&self)
{
  return &self.inputs;
}

fn void Bulb.recalculate_state(&self)
{
  if (self.inputs[0].out != null)
  {
    self.on = self.inputs[0].out.on;
  }
  else
  {
    self.on = false;
  }
}

fn void Bulb.draw(&self, Point pos, Point size)
{
  rl::drawRectangle(...pos, ...size, self.on ? {0xff, 0x00, 0xff, 0xff} : {0x00, 0x00, 0x00, 0xff});
  rl::drawText(self.on ? (ZString) "1" : (ZString) "0", ...pos + {4, 0}, 24, self.on ? {0x00, 0x00, 0x00, 0xff} : {0xff, 0xff, 0xff, 0xff});
}
