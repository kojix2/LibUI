# ============================================================================ #
# This example (font_button.rb) shall demonstrate the following
# functionality (5 components), as well as their implementation-status
# in regards to this file:
#
#   :new_font_button              # [DONE]
#   :font_button_font             # [NOT YET ADDED]
#   :font_button_on_changed       # [DONE]
#   :free_font_button_font        # [NOT YET ADDED]
#   :free_font_descriptor         #[NOT YET ADDED]
#
# Unsure what ":load_control_ font" is.
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('font_button.rb', 640, 240, 1)

vbox = LibUI.new_vertical_box
LibUI.box_set_padded(vbox, 1)
_ = LibUI.new_font_button # Create a new font-button here.
LibUI.box_append(vbox, _, 0) # Add the font-button here.

LibUI.font_button_on_changed(_) {|entry|
  puts 'The font was changed. (class '+entry.class.to_s+')'
}

LibUI.window_set_child(main_window, vbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
