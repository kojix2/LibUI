# ============================================================================ #
# This example (progress_bar.rb) shall demonstrate the following
# functionality (2 components), as well as their implementation-status
# in regards to this file:
#
#   :progress_bar_set_value       # [DONE]
#   :progress_bar_value           # [DONE]
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('ProgressBar', 640, 240, 1)

vbox = LibUI.new_vertical_box
LibUI.box_set_padded(vbox, 1)
_ = LibUI.new_progress_bar # Create a new progressbar here.
LibUI.progress_bar_set_value(_, 42) # Show how to set a value to a progress bar.
LibUI.box_append(vbox, _, 0.5) # Add the progressbar here.

puts 'The current value of the progress bar is: '+
      LibUI.progress_bar_value(_).to_s

LibUI.window_set_child(main_window, vbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
