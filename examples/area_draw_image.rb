require 'libui'

UI = LibUI

def sample_rgba(width, height)
  pixels = ''.b

  height.times do |y|
    width.times do |x|
      cx = x - width / 2.0
      cy = y - height / 2.0
      distance = Math.sqrt(cx * cx + cy * cy)
      r = [255 - distance * 2, 0].max.round
      g = (255.0 * x / (width - 1)).round
      b = (255.0 * y / (height - 1)).round
      pixels << r << g << b << 255
    end
  end

  pixels
end

width = 120
height = 120
pixels = sample_rgba(width, height)

UI.init

image = UI.new_image(width, height)
UI.image_append(image, pixels, width, height, width * 4)

handler = UI::FFI::AreaHandler.malloc
handler.to_ptr.free = Fiddle::RUBY_FREE

white_brush = UI::FFI::DrawBrush.malloc
white_brush.to_ptr.free = Fiddle::RUBY_FREE
white_brush.Type = UI::DrawBrushTypeSolid
white_brush.R = 1.0
white_brush.G = 1.0
white_brush.B = 1.0
white_brush.A = 1.0

@callbacks = []

draw_callback = Fiddle::Closure::BlockCaller.new(0, [1, 1, 1]) do |_, _, area_draw_params|
  params = UI::FFI::AreaDrawParams.new(area_draw_params)

  path = UI.draw_new_path(UI::DrawFillModeWinding)
  UI.draw_path_add_rectangle(path, 0, 0, params.AreaWidth, params.AreaHeight)
  UI.draw_path_end(path)
  UI.draw_fill(params.Context, path, white_brush.to_ptr)
  UI.draw_free_path(path)

  UI.draw_image(params.Context, image, 10, 10, 100, 100)
  UI.draw_image(params.Context, image, 160, 10, 200, 100)
  UI.draw_image(params.Context, image, 10, 160, 100, 200)
  UI.draw_image(params.Context, image, 160, 160, 200, 200)
end
@callbacks << draw_callback

do_nothing = Fiddle::Closure::BlockCaller.new(0, [0]) {}
key_event = Fiddle::Closure::BlockCaller.new(1, [0]) { 0 }
@callbacks.concat([do_nothing, key_event])

handler.Draw = draw_callback
handler.MouseEvent = do_nothing
handler.MouseCrossed = do_nothing
handler.DragBroken = do_nothing
handler.KeyEvent = key_event

area = UI.new_area(handler)

box = UI.new_horizontal_box
UI.box_append(box, area, 1)

window = UI.new_window('Draw Image Example', 400, 400, 0)
UI.window_set_margined(window, 1)
UI.window_set_child(window, box)

UI.window_on_closing(window) do
  UI.quit
  1
end

UI.control_show(window)
UI.main

UI.free_image(image)
UI.uninit
