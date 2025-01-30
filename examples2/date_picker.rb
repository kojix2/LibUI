# ============================================================================ #
# === DatePicker - a widget to allow the user to enter a date
#
# This example (date_picker.rb) shall demonstrate the following functionality
# (3 components), as well as their implementation-status in regards to
# this file:
#
#   :new_date_picker             # [DONE]
#   :date_time_picker_on_changed # [DONE]
#   :date_time_picker_set_time   # [NOT YET IMPLEMENTED]
#
# Documentation for the perl-API, for libui, can be seen here:
#
#   https://metacpan.org/pod/LibUI::DatePicker
#
# While this is not necessarily 1:1 the ruby-API, for the most part it
# is quite similar.
#
# Note that not all functionality related to date_picker is tested for
# yet in this file. Patches to enhance functionality as well as the
# documentation are welcome.
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('date_picker.rb', 640, 240, 1)

vbox = LibUI.new_vertical_box
LibUI.box_set_padded(vbox, 1)
_ = LibUI.new_date_picker # Create a date-picker widget here.
LibUI.box_append(vbox, _, 0) # Add the font-button here.

callback_on_changed = proc { |pointer|
  puts 'The time was changed.'
  #puts LibUI.date_time_picker_time(pointer) 
}
LibUI.date_time_picker_on_changed(_, callback_on_changed)

# uiDateTimePickerSetTime(d : UI::DateTimePicker*, tm : LibC::Tm*)
# LibUI.date_time_picker_set_time(_, Time.now)

LibUI.window_set_child(main_window, vbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
