require 'libui'

UI = LibUI

UI.init

handler = UI::FFI::AreaHandler.malloc
area    = UI.new_area(handler)
brush   = UI::FFI::DrawBrush.malloc

handler_draw_event = Fiddle::Closure::BlockCaller.new(0, [1, 1, 1]) do |_, _, area_draw_params|
  path = UI.draw_new_path(0)
  UI.draw_path_add_rectangle(path, 0, 0, 400, 400)
  UI.draw_path_end(path)
  brush.Type = 0
  brush.R = 0.4
  brush.G = 0.4
  brush.B = 0.8
  brush.A = 1.0
  area_draw_params = UI::FFI::AreaDrawParams.new(area_draw_params)
  UI.draw_fill(area_draw_params.Context, path, brush.to_ptr)
  UI.draw_free_path(path)
end

handler.Draw         = handler_draw_event
handler.MouseEvent   = Fiddle::Closure::BlockCaller.new(0, [0]) {}
handler.MouseCrossed = Fiddle::Closure::BlockCaller.new(0, [0]) {}
handler.DragBroken   = Fiddle::Closure::BlockCaller.new(0, [0]) {}
handler.KeyEvent     = Fiddle::Closure::BlockCaller.new(0, [0]) {}

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.box_append(box, area, 1)

main_window = UI.new_window('Basic Area', 400, 400, 1)
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
