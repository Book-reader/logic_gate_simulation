module logic_gate_simulation::component;

import logic_gate_simulation::queue;
import logic_gate_simulation::main;
import raylib5;

const PointSmall INPUT_SIZE = {4, 4};
const PointSmall OUTPUT_SIZE = {4, 4};

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

fn GameEvent removed_event(Id target_id)
{
  return {COMPONENT_REMOVED, 0, {.id = target_id}};
}

fn GameEvent component_disconnected_event(Id target_id)
{
  return {COMPONENT_DISCONNECTED, 0, {.id = target_id}};
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
  COMPONENT_DISCONNECTED,
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
  Anchor anchor;
}

fn void Input.draw(&self, Component* parent)
{
  rl::drawRectangle(...(self.get_pos(parent) - 1), ...INPUT_SIZE + 2, rl::BLACK);
  rl::drawRectangle(...(self.get_pos(parent)), ...INPUT_SIZE, rl::GREEN);
}

fn Point Input.get_pos(&self, Component* parent, bool relative = false)
{
  return self.anchor.apply_anchor(parent.get_pos(), parent.get_size(), INPUT_SIZE, relative);
}

struct Output
{
  bool on;
  Anchor anchor;
}

fn void Output.draw(&self, Component* parent)
{
  rl::drawRectangle(...(self.get_pos(parent) - 1), ...OUTPUT_SIZE + 2, rl::BLACK);
  rl::drawRectangle(...(self.get_pos(parent)), ...OUTPUT_SIZE, rl::YELLOW);
}

fn Point Output.get_pos(&self, Component* parent, bool relative = false)
{
  return self.anchor.apply_anchor(parent.get_pos(), parent.get_size(), OUTPUT_SIZE, relative);
}

enum Anchor : char
{
  TOP_LEFT,
  TOP_MIDDLE,
  TOP_RIGHT,
  CENTER_LEFT,
  CENTER_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_MIDDLE,
  BOTTOM_RIGHT
}

macro Point Anchor.apply_anchor(self, Point parent_pos, Point parent_size, Point $size, bool relative = false)
{
  Point pos;
  switch (self)
  {
    case TOP_LEFT:
      pos = parent_pos;
    case TOP_MIDDLE:
      pos = {parent_pos.x + parent_size.x / 2 - $size.x / 2, parent_pos.y};
    case TOP_RIGHT:
      pos = {parent_pos.x + parent_size.x - $size.x, parent_pos.y};
    case CENTER_LEFT:
      pos = {parent_pos.x, parent_pos.y / 2 - $size.y / 2};
    case CENTER_RIGHT:
      pos = {parent_pos.x + parent_size.x - $size.x, parent_pos.y / 2 - $size.y / 2};
    case BOTTOM_LEFT:
      pos = {parent_pos.x, parent_size.y + parent_pos.y - $size.y};
    case BOTTOM_MIDDLE:
      pos = {parent_pos.x + parent_size.x / 2 - $size.x / 2, parent_size.y + parent_pos.y - $size.y};
    case BOTTOM_RIGHT:
      pos = {parent_pos.x + parent_size.x - $size.x, parent_size.y + parent_pos.y - $size.y};
  }
  if (relative)
  {
    pos -= parent_pos;
  }
  return pos;
}


fn Input new_input(Anchor anchor)
{
  return {0, 0, anchor};
}

fn Output new_output(Anchor anchor, bool on)
{
  return {on, anchor};
}

fn void connect(Component* emitter, OpId output_idx, Component* listener, OpId input_idx)
{
  main::event_manager_mutex.lock()!!;
  main::event_manager.register(listener.get_id(), emitter.get_id());
  main::event_manager_mutex.unlock()!!;
  listener.get_inputs()[input_idx].connected_id = emitter.get_id();
  listener.get_inputs()[input_idx].output_idx = output_idx;
  main::event_queue.push(power_change_event(emitter.get_id()));
}

fn void disconnect(Component* emitter, Component* listener, OpId input_idx)
{
  main::event_manager_mutex.lock()!!;
  main::event_manager.deregister(listener.get_id(), emitter.get_id());
  main::event_manager_mutex.unlock()!!;
  listener.get_inputs()[input_idx].connected_id = 0;
  main::event_queue.push(component_disconnected_event(listener.get_id()));
  listener.get_inputs()[input_idx].output_idx = 0;
}

fn bool output_state(Id component_id, OpId output_idx)
{
  return main::world.get_ref(component_id)!!.get_outputs()[output_idx].on;
}

// Implement recalculate_state, draw, and handle_event manually
def RecalculateStateFn = fn void (Component*);
def DrawFn = fn void (Component*);
def HandleEventFn = fn void (Component*, GameEvent*);

enum ComponentType : char (String builder_name)
{
  LEVER = "lever",
  BULB = "bulb",
  AND = "andgate",
  NAND = "nandgate",
  OR = "orgate",
  NOR = "norgate",
  XOR = "xorgate",
  XNOR = "xnorgate"
}

struct Component
{
  ComponentType type;
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

fn ComponentType Component.get_type(&self)
{
  return self.type;
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

macro Component.@input_state(&self; @body(bool[] outputs))
{
  bool[] input_bools = mem::temp_new_array(bool, self.inputs.len);
  foreach (i, op : &self.inputs)
  {
    if (op.connected_id != 0)
    {
      input_bools[i] = main::world.get_ref(op.connected_id)!!.get_outputs()[op.output_idx].on;
    }
  }
  @body(input_bools);
}

macro void Component.new_init(&self, ComponentType type, Point pos, PointSmall $size, Id id, usz $input_num, usz $output_num, Anchor[] $input_anchors, Anchor[] $output_anchors, RecalculateStateFn recalculate_state_fn, DrawFn draw_fn, HandleEventFn handle_event_fn)
{
  self.type = type;
  self.pos = pos;
  self.size = $size;
  self.id = id;

  usz $idx = 0;

  $if ($input_num > 0):
    self.inputs = mem::new_array(Input, $input_num);
    $for (var $i = 0; $i < $input_num; $i++)
      self.inputs[$i].anchor = $input_anchors[$i];
      $idx++;
    $endfor
  $else
    self.inputs = {};
  $endif

  $if ($output_num > 0):
    self.outputs = mem::new_array(Output, $output_num);
    $for (var $i = 0; $i < $output_num; $i++)
      self.outputs[$i].anchor = $output_anchors[$i];
      $idx++;
    $endfor
  $else
    self.outputs = {};
  $endif

  self.recalculate_state_fn = recalculate_state_fn;
  self.draw_fn = draw_fn;
  self.handle_event_fn = handle_event_fn;

  self.recalculate_state();
}

// TODO: serialize and deserialize connections
import logic_gate_simulation::components;
fn Component deserialize(String data)
{
  String[] data_split = data.split(",");

  $foreach ($member : ComponentType.values)
    if ($member.nameof == data_split[0])
    {
      Component new = $eval("components::" +++ $member.builder_name)({data_split[1].to_integer($evaltype(PointSmall.inner.nameof))!!, data_split[2].to_integer($evaltype(PointSmall.inner.nameof))!!}, data_split[3].to_integer(Id)!!);
      main::id_counter = new.get_id();
      return new;
    }
  $endforeach
  unreachable("Failed to deserialize %s", data);
}

fn String Component.serialize(&self)
{
  DString format;
  format.new_init();
  defer format.free();
  format.appendf("%s,%s,%s,%s", self.type, ...self.pos, self.id);
  return format.copy_str();
}
