module electronics_game::world;

import electronics_game::queue;

import std::io;

def Point = int[<2>];

fn uint int[<2>].hash(&self)
{
  return (self.x.hash() * self.y.hash()).hash();
}

struct GameEvent
{
  EventType type;
  Component* target;
  // TODO: some sort of data union for event specific data
  // GameEventData data;
}

enum EventType
{
  POWER_STATE_CHANGE,
  CONNECTED_COMPONENT_REMOVED
}

struct Input
{
  bool* on;
}

struct Output
{
  bool on;
  Point position;
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
  fn Output*[] get_outputs();
  fn Input*[] get_inputs();
  fn void handle_event(GameEvent* event);
  fn Point get_size();

  // todo: some sort of rotation, this may not be needed.
  // It would also likely be really complex to implement and update
  // fn Rotation get_rotation();
  // Rotation being an enum
}

struct Switch (Component)
{
  Output main_output;
  Queue(<GameEvent>)* event_queue;
  Point size;
}

fn void Switch.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case POWER_STATE_CHANGE:
      io::printn("Power state change, recalculating");
    case CONNECTED_COMPONENT_REMOVED:
      io::printn("Component removed, recalculating");
  }
}

fn Output*[] Switch.get_outputs(&self) @dynamic
{
  return {&self.main_output};
}

fn Input*[] Switch.get_inputs(&self) @dynamic
{
  return {};
}

fn Point Switch.get_size(&self) @dynamic
{
  return self.size;
}
