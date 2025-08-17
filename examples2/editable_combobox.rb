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
  LibUI.editable_combobox_set_text(the_combobox, this_array[0]) # Set first element as default text.
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
# Note: uiEditableCombobox does not support clearing. Recreate if needed.
# ============================================================================ #

# ============================================================================ #
# Note: uiEditableCombobox does not support delete or insert operations.
# ============================================================================ #

# ============================================================================ #
# Note: uiEditableCombobox does not support counting items.
# ============================================================================ #

# ============================================================================ #
# Show the current text instead:
# ============================================================================ #
puts "The current text in our editable combobox is: "\
     "#{LibUI.editable_combobox_text(_)}"

puts 'Last but not least, try to change the combobox to a new value.'
puts 'This will trigger LibUI.editable_combobox_on_changed().'

# ============================================================================ #
# Testing support for :editable_combobox_on_changed next.
# ============================================================================ #
LibUI.editable_combobox_on_changed(_) { |pointer|
  puts "The editable combobox text has changed."
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
