# ============================================================================ #
# This example (search_entry.rb) shall demonstrate the following functionality
# (6 components), as well as their implementation-status in regards to
# this file:
#
#   :new_entry                   # [DONE]
#   :entry_on_changed            # [DONE]
#   :entry_read_only             # [DONE]
#   :entry_set_read_only         # [DONE]
#   :entry_set_text              # [DONE]
#   :entry_text                  # [DONE]
#
# Note that search-entry is a subclass of uiEntry.
#
# See also rust-documentation here:
#
#   https://docs.rs/libui/latest/libui/controls/struct.SearchEntry.html
#
# Or Go documentation here:
#
#   https://pkg.go.dev/github.com/andlabs/ui#NewSearchEntry
# 
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('search_entry.rb', 800, 440, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

_ = LibUI.new_search_entry # Create a new search-entry here.
LibUI.box_append(hbox, _, 1) # Add the search-entry here.
@old_entry_text = 'This is a generic text for the search-entry.'
LibUI.entry_set_text(_, @old_entry_text)

puts 'The entry will be set to read-onlyn ext, via '\
     'LibUI.entry_set_read_only().'

LibUI.entry_set_read_only(_, 1) # We have to use 1 rather than true here, unfortunately.
puts
puts "Is this entry read-only? #{LibUI.entry_read_only(_)}"\
     " # note that a 1 here means yes/true"
puts
puts 'The text for the current entry in use is as follows:'
puts
puts "  → #{LibUI.entry_text(_)}"
puts
puts 'Making the entry no longer read-only next:'
puts
LibUI.entry_set_read_only(_, 0) # We have to use 1 rather than true here, unfortunately.

callback_proc = proc { |pointer|
  new_text = LibUI.entry_text(pointer).to_s
  puts
  puts "The old entry-text was: '#{@old_entry_text}'"
  puts "The new entry-text is:  '#{new_text}'"
  @old_entry_text = new_text
  puts
  puts 'Note that this callback can be modified to'
  puts 'allow for the search functionality'
}
LibUI.entry_on_changed(_, callback_proc)

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
