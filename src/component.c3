module logic_gate_simulation::component;

import logic_gate_simulation::queue;

const PointSmall INPUT_SIZE = {5, 5};
const PointSmall OUTPUT_SIZE = {5, 5};

def Point = int[<2>];
def PointSmall = short[<2>];
def EventQueue = Queue(<GameEvent>);
def OpId = char;
def Id = uint;
// def Splitter = splitter::Splitter;

macro unimplemented() @builtin
{
  unreachable("Not implemented yet: %s", $$FUNC);
}

fn uint int[<2>].hash(&self)
{
  return (self.x.hash() * self.y.hash()).hash();
}

struct GameEvent
{
  EventType type;
  Id source_id;
  EventData data;
}

fn GameEvent power_change_event(Id source_id)
{
  return {POWER_STATE_CHANGE, source_id, {}};
}

fn GameEvent removed_event(Id source_id)
{
  return {COMPONENT_REMOVED, source_id, {}};
}

fn GameEvent pressed_event(Id target_id, Point relative_coords)
{
  return {PRESSED, 0, {.id = target_id, .pos = relative_coords}};
}

enum EventType : char
{
  POWER_STATE_CHANGE,
  COMPONENT_REMOVED,
  // TODO
  // COMPONENT_CONNECTED,
  PRESSED
}

struct EventData
{
  Id id;
  // uptr ptr;
  Point pos;
}

struct Input
{
  Id connected_id;
  OpId output_idx;
  PointSmall position;
}

struct Output
{
  bool on;
  PointSmall position;
}

fn void Output.connect_input(&self, Input* input)
{
  unimplemented();
  // self.in = input;
  // input.out = self;
}

fn void Output.disconnect_input(&self)
{
  unimplemented();
  // self.in.out = null;
  // self.in = null;
}

fn Input new_input(PointSmall pos)
{
  return {0, 0, pos};
}

fn Output new_output(PointSmall pos, bool on)
{
  return {on, pos};
}

/* TODO: have some sort of modular component system with generics & interfaces.
 * I would likely need to use macros to automatically generate lists that store every created component then automatically add a reference to them to the world map
 *
 * def AndGate = Component(<NUM_INPUTS, NUM_OUTPUTS, &and_gate_state_calculate_fn>);
*/
interface Component
{
  fn Point get_pos();
  fn PointSmall get_size();
  fn Input[] get_inputs();
  fn Output[] get_outputs();
  fn Id get_id();

  fn void set_pos(Point pos);
  fn void recalculate_state();
  fn void handle_event(GameEvent* event);
  fn void draw();
}

fn void connect(Component* from, OpId output_idx, Component* to, OpId input_idx)
{
  logic_gate_simulation::event_manager_mutex.lock()!!;
  logic_gate_simulation::event_manager.register(to.get_id(), from.get_id());
  logic_gate_simulation::event_manager_mutex.unlock()!!;
  to.get_inputs()[input_idx].connected_id = from.get_id();
  to.get_inputs()[input_idx].output_idx = output_idx;
}

fn void disconnect(Component* from, Component* to, OpId input_idx)
{
  logic_gate_simulation::event_manager_mutex.lock()!!;
  logic_gate_simulation::event_manager.deregister(to.get_id(), from.get_id());
  logic_gate_simulation::event_manager_mutex.unlock()!!;
  to.get_inputs()[input_idx].connected_id = 0;
  to.get_inputs()[input_idx].output_idx = 0;
}

fn bool output_state(Id component_id, OpId output_idx)
{
  return logic_gate_simulation::world.get_ref(component_id)!!.get_outputs()[output_idx].on;
}

module logic_gate_simulation::generic_component(<INPUT_COUNT, OUTPUT_COUNT, WIDTH, HEIGHT>);

import logic_gate_simulation::component;

// Implement recalculate_state, draw, and handle_event manually

struct GenericComponent (Component)
{
  Input[INPUT_COUNT] inputs @if(INPUT_COUNT > 0);
  Output[OUTPUT_COUNT] outputs @if(OUTPUT_COUNT > 0);
  Point pos;
  Id id;
  // Only really used for BULB
  bool on @if(OUTPUT_COUNT == 0);
}

fn Point GenericComponent.get_pos(&self) @dynamic
{
  return self.pos;
}

fn PointSmall GenericComponent.get_size(&self) @dynamic
{
  return {WIDTH, HEIGHT};
}

fn Input[] GenericComponent.get_inputs(&self) @dynamic
{
  $if ($defined (self.inputs)):
    return &self.inputs;
  $else
    return {};
  $endif
}

fn Output[] GenericComponent.get_outputs(&self) @dynamic
{
  $if ($defined (self.outputs)):
    return &self.outputs;
  $else
    return {};
  $endif
}

fn Id GenericComponent.get_id(&self) @dynamic
{
  return self.id;
}

fn void GenericComponent.set_pos(&self, Point pos) @dynamic
{
  self.pos = pos;
}

fn GenericComponent GenericComponent.new(self, Point pos, Id id)
{
  GenericComponent new;
  $if ($defined (self.inputs)):
    foreach (&input : self.inputs)
    {
      *input = component::new_input({0, 0});
    }
  $endif
  $if ($defined (self.outputs)):
    foreach (&output : self.outputs)
    {
      *output = component::new_output({0, 0}, false);
    }
  $endif
  new.pos = pos;
  new.id = id;
  return new;
}
