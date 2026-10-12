require 'libui'

UI = LibUI

UI.init

main_window = UI.new_window('Animal sounds', 300, 200, 1)

hbox = UI.new_horizontal_box
UI.window_set_child(main_window, hbox)

data = [
  %w[cat meow],
  %w[dog woof],
  %w[chicken cock-a-doodle-doo],
  %w[horse neigh],
  %w[cow moo]
]

model = UI::TableModel.new(column_types: [UI::TableValueTypeString] * 2, rows: data)
table = UI.new_table(model: model)
UI.table_append_text_column(table, 'Animal', 0, -1)
UI.table_append_text_column(table, 'Description', 1, -1)
UI.table_set_selection_mode(table, UI::TableSelectionModeZeroOrMany)
UI.table_set_selection(table, [1, 3])

UI.box_append(hbox, table, 1)
UI.control_show(main_window)

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

UI.main
model.free
UI.uninit
