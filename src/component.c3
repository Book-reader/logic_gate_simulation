module logic_gate_simulation::component;

import logic_gate_simulation::queue;

const PointSmall INPUT_SIZE = {5, 5};
const PointSmall OUTPUT_SIZE = {5, 5};

def Point = int[<2>];
def PointSmall = short[<2>];
def EventQueue = Queue(<GameEvent>);
def OpId = char;
def Id = uint;

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

fn Input new_input(PointSmall pos)
{
  return {0, 0, pos};
}

fn Output new_output(PointSmall pos, bool on)
{
  return {on, pos};
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

// Implement recalculate_state, draw, and handle_event manually
def RecalculateStateFn = fn void (Component*);
def DrawFn = fn void (Component*);
def HandleEventFn = fn void (Component*, GameEvent*);

struct Component
{
  Input[] inputs;
  Output[] outputs;
  Point pos;
  PointSmall size;
  Id id;
  // Only really used for BULB
  bool on;
  RecalculateStateFn recalculate_state_fn;
  DrawFn draw_fn;
  HandleEventFn handle_event_fn;
}


fn void Component.recalculate_state(&self)
{
  self.recalculate_state_fn(self);
}

fn void Component.handle_event(&self, GameEvent* event)
{
  self.handle_event_fn(self, event);
}

fn void Component.draw(&self)
{
  self.draw_fn(self);
}

fn Point Component.get_pos(&self)
{
  return self.pos;
}

fn PointSmall Component.get_size(&self)
{
  return self.size;
}

fn Input[] Component.get_inputs(&self)
{
  return self.inputs;
}

fn Output[] Component.get_outputs(&self)
{
  return self.outputs;
}

fn Id Component.get_id(&self)
{
  return self.id;
}

fn void Component.set_pos(&self, Point pos)
{
  self.pos = pos;
}

fn void Component.free(&self)
{
  if (self.inputs.len != 0)
  {
    mem::free(self.inputs);
  }
  if (self.outputs.len != 0)
  {
    mem::free(self.outputs);
  }
}

macro void Component.new_init(&self, Point pos, PointSmall $size, Id id, usz $input_num, usz $output_num, RecalculateStateFn recalculate_state_fn, DrawFn draw_fn, HandleEventFn handle_event_fn)
{
  self.pos = pos;
  self.size = $size;
  self.id = id;
  $if ($input_num > 0):
    self.inputs = mem::new_array(Input, $input_num);
  $else
    self.inputs = {};
  $endif
  $if ($output_num > 0):
    self.outputs = mem::new_array(Output, $output_num);
  $else
    self.outputs = {};
  $endif
  self.recalculate_state_fn = recalculate_state_fn;
  self.draw_fn = draw_fn;
  self.handle_event_fn = handle_event_fn;
}
