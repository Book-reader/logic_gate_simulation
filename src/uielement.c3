module sdl2_ui;

import sdl2;

import logic_gate_simulation::component;

def OnClickFunction = fn void();

interface UIElement
{
  fn void set_on_click(OnClickFunction on_click);
  fn void on_click();
  fn bool is_clickable();
  fn Point get_pos();
  fn void draw(SDLRenderer renderer, Point offset);
  fn Point get_size();
}

const Point BUTTON_SIZE = {20, 20};

fn Button new_button(Point pos, String text, OnClickFunction on_click = fn () => {|io::printfn("button pressed");|})
{
  return {pos, BUTTON_SIZE, text, on_click, true};
}

struct Button (UIElement)
{
  Point pos;
  Point size;
  String text;
  OnClickFunction on_click;
  bool clickable;
}

fn Point Button.get_pos(&self) @dynamic
{
  return self.pos;
}

fn void Button.set_on_click(&self, OnClickFunction on_click) @dynamic
{
  self.on_click = on_click;
}

fn void Button.on_click(&self) @dynamic
{
  self.on_click();
}

fn void Button.draw(&self, SDLRenderer renderer, Point offset) @dynamic
{
  sdl2::fill_rect(renderer, &&SDLRect {self.pos.x - offset.x, self.pos.y - offset.y, self.size.x, self.size.y});

  sdl2::draw_text(renderer, (ZString)self.text, {self.pos.x - offset.x, self.pos.y - offset.y}, {0, 0, 0, 0xff});

}

fn Point Button.get_size(&self) @dynamic
{
  return self.size;
}

fn bool Button.is_clickable(&self) @dynamic
{
  return self.clickable;
}

fn Button Button.set_size(self, Point size)
{
  self.size = size;
  return self;
}
