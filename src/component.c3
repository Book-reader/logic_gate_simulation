module logic_gate_simulation::component;

import logic_gate_simulation::queue;

//import sdl2;

import std::io;

def Point = int[<2>];
def EventQueue = Queue(<GameEvent>);

fn uint int[<2>].hash(&self)
{
  return (self.x.hash() * self.y.hash()).hash();
}

struct GameEvent
{
  EventType type;
  usz target_id;
  EventData data;
}

fn GameEvent power_change_event(usz target_id)
{
  return {POWER_STATE_CHANGE, target_id, {}};
}

fn GameEvent connected_removed_event(usz own_id, usz target_id)
{
  unreachable("TODO");
  // TODO
  // return {CONNECTED_COMPONENT_REMOVED, own_id};
}

fn GameEvent pressed_event(usz target_id, Point relative_coords)
{
  return {PRESSED, target_id, {.pos = relative_coords}};
}

enum EventType
{
  POWER_STATE_CHANGE,
  CONNECTED_COMPONENT_REMOVED,
  // TODO
  // COMPONENT_CONNECTED,
  PRESSED
}

union EventData
{
  usz id;
  uptr ptr;
  Point pos;
}

struct Input
{
  usz parent_id;
  bool* on;
}

struct Output
{
  bool on;
  Point position;
  usz connected_id;
}

fn void Output.connect_input(&self, Input* input)
{
  self.connected_id = input.parent_id;
  input.on = &self.on;
}

fn void Output.disconnect_input(&self, Input* input)
{
  input.on = null;
  self.connected_id = 0;
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
interface Component
{
  fn Output[] get_outputs();
  fn Input[] get_inputs();
  fn void handle_event(GameEvent* event);
  fn Point get_size();
  fn void draw();
  fn Point get_pos();
  fn usz get_id();
  fn void set_pos(Point pos);
}

// TODO: error detection
fn void connect(EventQueue* event_queue, Component* out, usz out_id, Component* in, usz in_id)
{
  out.get_outputs()[out_id].connect_input(&in.get_inputs()[in_id]);
  event_queue.push(power_change_event(in.get_id()));
}

// NOTE: IMPORTANT: the CONNECTED_COMPONENT_REMOVED event should be sent to both the input of 1 component and the output of the other component
macro void connected_removed(self, GameEvent* event)
{
  $if($defined(self.inputs)):
    foreach (&input : self.inputs)
    {
      if (input.parent_id == event.data.id)
      {
        input.on = null;
      }
    }
  $endif
  $if($defined(self.outputs)):
    foreach (&output : self.outputs)
    {
      if (output.connected_id == event.data.id)
      {
        output.connected_id = 0;
      }
    }
  $endif
}
