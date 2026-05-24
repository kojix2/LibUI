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

def ui_text(text_pointer)
  text_pointer.to_s
ensure
  LibUI.free_text(text_pointer) if text_pointer && !text_pointer.null?
end

# ============================================================================ #
# === populate_the_editable_combobox_with_this_array
#
# This method is used as a helper-method, to populate the editable combobox
# we use here with data (an Array).
# ============================================================================ #
def populate_the_editable_combobox_with_this_array(
    the_combobox,
    this_array
  )
  this_array.each {|this_entry|
    LibUI.editable_combobox_append(the_combobox, this_entry) # Here we add elements to the combobox.
  }
end

main_window = LibUI.new_window('editable_combobox.rb', 640, 480, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

_  = LibUI.new_editable_combobox # Create a new editable combobox here.
LibUI.box_append(hbox, _, 1) # Add the editable combobox here. Right now the combobox is empty.

# ============================================================================ #
# Let's add suggestions to the editable combobox, as an Array:
# ============================================================================ #
array = %w( matz created ruby as efficient alternative to perl )
populate_the_editable_combobox_with_this_array(_, array)

# ============================================================================ #
# As explained by kojix2, libui-ng intentionally limits editable comboboxes
# to simple text get/set functionality.
#
# Since users can freely input text in an editable combobox, the concept
# of "which item is selected" becomes ambiguous. This is why
# LibUI.editable_combobox_set_text() is used next.
# ============================================================================ #
LibUI.editable_combobox_set_text(_, 'Testing a new default text. This will appear first.')

puts 'The current editable combobox text is:'
puts
puts "  #{ui_text(LibUI.editable_combobox_text(_))}"
puts
puts 'Try to change the editable combobox to a new value.'
puts 'This will trigger LibUI.editable_combobox_on_changed().'

# ============================================================================ #
# Testing support for :editable_combobox_on_changed next.
# ============================================================================ #
LibUI.editable_combobox_on_changed(_) { |pointer|
  puts "The current text is: `#{ui_text(LibUI.editable_combobox_text(pointer))}`"
}

# ============================================================================ #
# Additional suggestions can be appended at any time.
# ============================================================================ #
LibUI.editable_combobox_append(_, 'This is a black cat.') # Here we add elements to the combobox.

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
