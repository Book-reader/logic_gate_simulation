module electronics_game::boilerplate_generator;

import std::io;

fn int main(String[] args)
{
  // if (args.len != 2)
  // {
  // unreachable("More than one argument passed");
  // }
  String class_name = args[1];

  io::printfn(`
fn Point %s.get_size(&self) @dynamic
{
  return self.size;
}

fn Point %s.get_pos(&self) @dynamic
{
  return self.pos;
}

fn usz %s.get_id(&self) @dynamic
{
  return self.id;
}

fn void %s.set_pos(&self, Point pos) @dynamic
{
  self.pos = pos;
}`, class_name, class_name, class_name, class_name);


  return 0;
}
