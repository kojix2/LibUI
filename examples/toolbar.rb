require 'libui'

UI = LibUI

UI.init

ink = [50, 105, 185, 255].pack('C4')
transparent = "\0" * 4

drawn = proc do |shape, x, y|
  case shape
  when :plus
    (x.between?(7, 8) && y.between?(3, 12)) || (y.between?(7, 8) && x.between?(3, 12))
  when :square
    x.between?(3, 12) && y.between?(3, 12) &&
      (x.between?(3, 4) || x.between?(11, 12) || y.between?(3, 4) || y.between?(11, 12))
  when :circle
    distance_squared = (x - 7.5)**2 + (y - 7.5)**2
    distance_squared.between?(18, 36)
  end
end

# Each uiImage contains 16x16 and 32x32 RGBA representations.
make_icon = proc do |shape|
  image = UI.new_image(16, 16)
  [1, 2].each do |scale|
    size = 16 * scale
    pixels = (0...size).map do |y|
      (0...size).map { |x| drawn.call(shape, x / scale, y / scale) ? ink : transparent }.join
    end.join
    UI.image_append_rgba(image, pixels, size, size)
  end
  image
end

icons = %i[plus square circle].map { |shape| make_icon.call(shape) }
new_icon, open_icon, pin_icon = icons

window = UI.new_window('Toolbar', 480, 240, 1)
UI.window_set_margined(window, 1)

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
status = UI.new_label('Use the toolbar buttons above this window.')
UI.box_append(box, status, 0)

mode = UI.new_combobox
['Icons only', 'Icons and text (horizontal)', 'Icons and text (vertical)', 'Text only'].each do |name|
  UI.combobox_append(mode, name)
end
UI.box_append(box, mode, 0)

toolbar = UI.new_toolbar
UI.toolbar_set_display_mode(toolbar, UI::ToolbarDisplayModeIconAndTextVertical)

new_item = UI.toolbar_append_button(toolbar, 'New', new_icon)
UI.toolbar_item_set_tooltip(new_item, 'Start a new document')
UI.toolbar_item_on_clicked(new_item) { UI.label_set_text(status, 'New clicked') }

open_item = UI.toolbar_append_button(toolbar, 'Open', open_icon)
UI.toolbar_item_set_tooltip(open_item, 'Open a document')
UI.toolbar_item_on_clicked(open_item) do
  path = UI.open_file(window)
  UI.label_set_text(status, path || 'Open cancelled')
end

UI.toolbar_append_separator(toolbar)

pin_item = UI.toolbar_append_toggle_button(toolbar, 'Pinned', pin_icon)
UI.toolbar_item_set_tooltip(pin_item, 'Toggle the pinned state')
UI.toolbar_item_on_clicked(pin_item) do |sender|
  UI.label_set_text(status, UI.toolbar_item_checked(sender) == 1 ? 'Pinned' : 'Unpinned')
end

UI.combobox_set_selected(mode, UI::ToolbarDisplayModeIconAndTextVertical)
UI.combobox_on_selected(mode) do |sender|
  UI.toolbar_set_display_mode(toolbar, UI.combobox_selected(sender))
end

UI.window_set_child(window, box)
UI.window_set_toolbar(window, toolbar)
UI.window_on_closing(window) do
  UI.window_set_toolbar(window, nil)
  UI.free_toolbar(toolbar)
  icons.each { |icon| UI.free_image(icon) }
  UI.quit
  1
end
UI.control_show(window)

begin
  UI.main
ensure
  UI.uninit
end
