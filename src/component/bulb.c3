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

// fn Bulb new(EventQueue* event_queue, Point pos, usz id)
// {
//   return {{{id, null}}, event_queue, BULB_SIZE, false, pos, id};
// }

fn Component new(EventQueue* event_queue, Point pos, usz id)
{
  return {pos, BULB_SIZE, event_queue, id, BULB, {.bulb = {{{id, null}}, false}}};
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
    case CONNECTED_COMPONENT_REMOVED:
      self.inputs[0].on = null;
      self.recalculate_state();
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
  if (self.inputs[0].on != null)
  {
    self.on = *self.inputs[0].on;
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
