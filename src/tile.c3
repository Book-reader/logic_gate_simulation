module electronics_game::tile;

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
  // TODO: GameEvents without a target are handled in the main loop and can do other things
  usz target_id;
  // TODO: some sort of data union for event specific data
  // This would be used to say which component is being removed when CONNECTED_COMPONENT_REMOVED
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
  uptr ptr;
  Point pos;
}

struct Input
{
  usz parent_id;
  bool* on;
}

// TODO: Input should hold a pointer to Output and vice-versa

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

  fn void recalculate_state();
  fn ComponentType get_type();

  // TODO: replace get_color with draw() for drawing more complex shapes defined by the Component itself
  fn Color get_color();
  fn Point get_pos();
  fn usz get_id();

  // todo: some sort of rotation, this may not be needed.
  // It would also likely be really complex to implement and update
  // fn Rotation get_rotation();
  // Rotation being an enum
}

enum ComponentType
{
  SWITCH,
  BULB
}


/*
 *
 *
 *
 * Switch definition
 *
 *
 *
*/
const Point SWITCH_SIZE = {20, 20};

fn Switch new_switch(EventQueue* event_queue, Point pos, usz id)
{
  return {{false, {0, 1}, 0}, event_queue, SWITCH_SIZE, SWITCH, pos, id};
}

struct Switch (Component)
{
  Output main_output;
  EventQueue* event_queue;
  Point size;
  ComponentType type;
  Point pos;
  usz id;
}

fn void Switch.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case PRESSED:
      self.main_output.on = !self.main_output.on;
      if (self.main_output.connected_id != 0)
      {
        self.event_queue.push({POWER_STATE_CHANGE, self.main_output.connected_id, {}});
      }
      else
      {
        io::printfn("not connected to anything");
      }
      self.recalculate_state();
    default:
  }
}

import std::collections::list;

fn Output*[] Switch.get_outputs(&self) @dynamic
{
  // FIXME: this leaks memory
  List(<Output*>) o;
  o.new_init();
  o.push(&self.main_output);
  return o.array_view();
}

fn Input*[] Switch.get_inputs(&self) @dynamic
{
  return {};
}

fn Point Switch.get_size(&self) @dynamic
{
  return self.size;
}

fn void Switch.recalculate_state(&self) @dynamic
{
  // This is not used because the only state a switch has is its output, which only changes on press
}

fn ComponentType Switch.get_type(&self) @dynamic
{
  return self.type;
}

fn Color Switch.get_color(&self) @dynamic
{
  // fun compiler SIGSEV in c3 0.6.3
  return self.main_output.on ? {0xcc, 0x00, 0x00, 0xff} : {0xff, 0x00, 0x00, 0xff};
}

fn Point Switch.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Switch.get_id(&self) @dynamic
{
  return self.id;
}

/*
 *
 *
 *
 * Bulb definition
 *
 *
 *
*/
const Point BULB_SIZE = {20, 20};

fn Bulb new_bulb(EventQueue* event_queue, Point pos, usz id)
{
  return {{id, null}, event_queue, BULB_SIZE, false, BULB, pos, id};
}

struct Bulb (Component)
{
  Input main_input;
  EventQueue* event_queue;
  Point size;
  bool on;
  ComponentType type;
  Point pos;
  usz id;
}

fn void Bulb.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case POWER_STATE_CHANGE:
      self.recalculate_state();
    case CONNECTED_COMPONENT_REMOVED:
      self.main_input.on = null;
      self.recalculate_state();
    case PRESSED:
  }
}

fn Output*[] Bulb.get_outputs(&self) @dynamic
{
  return {};
}

fn Input*[] Bulb.get_inputs(&self) @dynamic
{
  // return {&self.main_input};
  // FIXME: this leaks memory
  List(<Input*>) i;
  i.new_init();
  i.push(&self.main_input);
  return i.array_view();
}

fn Point Bulb.get_size(&self) @dynamic
{
  return self.size;
}

fn void Bulb.recalculate_state(&self) @dynamic
{
  if (self.main_input.on != null)
  {
    self.on = *self.main_input.on;
  }
  else
  {
    self.on = false;
  }
}

fn ComponentType Bulb.get_type(&self) @dynamic
{
  return self.type;
}

fn Color Bulb.get_color(&self) @dynamic
{
  return self.on ? {0xff, 0x00, 0xff, 0xff} : {0x00, 0x00, 0x00, 0xff};
}

fn Point Bulb.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Bulb.get_id(&self) @dynamic
{
  return self.id;
}
