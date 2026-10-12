require 'libui'

UI = LibUI

UI.init

window = UI.new_window('Font sizes', 480, 320, 1)
UI.window_set_margined(window, 1)

box = UI.new_vertical_box
UI.box_set_padded(box, 1)

label = UI.new_label('This label and the editor use the same font size.')
UI.box_append(box, label, 0)

entry = UI.new_multiline_entry
UI.multiline_entry_set_text(entry, "Change the size below.\nThe text stays editable.")
UI.box_append(box, entry, 1)

size = UI.new_spinbox(8, 36)
UI.spinbox_set_value(size, 18)
UI.box_append(box, size, 0)

status = UI.new_label('')
UI.box_append(box, status, 0)

show_sizes = proc do
  UI.label_set_text(
    status,
    "Label: #{UI.label_font_size(label)} pt; editor: #{UI.multiline_entry_font_size(entry)} pt"
  )
end

set_size = proc do |points|
  UI.label_set_font_size(label, points)
  UI.multiline_entry_set_font_size(entry, points)
  show_sizes.call
end

UI.spinbox_on_changed(size) { |sender| set_size.call(UI.spinbox_value(sender).to_f) }
set_size.call(18.0)

reset = UI.new_button('Reset to system font sizes')
UI.button_on_clicked(reset) do
  UI.label_reset_font_size(label)
  UI.multiline_entry_reset_font_size(entry)
  show_sizes.call
end
UI.box_append(box, reset, 0)

UI.window_set_child(window, box)
UI.window_on_closing(window) do
  UI.quit
  1
end
UI.control_show(window)

begin
  UI.main
ensure
  UI.uninit
end
