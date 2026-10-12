# NOTE:
# This example displays images that can be freely downloaded from the Studio Ghibli website.
# https://www.ghibli.jp/works/red-turtle/
# "Please feel free to use them within the scope of common sense."　Toshio Suzuki (producer)

require 'libui'
require 'chunky_png'
require 'open-uri'

UI = LibUI

UI.init

main_window = UI.new_window('The Red Turtle (2016)', 310, 350, 0)

hbox = UI.new_horizontal_box
UI.window_set_child(main_window, hbox)

IMAGES = Array.new(50) do |i|
  url = format('https://www.ghibli.jp/gallery/thumb-redturtle%03d.png', i + 1)
  canvas = URI.open(url) { |f| ChunkyPNG::Canvas.from_io(f) }
  data = canvas.to_rgba_stream
  width = canvas.width
  height = canvas.height
  image = UI.new_image(width, height)
  UI.image_append_rgba(image, data, width, height)
  image
rescue StandardError => e
  warn url, e.message
end

model = UI::TableModel.new(column_types: [UI::TableValueTypeImage],
                           rows: IMAGES.map { |image| [image] })
table = UI.new_table(model: model)
UI.table_append_image_column(table, 'Directed by Michaël Dudok de Wit', 0)

UI.box_append(hbox, table, 1)
UI.control_show(main_window)

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

UI.main
model.free
IMAGES.each { |i| UI.free_image(i) }
UI.uninit
