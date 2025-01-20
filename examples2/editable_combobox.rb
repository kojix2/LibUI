# ============================================================================ #
# This example (editable_combobox.rb) shall demonstrate the following
# functionality (5 components), as well as their implementation-status in
# regards to this file:
#
#   :new_editable_combobox                 # [DONE]
#   :editable_combobox_append              # [DONE]
#   :editable_combobox_on_changed          # [DONE]
#   :editable_combobox_set_text            # [DONE]
#   :editable_combobox_text                # [DONE]
#
# See an API reference here:
#
#   https://libui-ng.github.io/libui-ng/structui_editable_combobox.html
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

# ============================================================================ #
# === populate_the_combobox_with_this_array
#
# This method is used as a helper-method, to populate the combobox we use
# here with data (an Array).
# ============================================================================ #
def populate_the_combobox_with_this_array(
    the_combobox,
    this_array
  )
  this_array.each {|this_entry|
    LibUI.editable_combobox_append(the_combobox, this_entry) # Here we add elements to the combobox.
  }
  LibUI.combobox_set_selected(the_combobox, 0) # The first element is now the default selected entry.
end

main_window = LibUI.new_window('combobox.rb', 640, 480, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

_  = LibUI.new_editable_combobox # Create a new combobox here.
LibUI.box_append(hbox, _, 1) # Add the combobox here. Right now the combobox is empty.

# ============================================================================ #
# Let's add data to the combobox, as an Array:
# ============================================================================ #
array = %w( matz created ruby as efficient alternative to perl )
populate_the_combobox_with_this_array(_, array)

# ============================================================================ #
# Next showing how to clear it:
# ============================================================================ #
LibUI.combobox_clear(_)
populate_the_combobox_with_this_array(_, array) # And re-populate it here.

# ============================================================================ #
# Next we delete the third entry; and then insert two new elements
# at that former position, to showcase the functionality
# combobox_delete, as well as combobox_insert_at. Note that combobox_delete
# takes two arguments, whereas combobox_insert_at takes three arguments.
# ============================================================================ #
LibUI.combobox_delete(_, 2)
LibUI.combobox_insert_at(_, 2, 'ruby')

# ============================================================================ #
# Show how many elements are in that combobox:
# ============================================================================ #
puts "The combobox we are using here has a total "\
     "of #{LibUI.combobox_num_items(_)} elements."

LibUI.combobox_set_selected(_, 3) # Change the selected element next, to item 4.

# ============================================================================ #
# Show the selected entry next:
# ============================================================================ #
puts "The presently selected entry in our combobox is element number "\
     "#{LibUI.combobox_selected(_)}."

puts 'Last but not least, try to change the combobox to a new value.'
puts 'This will trigger LibUI.combobox_on_selected().'

# ============================================================================ #
# Testing support for :editable_combobox_on_changed next.
# ============================================================================ #
LibUI.editable_combobox_on_changed(_) { |pointer|
  selected = LibUI.combobox_selected(pointer)
  puts "The new selection is element number `#{selected}`."
  puts "The currently selected text is: `#{LibUI.editable_combobox_text(pointer)}`"
}

LibUI.editable_combobox_set_text(_, 'Testing a new default text. This will appear first.')

LibUI.editable_combobox_append(_, 'This is a black cat.') # Here we add elements to the combobox.

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
