# Based on libui-ng's histogram example.

require 'libui'

UI = LibUI

X_OFF_LEFT   = 20
Y_OFF_TOP    = 20
X_OFF_RIGHT  = 20
Y_OFF_BOTTOM = 20

def graph_size(area_width, area_height)
  [area_width - X_OFF_LEFT - X_OFF_RIGHT,
   area_height - Y_OFF_TOP - Y_OFF_BOTTOM]
end

def point_locations(datapoints, width, height)
  xincr = width / 9.0
  yincr = height / 100.0

  datapoints.each_with_index.map do |spinbox, index|
    [xincr * index, yincr * (100 - UI.spinbox_value(spinbox))]
  end
end

def construct_graph(datapoints, width, height, extend:)
  locations = point_locations(datapoints, width, height)
  UI::Path.open do |path|
    path.new_figure(*locations.first)
    locations.drop(1).each { |x, y| path.line_to(x, y) }
    if extend
      path.line_to(width, height).line_to(0, height).close_figure
    end
    path.end_path
    yield path
  end
end

UI.init

hbox = UI.new_horizontal_box
UI.box_set_padded(hbox, 1)
vbox = UI.new_vertical_box
UI.box_set_padded(vbox, 1)
UI.box_append(hbox, vbox, 0)

datapoints = Array.new(10) do
  UI.new_spinbox(0, 100).tap do |spinbox|
    UI.spinbox_set_value(spinbox, rand(90))
    UI.box_append(vbox, spinbox, 0)
  end
end

color_button = UI.new_color_button
UI.color_button_set_color(color_button, 0x1E / 255.0, 0x90 / 255.0, 1.0, 1.0)
UI.box_append(vbox, color_button, 0)

white_brush = UI::Brush.new(color: [1.0, 1.0, 1.0, 1.0])
black_brush = UI::Brush.new(color: [0.0, 0.0, 0.0, 1.0])
graph_brush = UI::Brush.new
stroke = UI::StrokeParams.new(thickness: 2)
matrix = UI::Matrix.new.translate(X_OFF_LEFT, Y_OFF_TOP)

handler = UI::AreaHandler.new(draw: ->(event) do
  context = event.context
  graph_width, graph_height = graph_size(event.area_width, event.area_height)

  UI::Path.open do |path|
    path.add_rectangle(0, 0, event.area_width, event.area_height).end_path
    context.fill(path, white_brush)
  end

  UI::Path.open do |path|
    path.new_figure(X_OFF_LEFT, Y_OFF_TOP)
        .line_to(X_OFF_LEFT, Y_OFF_TOP + graph_height)
        .line_to(X_OFF_LEFT + graph_width, Y_OFF_TOP + graph_height)
        .end_path
    context.stroke(path, black_brush, stroke)
  end

  context.transform(matrix)
  red, green, blue, alpha = UI.color_button_color(color_button)
  graph_brush.color = [red, green, blue, alpha / 2.0]
  construct_graph(datapoints, graph_width, graph_height, extend: true) do |path|
    context.fill(path, graph_brush)
  end

  graph_brush.color = [red, green, blue, alpha]
  construct_graph(datapoints, graph_width, graph_height, extend: false) do |path|
    context.stroke(path, graph_brush, stroke)
  end
end)

histogram = UI.new_area(handler)
UI.box_append(hbox, histogram, 1)
datapoints.each do |spinbox|
  UI.spinbox_on_changed(spinbox) { UI.area_queue_redraw_all(histogram) }
end
UI.color_button_on_changed(color_button) { UI.area_queue_redraw_all(histogram) }

main_window = UI.new_window('histogram example', 640, 480, 1)
UI.window_set_margined(main_window, 1)
UI.window_set_child(main_window, hbox)
UI.window_on_closing(main_window) do
  UI.quit
  1
end
UI.control_show(main_window)

UI.main
UI.uninit
