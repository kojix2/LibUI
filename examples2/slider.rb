# ============================================================================ #
# This example (slider.rb) shall demonstrate the following functionality
# (8 components), as well as their implementation-status in regards to
# this file:
#
#   :new_slider                                 # [DONE]
#   :slider_has_tool_tip                        # [DONE]
#   :slider_on_changed                          # [DONE]
#   :slider_on_released                         # [DONE]
#   :slider_set_has_tool_tip                    # [DONE]
#   :slider_set_range                           # [DONE]
#   :slider_set_value                           # [DONE]
#   :slider_value                               # [DONE]
#
# API documentation can be seen here:
#
#   https://libui.dev/structui_slider.html
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('slider.rb', 800, 440, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

# new_slider() wants: uiNewSlider (int min, int max)
_ = LibUI.new_slider(1, 100) # Create a new slider here.
LibUI.box_append(hbox, _, 1) # Add the slider here.

# ============================================================================ #
# The default "tooltip" is the current value of the slider at hand.
# ============================================================================ #
puts 'Does this slider haver a tooltip? '+
     LibUI.slider_has_tool_tip(_).to_s

callback_proc_on_changed = proc {|entry| # entry is a Fiddle::Pointer
  new_value = LibUI.slider_value(entry) # Obtain the current value of the slider here.
  puts 'The slider was changed. The new value is: '+new_value.to_s
}
LibUI.slider_set_has_tool_tip(_, 1) # 1 means true here

puts 'Modifying the range now from -200 to +200.'
LibUI.slider_set_range(_, -200, 200)

puts 'Setting the value of the slider to 42 now, as a new default.'
LibUI.slider_set_value(_, 42)

LibUI.slider_on_changed(_, callback_proc_on_changed)

callback_proc_on_released = proc {|entry| # entry is a Fiddle::Pointer
  puts 'The slider was released.'
}

LibUI.slider_on_released(_, callback_proc_on_released)

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
