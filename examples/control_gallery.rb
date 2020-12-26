# frozen_string_literal: true

require 'libui'
UI = LibUI

init = UI.init

should_quit = proc do
  puts 'Bye Bye'
  UI.control_destroy(MAIN_WINDOW)
  UI.quit
  0
end

# File menu
menu = UI.new_menu('File')
open_menu_item = UI.menu_append_item(menu, 'Open')
UI.menu_item_on_clicked(open_menu_item) do
  puts UI.open_file(MAIN_WINDOW)
  0
end
save_menu_item = UI.menu_append_item(menu, 'Save')
UI.menu_item_on_clicked(save_menu_item) do
  puts UI.save_file(MAIN_WINDOW)
  0
end

UI.menu_append_quit_item(menu)
UI.on_should_quit(should_quit)

# Edit menu
edit_menu = UI.new_menu('Edit')
UI.menu_append_check_item(edit_menu, 'Checkable Item_')
UI.menu_append_separator(edit_menu)
disabled_item = UI.menu_append_item(edit_menu, 'Disabled Item_')
UI.menu_item_disable(disabled_item)

preferences = UI.menu_append_preferences_item(menu)

# Help menu
help_menu = UI.new_menu('Help')
UI.menu_append_item(help_menu, 'Help')
UI.menu_append_about_item(help_menu)

vbox = UI.new_vertical_box
hbox = UI.new_horizontal_box
UI.box_set_padded(vbox, 1)
UI.box_set_padded(hbox, 1)

UI.box_append(vbox, hbox, 1)

group = UI.new_group('Basic Controls')
UI.group_set_margined(group, 1)
UI.box_append(hbox, group, 0)

inner = UI.new_vertical_box
UI.box_set_padded(inner, 1)
UI.group_set_child(group, inner)

button = UI.new_button('Button')
UI.button_on_clicked(button) do
  UI.msg_box(MAIN_WINDOW, 'Information', 'You clicked the button')
  0
end
UI.box_append(inner, button, 0)

checkbox = UI.new_checkbox('Checkbox')
UI.checkbox_on_toggled(checkbox) do |ptr|
  checked = UI.checkbox_checked(ptr) == 1
  UI.window_set_title(MAIN_WINDOW, "Checkbox is #{checked}")
  UI.checkbox_set_text(ptr, "I am the checkbox (#{checked})")
  0
end
UI.box_append(inner, checkbox, 0)

UI.box_append(inner, UI.new_label('Label'), 0)
UI.box_append(inner, UI.new_horizontal_separator, 0)
UI.box_append(inner, UI.new_date_picker, 0)
UI.box_append(inner, UI.new_time_picker, 0)
UI.box_append(inner, UI.new_date_time_picker, 0)
UI.box_append(inner, UI.new_font_button, 0)
UI.box_append(inner, UI.new_color_button, 0)

inner2 = UI.new_vertical_box
UI.box_set_padded(inner2, 1)
UI.box_append(hbox, inner2, 1)

group = UI.new_group('Numbers')
UI.group_set_margined(group, 1)
UI.box_append(inner2, group, 0)

inner = UI.new_vertical_box
UI.box_set_padded(inner, 1)
UI.group_set_child(group, inner)

spinbox = UI.new_spinbox(0, 100)
UI.spinbox_set_value(spinbox, 42)
UI.spinbox_on_changed(spinbox) do |ptr|
  puts "New Spinbox value: #{UI.spinbox_value(ptr)}"
  0
end
UI.box_append(inner, spinbox, 0)

slider = UI.new_slider(0, 100)
UI.slider_on_changed(slider) do |ptr|
  puts "New Slider value: #{UI.slider_value(ptr)}"
  0
end
UI.box_append(inner, slider, 0)

progressbar = UI.new_progress_bar
UI.box_append(inner, progressbar, 0)

group = UI.new_group('Lists')
UI.group_set_margined(group, 1)
UI.box_append(inner2, group, 0)

inner = UI.new_vertical_box
UI.box_set_padded(inner, 1)
UI.group_set_child(group, inner)

cbox = UI.new_combobox
UI.combobox_append(cbox, 'combobox Item 1')
UI.combobox_append(cbox, 'combobox Item 2')
UI.combobox_append(cbox, 'combobox Item 3')
UI.box_append(inner, cbox, 0)
UI.combobox_on_selected(cbox) do |ptr|
  puts "New combobox selection: #{UI.combobox_selected(ptr)}"
end

ebox = UI.new_editable_combobox
UI.editable_combobox_append(ebox, 'Editable Item 1')
UI.editable_combobox_append(ebox, 'Editable Item 2')
UI.editable_combobox_append(ebox, 'Editable Item 3')
UI.box_append(inner, ebox, 0)

rb = UI.new_radio_buttons
UI.radio_buttons_append(rb, 'Radio Button 1')
UI.radio_buttons_append(rb, 'Radio Button 2')
UI.radio_buttons_append(rb, 'Radio Button 3')
UI.box_append(inner, rb, 1)

tab = UI.new_tab
hbox1 = UI.new_horizontal_box
UI.tab_append(tab, 'Page 1', hbox1)
UI.tab_append(tab, 'Page 2', UI.new_horizontal_box)
UI.tab_append(tab, 'Page 3', UI.new_horizontal_box)
UI.box_append(inner2, tab, 1)

text_entry = UI.new_entry
UI.entry_set_text text_entry, 'Please enter your feeli/ngs'
UI.entry_on_changed(text_entry) do |ptr|
  puts "Current textbox data: '#{UI.entry_text(ptr)}'"
end
UI.box_append(hbox1, text_entry, 1)

MAIN_WINDOW = UI.new_window('hello world', 600, 600, 1)
UI.window_set_margined(MAIN_WINDOW, 1)
UI.window_set_child(MAIN_WINDOW, vbox)

UI.window_on_closing(MAIN_WINDOW, should_quit)
UI.control_show(MAIN_WINDOW)

UI.main
UI.quit
