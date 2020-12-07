require 'libui'

options = LibUI::FFI::InitOptions.malloc
init    = LibUI::FFI.uiInit(options)

unless init.size.zero?
  warn 'error'
  warn LibUI::FFI.uiFreeInitError(init)
end

main_window = LibUI::FFI.uiNewWindow('hello world', 300, 200, 1)

should_quit = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOIDP, [Fiddle::TYPE_VOIDP]) do |_pt|
  puts 'Bye Bye'
  LibUI::FFI.uiControlDestroy(main_window)
  LibUI::FFI.uiQuit
  0
end

LibUI::FFI.uiControlShow(main_window)
LibUI::FFI.uiWindowOnClosing(main_window, should_quit, nil)

LibUI::FFI.uiMain
LibUI::FFI.uiQuit
