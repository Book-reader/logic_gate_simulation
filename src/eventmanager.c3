module logic_gate_simulation::event_manager;

// TODO: some sort of common/types module that stores all type definitions
import logic_gate_simulation::component;

import std::collections::list;
import std::collections::map;

struct EventManager
{
  HashMap(<Id, List(<Id>)>) listeners;
}

fn void EventManager.new_init(&self)
{
  self.listeners.new_init();
}

fn void EventManager.free(&self)
{
  foreach (&id_list : self.listeners.value_tlist())
  {
    id_list.free();
  }
  self.listeners.free();
}

fn void EventManager.register(&self, Id own_id, Id listen_to)
{
  if (!self.listeners.has_key(listen_to))
  {
    List(<Id>) new_list;
    new_list.new_init();
    self.listeners.set(listen_to, new_list);
  }
  if (!self.listeners.get_ref(listen_to)!!.contains(own_id))
  {
    self.listeners.get_ref(listen_to)!!.push(own_id);
  }
}

fn void EventManager.deregister(&self, Id own_id, Id listen_to)
{
  self.listeners.get_ref(listen_to)!!.remove_first_item(own_id);
}

fn void EventManager.deregister_all(&self, Id own_id)
{
  foreach (id : self.listeners.tcopy_keys())
  {
    self.deregister(own_id, id);
  }
}

fault EventManagerFault
{
  NO_LISTENERS
}

fn Id[]! EventManager.listeners_of(&self, Id id)
{
  if (self.listeners.has_key(id))
  {
    return self.listeners.get_ref(id)!!.array_view();
  }
  return EventManagerFault.NO_LISTENERS?;
}
