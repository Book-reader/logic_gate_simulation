module logic_gate_simulation::components;

import logic_gate_simulation::component;
import logic_gate_simulation::generic_component;

import raylib5;

import std::io;


/*
 *
 *
 * Lever Declaration
 *
 *
*/
def Lever = GenericComponent(<0, 1, 20, 20>);
fn void Lever.recalculate_state(&self) @dynamic
{
  unimplemented();
}

fn void Lever.handle_event(&self, GameEvent* event) @dynamic
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

fn void Lever.draw(&self) @dynamic
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
def Bulb = GenericComponent(<1, 0, 20, 20>);

fn void Bulb.recalculate_state(&self) @dynamic
{
  unimplemented();
}


fn void Bulb.handle_event(&self, GameEvent* event) @dynamic
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

fn void Bulb.draw(&self) @dynamic
{
  rl::drawRectangle(...self.pos, ...self.get_size(), self.on ? rl::PURPLE : rl::BLACK);
}
