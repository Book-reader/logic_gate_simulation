module logic_gate_simulation::components;

import logic_gate_simulation::component;

import raylib5;

import std::io;

const DEBUG = false;
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
  new.new_init(LEVER, pos, {20, 20}, id, 0, 1, {}, {BOTTOM_MIDDLE}, &lever_recalculate_state, &lever_draw, &lever_handle_event);
  return new;
}

fn void lever_recalculate_state(Component* self)
{}

fn void lever_handle_event(Component* self, GameEvent* event)
{
  switch (event.type)
  {
    case PRESSED:
      self.outputs[0].on = !self.outputs[0].on;
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
      nextcase;
    default:
      $if (DEBUG):
        io::printfn("%s id %s recived event %s", $$FUNC.split("_")[0], self.id, event.type);
      $endif
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
  new.new_init(BULB, pos, {20, 20}, id, 1, 0, {TOP_MIDDLE}, {}, &bulb_recalculate_state, &bulb_draw, &bulb_handle_event);
  return new;
}

fn void bulb_recalculate_state(Component* self)
{
  self.@input_state(; bool[] inputs)
  {
    self.on = inputs[0];
  };
}


fn void bulb_handle_event(Component* self, GameEvent* event)
{
  switch (event.type)
  {
    case POWER_STATE_CHANGE:
    case COMPONENT_DISCONNECTED:
      self.recalculate_state();
      nextcase;
    default:
      $if (DEBUG):
        io::printfn("%s id %s recived event %s", $$FUNC.split("_")[0], self.id, event.type);
      $endif
      // io::printfn("%s id %s recived event %s", $$FUNC.split(".")[0], self.id, event.type);
  }

}

fn void bulb_draw(Component* self)
{
  rl::drawRectangle(...self.pos, ...self.get_size(), self.on ? rl::PURPLE : rl::BLACK);
}


/*
 *
 *
 * Gates Declaration
 *
 *
*/
fn Component andgate(Point pos, Id id)
{
  Component new;
  new.new_init(AND, pos, {20, 20}, id, 2, 1, {TOP_LEFT, TOP_RIGHT}, {BOTTOM_MIDDLE}, &and_recalculate_state, &logic_draw, &logic_handle_event);
  return new;
}

fn Component nandgate(Point pos, Id id)
{
  Component new;
  new.new_init(NAND, pos, {20, 20}, id, 2, 1, {TOP_LEFT, TOP_RIGHT}, {BOTTOM_MIDDLE}, &nand_recalculate_state, &logic_draw, &logic_handle_event);
  return new;
}

fn Component orgate(Point pos, Id id)
{
  Component new;
  new.new_init(OR, pos, {20, 20}, id, 2, 1, {TOP_LEFT, TOP_RIGHT}, {BOTTOM_MIDDLE}, &or_recalculate_state, &logic_draw, &logic_handle_event);
  return new;
}

fn Component norgate(Point pos, Id id)
{
  Component new;
  new.new_init(NOR, pos, {20, 20}, id, 2, 1, {TOP_LEFT, TOP_RIGHT}, {BOTTOM_MIDDLE}, &nor_recalculate_state, &logic_draw, &logic_handle_event);
  return new;
}

fn Component xorgate(Point pos, Id id)
{
  Component new;
  new.new_init(XOR, pos, {20, 20}, id, 2, 1, {TOP_LEFT, TOP_RIGHT}, {BOTTOM_MIDDLE}, &xor_recalculate_state, &logic_draw, &logic_handle_event);
  return new;
}

fn Component xnorgate(Point pos, Id id)
{
  Component new;
  new.new_init(XNOR, pos, {20, 20}, id, 2, 1, {TOP_LEFT, TOP_RIGHT}, {BOTTOM_MIDDLE}, &xnor_recalculate_state, &logic_draw, &logic_handle_event);
  return new;
}


fn void and_recalculate_state(Component* self)
{
  self.@input_state(; bool[] inputs)
  {
    bool old = self.outputs[0].on;
    self.outputs[0].on = inputs[0] && inputs[1];
    if (old != self.outputs[0].on)
    {
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
    }
  };
}

fn void nand_recalculate_state(Component* self)
{
  self.@input_state(; bool[] inputs)
  {
    bool old = self.outputs[0].on;
    self.outputs[0].on = !(inputs[0] && inputs[1]);
    if (old != self.outputs[0].on)
    {
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
    }
  };
}

fn void or_recalculate_state(Component* self)
{
  self.@input_state(; bool[] inputs)
  {
    bool old = self.outputs[0].on;
    self.outputs[0].on = inputs[0] || inputs[1];
    if (old != self.outputs[0].on)
    {
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
    }
  };
}

fn void nor_recalculate_state(Component* self)
{
  self.@input_state(; bool[] inputs)
  {
    bool old = self.outputs[0].on;
    self.outputs[0].on = !(inputs[0] || inputs[1]);
    if (old != self.outputs[0].on)
    {
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
    }
  };
}

fn void xor_recalculate_state(Component* self)
{
  self.@input_state(; bool[] inputs)
  {
    bool old = self.outputs[0].on;
    self.outputs[0].on = (inputs[0] && !inputs[1]) || (!inputs[0] && inputs[1]);
    if (old != self.outputs[0].on)
    {
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
    }
  };
}

fn void xnor_recalculate_state(Component* self)
{
  self.@input_state(; bool[] inputs)
  {
    bool old = self.outputs[0].on;
    self.outputs[0].on = !((inputs[0] && !inputs[1]) || (!inputs[0] && inputs[1]));
    if (old != self.outputs[0].on)
    {
      logic_gate_simulation::event_queue.push(component::power_change_event(self.id));
    }
  };
}

fn void logic_handle_event(Component* self, GameEvent* event)
{
  switch (event.type)
  {
    case POWER_STATE_CHANGE:
    case COMPONENT_DISCONNECTED:
      self.recalculate_state();
    default:
      $if (DEBUG):
        io::printfn("%s id %s recived event %s", $$FUNC.split("_")[0], self.id, event.type);
      $endif
  }

}

fn void logic_draw(Component* self)
{
  rl::drawRectangle(...self.pos, ...self.get_size(), self.outputs[0].on ? rl::PURPLE : rl::BLUE);
}
