# ============================================================================ #
# This example (button.rb) shall demonstrate the following functionality
# (9 components), as well as their implementation-status in regards to
# this file:
#
#   :new_button                         # [DONE]
#   :button_on_clicked                  # [DONE]
#   :button_set_text                    # [DONE]
#   :button_text                        # [DONE]
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('button.rb', 400, 240, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

_ = LibUI.new_button # Create a new button here.
LibUI.box_append(hbox, _, 1) # Add the button here.
LibUI.button_set_text(_, 'This is a generic text for the button.')

puts 'The text for our button is as follows (obtained via LibUI.button_text():'
puts
puts "  #{LibUI.button_text(_)}"
puts

callback_for_the_button = proc {
  puts 'I was clicked.'
  0 # This return value does not seem to be necessary, but we use it still, to show that one could use a return value here.
}

LibUI.button_on_clicked(_, callback_for_the_button)

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
