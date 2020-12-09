# frozen_string_literal: true

require 'libui'

UI = LibUI

options = UI::FFI::InitOptions.malloc
init = UI.init(options)

unless init.size.zero?
  warn 'error'
  warn UI.free_init_error(init)
end

main_window = UI.new_window('hello world', 300, 200, 1)

should_quit = Fiddle::Closure::BlockCaller.new(
  Fiddle::TYPE_INT, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
) do |_pt1, _pt2|
  puts 'Bye Bye'
  UI.control_destroy(main_window)
  UI.quit
  0
end

button = UI.new_button('Button')
button_clicked_callback = Fiddle::Closure::BlockCaller.new(
  Fiddle::TYPE_VOIDP, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
) do |_pt1, _pt2|
  UI.msg_box(main_window, 'Information', 'You clicked the button')
  0
end
UI.button_on_clicked(button, button_clicked_callback, nil)

UI.window_on_closing(main_window, should_quit, nil)

UI.window_set_child(main_window, button)
UI.control_show(main_window)

UI.main
UI.quit
