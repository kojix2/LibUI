# ============================================================================ #
# This example (color_button.rb) shall demonstrate the following
# functionality (4 components), as well as their implementation-status
# in regards to this file:
#
#   :new_color_button              # [DONE]
#   :color_button_color            # [DONE]
#   :color_button_on_changed       # [DONE]
#   :color_button_set_color        # [DONE]
#
# See an API reference here:
#
#   https://libui-ng.github.io/libui-ng/structui_color_button.html
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('color_button.rb', 640, 240, 1)

vbox = LibUI.new_vertical_box
LibUI.box_set_padded(vbox, 1)
color_button = LibUI.new_color_button
LibUI.box_append(vbox, color_button, 0)

LibUI.color_button_on_changed(color_button) do
  puts 'The colour button was changed.'
end

puts 'Set to a blue colour next.'
dodger_blue = [0x1E / 255.0, 0x90 / 255.0, 1.0, 1.0]
LibUI.color_button_set_color(color_button, *dodger_blue)

puts "Current color: #{LibUI.color_button_color(color_button).inspect}"

LibUI.window_set_child(main_window, vbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) do
  LibUI.quit
  1
end

LibUI.main
LibUI.uninit
