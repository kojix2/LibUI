# frozen_string_literal: true

require 'libui'

UI = LibUI

options = UI::FFI::InitOptions.malloc
init    = UI.init(options)

unless init.size.zero?
  warn 'error'
  warn UI.free_init_error(init)
end

main_window = UI.new_window('hello world', 300, 200, 1)

should_quit = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOIDP, [Fiddle::TYPE_VOIDP]) do |_pt|
  puts 'Bye Bye'
  UI.control_destroy(main_window)
  UI.quit
  0
end

UI.control_show(main_window)
UI.window_on_closing(main_window, should_quit, nil)

UI.main
UI.quit
