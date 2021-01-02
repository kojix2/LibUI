# frozen_string_literal: true

require 'libui'

UI = LibUI

UI.init

main_window = UI.new_window('hello world', 300, 200, 1)

font_button = UI.new_font_button
font_descriptor = UI::FFI::FontDescriptor.malloc
UI.font_button_on_changed(font_button) do
  UI.font_button_font(font_button, font_descriptor)
  p family: font_descriptor.Family.to_s,
    size: font_descriptor.Size,
    weight: font_descriptor.Weight,
    italic: font_descriptor.Italic,
    stretch: font_descriptor.Stretch
  0
end

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.control_destroy(main_window)
  UI.quit
  0
end

UI.window_set_child(main_window, font_button)
UI.control_show(main_window)

UI.main
UI.quit
