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

UI.control_show(main_window)

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.control_destroy(main_window)
  UI.quit
  0
end

UI.main
UI.quit
