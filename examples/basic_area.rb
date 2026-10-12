require 'libui'

UI = LibUI

UI.init

brush = UI::Brush.new(color: [0.4, 0.4, 0.8, 1.0])

handler = UI::AreaHandler.new(draw: ->(event) do
  UI::Path.open do |path|
    path.add_rectangle(0, 0, event.area_width, event.area_height).end_path
    event.context.fill(path, brush)
  end
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
