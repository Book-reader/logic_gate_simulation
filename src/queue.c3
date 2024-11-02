module logic_gate_simulation::queue(<Type>);

import logic_gate_simulation::main;

import std::collections::linkedlist;

// Wow, really putting in the effort to make a new data structure here.
struct Queue
{
  LinkedList(<Type>) stuff;
}

fn void Queue.push(&self, Type element)
{
  main::event_queue_mutex.lock()!!;
  defer main::event_queue_mutex.unlock()!!;
  self.stuff.push(element);
}

fn Type! Queue.pop(&self)
{
  main::event_queue_mutex.lock()!!;
  defer main::event_queue_mutex.unlock()!!;
  return self.stuff.pop_front();
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
