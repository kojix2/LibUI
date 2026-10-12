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
# Every pixel is opaque, so these RGBA bytes are already premultiplied.
UI.image_append(image, pixels, width, height, width * 4)

white_brush = UI::Brush.new(color: [1.0, 1.0, 1.0, 1.0])

handler = UI::AreaHandler.new(draw: ->(event) do
  UI::Path.open do |path|
    path.add_rectangle(0, 0, event.area_width, event.area_height).end_path
    event.context.fill(path, white_brush)
  end

  event.context.draw_image(image, 10, 10, 100, 100)
  event.context.draw_image(image, 160, 10, 200, 100)
  event.context.draw_image(image, 10, 160, 100, 200)
  event.context.draw_image(image, 160, 160, 200, 200)
end)

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
