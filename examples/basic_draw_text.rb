require 'libui'

UI = LibUI

UI.init

handler = UI::FFI::AreaHandler.malloc
area    = UI.new_area(handler)
font_button = UI.new_font_button

STR = <<-EOS

EOS

str = UI.new_attributed_string(STR)

handler_draw_event = Fiddle::Closure::BlockCaller.new(0, [1, 1, 1]) do |_, _, adp|
  area_draw_params = UI::FFI::AreaDrawParams.new(adp)
  default_font = UI::FFI::FontDescriptor.malloc
  params = UI::FFI::DrawTextLayoutParams.malloc

  UI.font_button_font(font_button, default_font)
  params.String = str
  params.DefaultFont = default_font
  params.Width = area_draw_params.AreaWidth
  params.Align = 0
  text_layout = UI.draw_new_text_layout(params)
  UI.draw_text(area_draw_params.Context, text_layout, 0, 0)
  UI.draw_free_text_layout(text_layout)
  UI.free_font_button_font(default_font)
end

handler.Draw         = handler_draw_event
handler.MouseEvent   = Fiddle::Closure::BlockCaller.new(0, [0]) {}
handler.MouseCrossed = Fiddle::Closure::BlockCaller.new(0, [0]) {}
handler.DragBroken   = Fiddle::Closure::BlockCaller.new(0, [0]) {}
handler.KeyEvent     = Fiddle::Closure::BlockCaller.new(0, [0]) {}

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.box_append(box, area, 1)

main_window = UI.new_window('Basic Draw Text', 300, 200, 1)
UI.window_set_margined(main_window, 1)
UI.window_set_child(main_window, box)

UI.window_on_closing(main_window) do
  UI.control_destroy(main_window)
  UI.quit
  0
end
UI.control_show(main_window)

UI.main
UI.quit
