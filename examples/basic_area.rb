require 'libui'

UI = LibUI

UI.init

brush = UI::Brush.new(color: [0.4, 0.4, 0.8, 1.0])

handler = UI::AreaHandler.new(draw: ->(event) do
  path = UI.draw_new_path(0)
  UI.draw_path_add_rectangle(path, 0, 0, 400, 400)
  UI.draw_path_end(path)
  event.context.fill(path, brush)
  UI.draw_free_path(path)
end)
area = UI.new_area(handler)

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.box_append(box, area, 1)

main_window = UI.new_window('Basic Area', 400, 400, 1)
UI.window_set_margined(main_window, 1)
UI.window_set_child(main_window, box)

UI.window_on_closing(main_window) do
  UI.quit
  1
end
UI.control_show(main_window)

UI.main
UI.uninit
