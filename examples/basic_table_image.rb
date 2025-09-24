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
  f = URI.open(url)
  canvas = ChunkyPNG::Canvas.from_io(f)
  f.close
  data = canvas.to_rgba_stream
  width = canvas.width
  height = canvas.height
  image = UI.new_image(width, height)
  UI.image_append(image, data, width, height, width * 4)
  image
rescue StandardError => e
  warn url, e.message
end

# Protects BlockCaller objects from garbage collection.
@block_callers = []
def rbcallback(*args, &block)
  args << [0] if args.size == 1 # Argument types are omitted
  block_caller = Fiddle::Closure::BlockCaller.new(*args, &block)
  @block_callers << block_caller
  block_caller
end

model_handler = UI::FFI::TableModelHandler.malloc
model_handler.to_ptr.free = Fiddle::RUBY_FREE
model_handler.NumColumns   = rbcallback(4) { 1 }
model_handler.ColumnType   = rbcallback(4) { 1 } # Image
model_handler.NumRows      = rbcallback(4) { IMAGES.size }
model_handler.CellValue    = rbcallback(1, [1, 1, 4, 4]) do |_, _, row, _column|
  UI.new_table_value_image(IMAGES[row])
end
model_handler.SetCellValue = rbcallback(0, [0]) {}

model = UI.new_table_model(model_handler)

table_params = UI::FFI::TableParams.malloc
table_params.to_ptr.free = Fiddle::RUBY_FREE
table_params.Model = model
table_params.RowBackgroundColorModelColumn = -1

table = UI.new_table(table_params)
UI.table_append_image_column(table, 'Directed by Michaël Dudok de Wit', -1)

UI.box_append(hbox, table, 1)
UI.control_show(main_window)

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

UI.main
UI.free_table_model(model)
IMAGES.each { |i| UI.free_image(i) }
UI.uninit
