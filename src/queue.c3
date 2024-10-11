module logic_gate_simulation::queue(<Type>);

import std::collections::list;

// Wow, really putting in the effort to make a new data structure here.
struct Queue
{
  List(<Type>) stuff;
}

fn void Queue.push(&self, Type element)
{
  self.stuff.push(element);
}

fn Type! Queue.pop(&self)
{
  return self.stuff.pop_first();;
}

fn void Queue.new_init(&self)
{
  self.stuff.new_init();
}

fn void Queue.free(&self)
{
  self.stuff.free();
}

fn usz Queue.len(&self) @operator(len)
{
  return self.stuff.len();
}
