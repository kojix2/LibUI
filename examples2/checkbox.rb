# ============================================================================ #
# This example (checkbox.rb) shall demonstrate the following functionality
# (6 components), as well as their implementation-status in regards to
# this file:
#
#   :new_checkbox              # [DONE]
#   :checkbox_checked          # [DONE]
#   :checkbox_on_toggled       # [DONE]
#   :checkbox_set_checked      # [DONE]
#   :checkbox_set_text         # [DONE]
#   :checkbox_text             # [DONE]
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

def ui_text(text_pointer)
  text_pointer.to_s
ensure
  LibUI.free_text(text_pointer) if text_pointer && !text_pointer.null?
end

main_window = LibUI.new_window('checkbox.rb', 400, 240, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

_ = LibUI.new_checkbox # Create a new checkbox here.
LibUI.box_append(hbox, _, 1) # Add it to a box.
LibUI.checkbox_set_text(_, 'This is a generic text for the checkbox.')

puts 'The text for our checkbox follows (obtained via LibUI.checkbox_text():'
puts
puts "  #{ui_text(LibUI.checkbox_text(_))}"
puts

callback_for_the_checkbox = proc {
  puts 'I was toggled. My state is now:'
  case LibUI.checkbox_checked(_)
  when 1
    puts '  checked (active)'
  when 0
    puts '  unchecked (inactive)'
  end
  0 # This return value does not seem to be necessary, but we use it still, to show that one could use a return value here.
}

LibUI.checkbox_on_toggled(_, callback_for_the_checkbox)

puts 'Setting the checkbox to checked (is-selected) next.'
LibUI.checkbox_set_checked(_, 1)

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) do
  LibUI.quit
  1
end

LibUI.main
LibUI.uninit
