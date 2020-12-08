# frozen_string_literal: true

require 'libui'

options = LibUI::FFI::InitOptions.malloc
init = LibUI::FFI.uiInit(options)

unless init.size.zero?
  warn 'error'
  warn LibUI::FFI.uiFreeInitError(init)
end

main_window = LibUI::FFI.uiNewWindow('hello world', 300, 200, 1)

should_quit = Fiddle::Closure::BlockCaller.new(
  Fiddle::TYPE_INT, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
) do |_pt1, _pt2|
  puts 'Bye Bye'
  LibUI::FFI.uiControlDestroy(main_window)
  LibUI::FFI.uiQuit
  0
end

button = LibUI::FFI.uiNewButton('Button')
button_clicked_callback = Fiddle::Closure::BlockCaller.new(
  Fiddle::TYPE_VOIDP, [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]
) do |_pt1, _pt2|
  LibUI::FFI.uiMsgBox(main_window, 'Information', 'You clicked the button')
  0
end
LibUI::FFI.uiButtonOnClicked(button, button_clicked_callback, nil)

LibUI::FFI.uiWindowOnClosing(main_window, should_quit, nil)

LibUI::FFI.uiWindowSetChild(main_window, button)
LibUI::FFI.uiControlShow(main_window)

LibUI::FFI.uiMain
LibUI::FFI.uiQuit
