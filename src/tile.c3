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

  List(<List(<usz>)>) grid;
  List(<Component>) data;
}


// TODO: make the module called world and make this world::new() that returns a world
fn void World.new_init(&self)
{
  // Scale is size in pixels of grid
  self.scale = 10;

  self.grid.new_init();
  self.data.new_init();
  // self.data[0] is null
  self.data.push({NULL, {}});
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

fn Point World.world_to_grid(&self, Point world_coords) => world_coords / self.scale;

fn Point World.grid_to_world(&self, Point grid_coords) => grid_coords * self.scale;

fn Component* World.get(&self, usz idx) => self.data.len() <= idx ? &null_component : &self.data[idx];

fn Component* World.get_at(&self, Point pos) => (pos.x >= self.grid.len() || pos.y >= self.grid[pos.x].len()) ? &null_component : &self.data[self.grid[pos.x][pos.y]];

fn usz World.get_idx_at(&self, Point pos) => (pos.x >= self.grid.len() || pos.y >= self.grid[pos.x].len()) ? 0 : self.grid[pos.x][pos.y];

fn void World.set_at(&self, Point pos, usz idx)
{
  usz orig_len = self.grid.len();
  if (pos.x >= orig_len)
  {
	for (usz i = orig_len; i <= pos.x; i++)
	{
	  io::printfn("n: %s", i);
	  List(<usz>) a;
	  a.new_init();
	  self.grid.push(a);
	}
  }
  while (pos.y >= self.grid[pos.x].len()) {
	self.grid[pos.x].push(0);
  }
  self.grid.get(pos.x).set(pos.y, idx);
}

// This cleans deleted data from the data list
// perhaps you could say it is a garbage collector >:)
// Should run every x seconds or after x deletions
fn void World.clean_null(&self)
{
  List(<usz>) idx_to_remove;
  idx_to_remove.new_init();
  defer idx_to_remove.free();
  for (int i = 1; i < self.data.len(); i++)
  {
	Component data = self.data[i];
	if (equals(data, Component {NULL, {}}))
	{
	  idx_to_remove.push(i);
	}
  }
  for (isz i = idx_to_remove.len() - 1; i >= 0; i--)
  {
	usz idx = idx_to_remove[i];
	foreach (row : self.grid)
	{
	  foreach (&cell : row)
	  {
		if (*cell == idx)
		{
		  *cell = 0;
		}
		else if (*cell > idx)
		{
		  (*cell) --;
		}
	  }
	}
	self.data.remove_at(idx);
  }
}


// TODO: automatic incrementing then every 100 or so run clean_null()
fn void World.remove(&self, usz idx) => self.data.set(idx, {NULL, {}});

// Add last_idx function to the world data
fn usz List(<Component>).last_idx(&self) => self.len() - 1;

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
  return @generic_equals(Component, self, other);
}


enum ComponentType
{
  NULL,
  WIRE,
  BUTTON,
  SWITCH,
}

union ComponentData
{
  Button as_button;
  Wire as_wire;
}

fn bool ComponentData.equals(&self, ComponentData other)
{
  return @generic_equals(ComponentData, self, other);
}

struct Wire
{
  bool powered;
}

fn bool Wire.equals(&self, Wire other)
{
  return @generic_equals(Wire, self, other);
}

struct Button
{
  bool enabled;
}

// FIXME all of these .equals functions break 
fn bool Button.equals(&self, Button other)
{
  return @generic_equals(Button, self, other);
}


fn void Button.push(&self, Point position)
{
  // TODO
}

macro bool @generic_equals($Type, self, other) @local
{
  $foreach ($member : $Type.membersof)
	if (!equals($member.get(*self), $member.get(other))) return false;
  $endforeach
  return true;
}
