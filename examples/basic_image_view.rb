require 'libui'

UI = LibUI

def sample_rgba(width, height)
  pixels = ''.b

  height.times do |y|
    width.times do |x|
      r = (255.0 * x / (width - 1)).round
      g = (255.0 * y / (height - 1)).round
      b = ((x / 12 + y / 12).even? ? 220 : 80)
      pixels << r << g << b << 255
    end
  end

  pixels
end

width = 160
height = 120
pixels = sample_rgba(width, height)

UI.init

window = UI.new_window('ImageView Example', 300, 220, 0)
UI.window_set_margined(window, 1)

box = UI.new_vertical_box
UI.box_set_padded(box, 1)

image = UI.new_image(width, height)
UI.image_append(image, pixels, width, height, width * 4)

image_view = UI.new_image_view
UI.image_view_set_image(image_view, image)
UI.image_view_set_content_mode(image_view, UI::ImageViewContentFit)

# uiImageView keeps its own internal image after SetImage().
UI.free_image(image)

UI.box_append(box, image_view, 1)
UI.box_append(box, UI.new_label('Generated RGBA image'), 0)
UI.window_set_child(window, box)

UI.window_on_closing(window) do
  UI.quit
  1
end

UI.control_show(window)
UI.main
UI.uninit
