module electronics_game::component;

import electronics_game::queue;
import electronics_game::sdl2;

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

enum EventType
{
  POWER_STATE_CHANGE,
  CONNECTED_COMPONENT_REMOVED,
  PRESSED
}

union EventData
{
  usz id;
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
  fn void draw(SDLRenderer renderer, Point offset);
  fn Point get_pos();
  fn usz get_id();

  // TODO: some sort of rotation, this may not be needed.
  // It would also likely be really complex to implement and update
  // fn Rotation get_rotation();
  // Rotation being an enum
}
