require 'libui'

UI = LibUI

UI.init

main_window = UI.new_window('hello world', 300, 200, 1)

font_button = UI.new_font_button
UI.font_button_on_changed(font_button) do
  font = UI.font_button_font(font_button)
  p font.to_h
end

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

UI.window_set_child(main_window, font_button)
UI.control_show(main_window)

UI.main
UI.uninit
