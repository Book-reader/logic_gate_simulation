module electronics_game::world;

import std::collections::list;

import std::io;

def Point = int[<2>];

fn uint Point.hash(&self)
{
  // TODO this isnt the best hashing method
  return self.x ^ self.y;
}


struct World
{
  Point offset;
  int zoom;

  int scale;

  List(<List(<Component*>)>) grid;
  List(<Component>) data;
}


// TODO: make the module called world and make this world::new() that returns a world
fn void World.new_init(&self)
{
  // Scale is size in pixels of grid
  self.scale = 10;

  self.grid.new_init();
  self.data.new_init();
}

fn void World.free(&self)
{
  foreach (column : self.grid)
  {
	column.free();
  }
  self.grid.free();
  self.data.free();
}

Component null_component = {NULL, {}};

fn Point World.world_to_grid(&self, Point world_coords)
{
  return world_coords / self.scale;
}

fn Point World.grid_to_world(&self, Point grid_coords)
{
  return grid_coords * self.scale;
}

fn Component* World.get_at(&self, Point pos)
{
  return (pos.x >= self.grid.len() || pos.y >= self.grid[pos.x].len()) ? &null_component : self.grid[pos.x][pos.y];
}

fn void World.set_at(&self, Point pos, Component* com)
{
  usz orig_len = self.grid.len();
  if (pos.x >= orig_len)
  {
	for (usz i = orig_len; i <= pos.x; i++)
	{
	  io::printfn("n: %s", i);
	  List(<Component*>) a;
	  a.new_init();
	  self.grid.push(a);
	}
  }
  while (pos.y >= self.grid[pos.x].len()) {
	self.grid[pos.x].push(&null_component);
  }
  self.grid.get(pos.x).set(pos.y, com);
}

// Add last_ref function to the world grid
fn Component* List(<Component>).last_ref(&self)
{
  return &self.entries[self.size -1];
}

struct Component
{
  ComponentType type;
  ComponentData data;
}

fn void Component.power(&self)
{
  switch (self.type)
  {
	case WIRE:
	  self.data.as_wire.powered = true;
	default:
  }
}


// This compares if the components are the same in memo
fn bool Component.equals(&self, Component other)
{
  return self.type == other.type && self.data.equals(other.data);
}


enum ComponentType
{
  NULL,
  WIRE,
  BUTTON,
}

union ComponentData
{
  Button as_button;
  Wire as_wire;
}

fn bool ComponentData.equals(&self, ComponentData other)
{
  //   $foreach ($member : ComponentData.membersof)
  // 	if (self.$member != other.$member) return false;
  // $endforeach
  // return true;
  return self.as_button.equals(other.as_button) && self.as_wire.equals(other.as_wire);
}

struct Wire
{
  bool powered;
}

fn bool Wire.equals(&self, Wire other)
{
  // String $a = "powered";
  // // $foreach ($member : $a)
  // 	// $if ($member):
  // if (self.$a != other.$a) return false;
  // 	// $endif
  // // $endforeach
  // return true;
  return self.powered == other.powered;
}

struct Button
{
  bool enabled;
}

// FIXME all of these .equals functions break 
fn bool Button.equals(&self, Button other)
{
  // $foreach ($member : Button.membersof)
  // 	if (self.$member != other.$member) return false;
  // $endforeach
  // return true;
  return self.enabled == other.enabled;
}


fn void Button.push(&self, Point position)
{
  // TODO
}

// fn bool Button.equals(&self, Button other)
// {
//   // The buttons should never overlap
//   // return self.position == other.position;
//   return false;
// }
