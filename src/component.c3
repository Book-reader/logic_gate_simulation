module logic_gate_simulation::component;

import logic_gate_simulation::queue;

const PointSmall INPUT_SIZE = {5, 5};
const PointSmall OUTPUT_SIZE = {5, 5};

def Point = int[<2>];
def PointSmall = short[<2>];
def EventQueue = Queue(<GameEvent>);
def Id = uint;
def Splitter = splitter::Splitter;

fn uint int[<2>].hash(&self)
{
  return (self.x.hash() * self.y.hash()).hash();
}

struct GameEvent
{
  EventType type;
  Id target_id;
  EventData data;
}

fn GameEvent power_change_event(Id target_id)
{
  return {POWER_STATE_CHANGE, target_id, {}};
}

fn GameEvent removed_event(Id removed_id)
{
  return {COMPONENT_REMOVED, 0, {.id = removed_id}};
}

fn GameEvent pressed_event(Id target_id, Point relative_coords)
{
  return {PRESSED, target_id, {.pos = relative_coords}};
}

enum EventType : char
{
  POWER_STATE_CHANGE,
  COMPONENT_REMOVED,
  // TODO
  // COMPONENT_CONNECTED,
  PRESSED
}

union EventData
{
  Id id;
  // uptr ptr;
  Point pos;
}

struct Input
{
  Id parent_id;
  Output* out;
  PointSmall position;
}

struct Output
{
  bool on;
  PointSmall position;
  Input* in;
  Id parent_id;
}

fn void Output.connect_input(&self, Input* input)
{
  self.in = input;
  input.out = self;
}

fn void Output.disconnect_input(&self)
{
  self.in.out = null;
  self.in = null;
}

fn Input new_input(Id id, PointSmall pos = {0, 0})
{
  return {id, null, pos};
}

fn Output new_output(Id id, PointSmall pos, bool on)
{
  return {on, pos, null, id};
}

// TODO have some sort of relative coordinate system for the outputs and inputs
// eg:
/*
 *       0,-1
 *  -1,1 comp,1,1
 *       0, 1
 *
            */
// Store the coordinates in the inputs and outputs,
// return an array slice of them with get_inputs/outputs
// then loop through them and read the coordinates to draw them
struct Component
{
  // The things all components will have
  Point pos;
  PointSmall size;
  EventQueue* event_queue;
  Id id;
  // Functions unique to each component type (draw, handle_events, etc)
  ComponentType type;
  ComponentData data;
}

fn Point Component.get_pos(&self)
{
  return self.pos;
}

fn void Component.set_pos(&self, Point pos)
{
  self.pos = pos;
}

fn Point Component.get_size(&self)
{
  return self.size;
}

fn Id Component.get_id(&self)
{
  return self.id;
}

fn void Component.draw(&self)
{
  @execute(self, "draw", self.pos, self.size);
}

fn void Component.handle_event(&self, GameEvent* event)
{
  @execute(self, "handle_event", event, self.event_queue);
}

fn Output[] Component.get_outputs(&self)
{
  return @get(self, "outputs", Output[]{});
}

fn Input[] Component.get_inputs(&self)
{
  return @get(self, "inputs", Input[]{});
}

enum ComponentType : (String name)
{
  NONE = "none",
  BULB = "bulb",
  LEVER = "lever",
  ANDGATE = "andgate",
  ORGATE = "orgate",
  NORGATE = "norgate",
  NOTGATE = "notgate",
  XNORGATE = "xnorgate",
  XORGATE = "xorgate",
  SPLITTER = "splitter",
  LATCH = "latch",
  PULSE = "pulse"
}

union ComponentData
{
  Bulb bulb;
  Lever lever;
  Andgate andgate;
  Orgate orgate;
  Norgate norgate;
  Notgate notgate;
  Xnorgate xnorgate;
  Xorgate xorgate;
  Splitter splitter;
  Latch latch;
  Pulse pulse;
}

macro @execute(Component* component, #function_name, ...) @private
{
  $foreach ($member : ComponentType.values)
    $if ($member != NONE):
      if (component.type == $member)
      {
        return component.data.$eval($member.name).$eval(#function_name)($vasplat);
      }
    $endif
  $endforeach
}

macro @get(Component* component, #value, #if_none) @private
{
  $foreach ($member : ComponentType.values)
    $if ($member != NONE):
      if (component.type == $member)
      {
        $if ($defined(component.data.$eval($member.name).$eval(#value))):
          return &component.data.$eval($member.name).$eval(#value);
        $else
          return #if_none;
        $endif
      }
    $endif
  $endforeach
  unreachable("@get: component type not in ComponentType (impossible)");
}

macro @input_state(component_data; @body(bool[] outputs))
{
  var $Type = $typeof(component_data);
  var $type_name = "";
  // Remove the * from the type name and bring to lower to match enum value
  $if ($defined($Type.inner)):
    $type_name = $Type.inner.nameof.temp_ascii_to_lower();
  $else
    $type_name = $Type.nameof.temp_ascii_to_lower();
  $endif
  $foreach ($member : ComponentType.values)
    $if ($member != NONE):
      if ($type_name == $member.name)
      {
        $if ($defined(component_data.inputs)):
          bool[component_data.inputs.len] input_bools;
          foreach (i, op : component_data.inputs)
          {
            if (op.out != null)
            {
              input_bools[i] = op.out.on;
            }
          }
          @body(&input_bools);
        $else
          unreachable("%s has not inputs", $typeof(component_data));
        $endif
      }
    $endif
  $endforeach
}

// TODO: error detection
fn void connect(EventQueue* event_queue, Component* out, Id out_id, Component* in, Id in_id)
{
  out.get_outputs()[out_id].connect_input(&in.get_inputs()[in_id]);
  event_queue.push(power_change_event(in.get_id()));
}

macro void connected_removed(self, GameEvent* event)
{
  $if($defined(self.inputs)):
    foreach (&input : self.inputs)
    {
      if (input.out != null && input.out.parent_id == event.data.id)
      {
        input.out.disconnect_input();
      }
    }
  $endif
  $if($defined(self.outputs)):
    foreach (&output : self.outputs)
    {
      if (output.in != null && output.in.parent_id == event.data.id)
      {
        output.disconnect_input();
      }
    }
  $endif;
}
