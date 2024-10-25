module logic_gate_simulation::components;

import logic_gate_simulation::component;

import raylib5;

import std::io;


/*
 *
 *
 * Lever Declaration
 *
 *
*/
fn Component lever(Point pos, Id id)
{
  Component new;
  new.new_init(pos, {20, 20}, id, 0, 1, &lever_recalculate_state, &lever_draw, &lever_handle_event);
  return new;
}

fn void lever_recalculate_state(Component* self)
{
  unimplemented();
}

fn void lever_handle_event(Component* self, GameEvent* event)
{
  switch (event.type)
  {
    case PRESSED:
      self.outputs[0].on = !self.outputs[0].on;
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
      nextcase;
    default:
      // io::printfn("%s id %s recived event %s", $$FUNC.split(".")[0], self.id, event.type);
  }
}

fn void lever_draw(Component* self)
{
  rl::drawRectangle(...self.pos, ...self.get_size(), self.outputs[0].on ? {255, 0, 0, 255} : {150, 0, 0, 255});
}


/*
 *
 *
 * Bulb Declaration
 *
 *
*/
fn Component bulb(Point pos, Id id)
{
  Component new;
  new.new_init(pos, {20, 20}, id, 1, 0, &bulb_recalculate_state, &bulb_draw, &bulb_handle_event);
  return new;
}

fn void bulb_recalculate_state(Component* self)
{
  unimplemented();
}


fn void bulb_handle_event(Component* self, GameEvent* event)
{
  switch (event.type)
  {
    case POWER_STATE_CHANGE:
      if (self.inputs[0].connected_id != 0)
      {
        self.on = component::output_state(self.inputs[0].connected_id, self.inputs[0].output_idx);
      }
      else
      {
        self.on = false;
      }
      nextcase;
    default:
      // io::printfn("%s id %s recived event %s", $$FUNC.split(".")[0], self.id, event.type);
  }

}

fn void bulb_draw(Component* self)
{
  rl::drawRectangle(...self.pos, ...self.get_size(), self.on ? rl::PURPLE : rl::BLACK);
}
