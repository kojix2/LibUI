require 'libui'

UI = LibUI

UI.init

main_window = UI.new_window('hello world', 300, 200, 1)

button = UI.new_button('Button')

UI.button_on_clicked(button) do
  UI.msg_box(main_window, 'Information', 'You clicked the button')
end

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

UI.window_set_child(main_window, button)
UI.control_show(main_window)

UI.main
UI.uninit
