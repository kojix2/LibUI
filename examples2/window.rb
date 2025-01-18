# ============================================================================ #
# This example (window.rb) shall demonstrate the following functionality
# (18 components), as well as their implementation-status in regards to
# this file:
#
#  :new_window                                   # [DONE]
#  :window_borderless                            # [DONE]
#  :window_content_size                          # Unsure how to use this
#  :window_focused                               # [DONE] - returns whether or not the window is focused.
#  :window_fullscreen                            # [DONE]
#  :window_margined                              # [DONE]
#  :window_on_closing                            # [DONE]
#  :window_on_content_size_changed               # [DONE]
#  :window_on_focus_changed                      # [DONE]
#  :window_resizeable                            # [DONE]
#  :window_set_borderless                        # [DONE]
#  :window_set_child                             # [DONE]
#  :window_set_content_size                      # [DONE]
#  :window_set_fullscreen                        # [DONE]
#  :window_set_margined                          # [DONE]
#  :window_set_resizeable                        # [DONE]
#  :window_set_title                             # [DONE]
#  :window_title                                 # [DONE]
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('window.rb', 880, 640, 1)
LibUI.window_set_title(main_window, 'TEST TITLE')
puts 'The temporary title of this window is: '+
      LibUI.window_title(main_window)
LibUI.window_set_title(main_window, 'window.rb') # And restore the title here again.
LibUI.window_set_resizeable(main_window, 0)
LibUI.window_set_margined(main_window, 1)
puts 'Is the window margined? '+
      LibUI.window_margined(main_window).to_s

puts 'The main-window will have a margin, thanks to LibUI.window_set_margined()'

puts 'Can this window be resized? '+
      LibUI.window_resizeable(main_window).to_s

puts 'Setting this window to fullscreen next, by default.'
puts '(Actually, no, because this is annoying; the code for this'
puts 'is LibUI.window_set_fullscreen(main_window, 1), though.'
# LibUI.window_set_fullscreen(main_window, 1)
puts 'You can also query it via LibUI.window_fullscreen(main_window)'

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

# ============================================================================ #
# LibUI.window_set_content_size() is actually
# LibUI::FFI.uiWindowSetContentSize
# The code for this is:
#
#   try_extern 'void uiWindowSetContentSize(uiWindow *w, int width, int height)'
#
# So it needs two arguments. Note that this can be ignored by the system
# though.
#
# More documentation for this method can be seen here:
#
#   https://libui.dev/structui_window.html#a1f33b8462a999bdaf276bcdca07dfe28
#
# ============================================================================ #
#LibUI.window_set_content_size(main_window, 500, 300)
# ^^^ this one does not work.

_ = LibUI.new_label(
  "Just testing the window-widget here.\n\n"\
  "For testing-purposes this window can not be resized, "\
  "which is\nNOT recommended. See LibUI.window_set_resizeable()"
  ) # Create a new help-text. here.
LibUI.box_append(hbox, _, 1) # Add it to a box.

puts
puts 'The window will be borderless, thanks to LibUI.window_set_borderless()'
puts 'Actually, that is not extremely useful, so we do not use it.'
LibUI.window_set_borderless(main_window, 0)
puts 'You can test whether it is borderless via LibUI.borderless()'

callback_proc = proc { |pointer|
  puts '_'*80
  puts 'The focus changed. This happens when the main-window'
  puts 'is dragged to a new position, for instance, as well as'
  puts 'on startup.'
  # === window_content_size
  #
  # try_extern 'void uiWindowContentSize(uiWindow *w, int *width, int *height)'
  #
  # puts 'The window-content-size is '+
  #       LibUI.window_content_size(main_window, 15,15).to_s
  puts '_'*80
}

LibUI.window_on_focus_changed(main_window, callback_proc)
puts 'Is the window focused? '+LibUI.window_focused(main_window).to_s

callback_on_content_size_changed = proc { |pointer|
  puts 'The content-size of the main window was changed.'
}
LibUI.window_on_content_size_changed(main_window, callback_on_content_size_changed)

# ============================================================================ #
# Moves the window to the specified position.
# ============================================================================ #
# puts 'Set to a position:'
# LibUI.window_set_position(main_window, 2, 2)

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)
LibUI.window_on_closing(main_window) {
  # Do on-closing actions here.
  LibUI.quit
  1 # An Integer must be returned by this block.
}

LibUI.main
LibUI.uninit
