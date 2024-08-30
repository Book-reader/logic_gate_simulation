module electronics_game::world;

import std::collections::list;

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
  foreach (cell : self.grid)
  {
	cell.free();
  }
  grid.free();
  data.free();
}

fn Point World.world_to_grid(&self, Point world_coords)
{
  return world_coords / self.scale;
}

fn Point World.grid_to_world(&self, Point grid_coords)
{
  return grid_coords * self.scale;
}

struct Wire
{
  List(<Point>) points;
  bool powered;
}

fn void Wire.new_init(&self)
{
  self.points.new_init();
}

fn void Wire.free(&self)
{
  self.points.free();
}

struct Button
{
  Point position;
  bool enabled;
  Wire* top;
  Wire* bottom;
  Wire* left;
  Wire* right;
}

fn void Button.push(&self)
{
  if (self.top != null)
  {
	self.top.powered = true;
  }
  if (self.bottom != null)
  {
	self.bottom.powered = true;
  }
  if (self.left != null)
  {
	self.left.powered = true;
  }
  if (self.right != null)
  {
	self.right.powered = true;
  }
}

fn bool Button.equals(&self, Button other)
{
  // The buttons should never overlap
  return self.position == other.position;
}
