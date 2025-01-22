# ============================================================================ #
# This example (color_button.rb) shall demonstrate the following
# functionality (4 components), as well as their implementation-status
# in regards to this file:
#
#   :new_color_button              # [DONE]
#   :color_button_color            # [DONE]
#   :color_button_on_changed       # [DONE]
#   :color_button_set_color        # [DONE]
#
# See an API reference here:
#
#   https://libui-ng.github.io/libui-ng/structui_editable_combobox.html
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('color_button.rb', 640, 240, 1)

# ============================================================================ #
# Get the colours and set up the brush
# uiColorButtonColor(colorButton, &graphR, &graphG, &graphB, &graphA)
# ============================================================================ #
graph_r = Fiddle::Pointer.malloc(8, Fiddle::RUBY_FREE) # double
graph_g = Fiddle::Pointer.malloc(8, Fiddle::RUBY_FREE) # double
graph_b = Fiddle::Pointer.malloc(8, Fiddle::RUBY_FREE) # double
graph_a = Fiddle::Pointer.malloc(8, Fiddle::RUBY_FREE) # double

vbox = LibUI.new_vertical_box
LibUI.box_set_padded(vbox, 1)
_ = LibUI.new_color_button # Create a new color-button here.
LibUI.box_append(vbox, _, 0) # Add the combobox here. Right now the combobox is empty.

LibUI.color_button_on_changed(_) {
  puts 'The colour button was changed.'
}

BRUSH             = LibUI::FFI::DrawBrush.malloc
BRUSH.to_ptr.free = Fiddle::RUBY_FREE

# === set_solid_brush
def set_solid_brush(
    brush = BRUSH,
    color = 0x1E90FF,
    alpha
  )
  BRUSH.Type = 0 # solid
  BRUSH.R = ((color >> 16) & 0xFF) / 255.0
  BRUSH.G = ((color >>  8) & 0xFF) / 255.0
  BRUSH.B = (color & 0xFF) / 255.0
  BRUSH.A = alpha
  BRUSH
end

puts 'Set to a blue colour next.'
set_solid_brush(BRUSH, 0x1E90FF, 1.0)

LibUI.color_button_set_color(_, BRUSH.R, BRUSH.G, BRUSH.B, BRUSH.A)

LibUI.color_button_color(_, graph_r, graph_g, graph_b, graph_a) # Use LibUI.color_button_color() here.

LibUI.window_set_child(main_window, vbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
