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

  // todo: some sort of rotation, this may not be needed.
  // It would also likely be really complex to implement and update
  // fn Rotation get_rotation();
  // Rotation being an enum
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
  return {{false, {0, 1}, 0}, event_queue, SWITCH_SIZE, pos, id};
}

struct Switch (Component)
{
  Output main_output;
  EventQueue* event_queue;
  Point size;
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
    default:
  }
}

import std::collections::list;

fn Output*[] Switch.get_outputs(&self) @dynamic
{
  // return {&self.main_output};
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

fn void Switch.draw(&self, SDLRenderer renderer, Point offset) @dynamic
{
  // fun compiler SIGSEV in c3 0.6.3
  sdl2::set_draw_color(renderer, self.main_output.on ? {0xcc, 0x00, 0x00, 0xff} : {0xff, 0x00, 0x00, 0xff});
  sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  sdl2::draw_text(renderer, self.main_output.on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + SWITCH_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
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
  return {{id, null}, event_queue, BULB_SIZE, false, pos, id};
}

struct Bulb (Component)
{
  Input main_input;
  EventQueue* event_queue;
  Point size;
  bool on;
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
      break;
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
  List(<Input*>) o;
  o.new_init();
  o.push(&self.main_input);
  return o.array_view();
}

fn Point Bulb.get_size(&self) @dynamic
{
  return self.size;
}

fn void Bulb.recalculate_state(&self)
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

fn void Bulb.draw(&self, SDLRenderer renderer, Point offset) @dynamic
{
  sdl2::set_draw_color(renderer, self.on ? {0xff, 0x00, 0xff, 0xff} : {0x00, 0x00, 0x00, 0xff});
  sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  sdl2::draw_text(renderer, self.on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + SWITCH_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0xff, 0xff, 0xff, 0xff});
}

fn Point Bulb.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz Bulb.get_id(&self) @dynamic
{
  return self.id;
}


/*
 *
 *
 *
 * AndGate definition
 *
 *
 *
*/
const Point ANDGATE_SIZE = {20, 20};

fn AndGate new_andgate(EventQueue* event_queue, Point pos, usz id)
{
  return {{id, null}, {id, null}, {false, {0, 1}, 0}, event_queue, ANDGATE_SIZE, pos, id};
}

struct AndGate (Component)
{
  Input left_input;
  Input right_input;
  Output main_output;
  EventQueue* event_queue;
  Point size;
  Point pos;
  usz id;
}

fn void AndGate.handle_event(&self, GameEvent* event) @dynamic
{
  switch (event.type)
  {
    case PRESSED:
      break;
    case CONNECTED_COMPONENT_REMOVED:
      if (self.left_input.parent_id == event.data.id)
      {
        self.left_input.parent_id = 0;
      }
      if (self.right_input.parent_id == event.data.id)
      {
        self.right_input.parent_id = 0;
      }
      nextcase;
    case POWER_STATE_CHANGE:
      self.recalculate_state();
  }
}

fn Output*[] AndGate.get_outputs(&self) @dynamic
{
  // return {&self.main_output};
  List(<Output*>) o;
  o.new_init();
  o.push(&self.main_output);
  return o.array_view();
}

fn Input*[] AndGate.get_inputs(&self) @dynamic
{
  // return {&self.left_input, &self.right_input};
  List(<Input*>) o;
  o.new_init();
  o.push(&self.left_input);
  o.push(&self.right_input);
  return o.array_view();
}

fn Point AndGate.get_size(&self) @dynamic
{
  return self.size;
}

fn void AndGate.recalculate_state(&self)
{
  if (self.left_input.on != null && self.right_input.on != null)
  {
    bool tmp = self.main_output.on;
    self.main_output.on = *self.left_input.on && *self.right_input.on;
    if (tmp != self.main_output.on)
    {
      self.event_queue.push({POWER_STATE_CHANGE, self.main_output.connected_id, {}});
    }
  }
  else
  {
    self.main_output.on = false;
  }
}

fn void AndGate.draw(&self, SDLRenderer renderer, Point offset) @dynamic
{
  sdl2::set_draw_color(renderer, self.main_output.on ? {0x99, 0xff, 0x99, 0xff} : {0xff, 0x99, 0x99, 0xff});
  sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  sdl2::draw_text(renderer, self.main_output.on ? (ZString)"1\0" : (ZString)"0\0", {self.pos.x + SWITCH_SIZE.x / 4 - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});
}

fn Point AndGate.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz AndGate.get_id(&self) @dynamic
{
  return self.id;
}
