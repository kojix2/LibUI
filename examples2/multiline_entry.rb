# ============================================================================ #
# This example (multiline_entry.rb) shall demonstrate the following functionality
# (6 components), as well as their implementation-status in regards to
# this file:
#
#   :multiline_entry_append        # [DONE]
#   :multiline_entry_on_changed
#   :multiline_entry_read_only     # [DONE]
#   :multiline_entry_set_read_only # [DONE]
#   :multiline_entry_set_text      # [DONE]
#   :multiline_entry_text
#   :new_multiline_entry           # [DONE]
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('entry.rb', 800, 440, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

_ = LibUI.new_multiline_entry # Create a new entry here.
LibUI.box_append(hbox, _, 1) # Add the entry here.
@old_entry_text = 'This is a generic text for the entry.'
LibUI.multiline_entry_set_text(_, @old_entry_text)
puts 'Appending something next.'
LibUI.multiline_entry_append(_, ' More content.')

callback_proc = proc { |pointer|
  new_text = LibUI.multiline_entry_text(pointer).to_s
  puts
  puts "The old entry-text was: '#{@old_entry_text}'"
  puts "The new entry-text is:  '#{new_text}'"
  @old_entry_text = new_text 
}
LibUI.multiline_entry_on_changed(_, callback_proc)

# LibUI.multiline_entry_set_read_only(_, 1) # Set it read-only here.
# LibUI.multiline_entry_read_only(_) # Query the read-only way here.

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
