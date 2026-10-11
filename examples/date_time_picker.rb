require 'libui'

UI = LibUI

UI.init

vbox = UI.new_vertical_box

date_time_picker = UI.new_date_time_picker
UI.date_time_picker_set_time(date_time_picker, Time.now)

UI.date_time_picker_on_changed(date_time_picker) do
  puts UI.date_time_picker_time(date_time_picker)
end
UI.box_append(vbox, date_time_picker, 1)

main_window = UI.new_window('Date Time Pickers', 300, 200, 1)
UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end
UI.window_set_child(main_window, vbox)
UI.control_show(main_window)

UI.main
UI.uninit
