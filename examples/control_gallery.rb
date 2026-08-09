require 'libui'

UI = LibUI

UI.init

main_window = nil
preferences_window = nil

# File menu
file_menu = UI.new_menu('File')

open_item = UI.menu_append_item(file_menu, 'Open')
UI.menu_item_on_clicked(open_item) do |_item, window|
  text_pointer = UI.open_file(window)
  unless text_pointer.null?
    begin
      puts text_pointer.to_s
    ensure
      UI.free_text(text_pointer)
    end
  end
end

save_item = UI.menu_append_item(file_menu, 'Save')
UI.menu_item_on_clicked(save_item) do |_item, window|
  text_pointer = UI.save_file(window)
  unless text_pointer.null?
    begin
      puts text_pointer.to_s
    ensure
      UI.free_text(text_pointer)
    end
  end
end

UI.menu_append_separator(file_menu)
should_quit_item = UI.menu_append_check_item(file_menu, 'Should Quit_')
UI.menu_item_set_checked(should_quit_item, 1)
UI.menu_append_quit_item(file_menu)

UI.on_should_quit do
  if UI.menu_item_checked(should_quit_item) == 1
    puts 'Bye Bye (on_should_quit)'
    if preferences_window
      UI.control_destroy(preferences_window)
      preferences_window = nil
    end
    UI.control_destroy(main_window)
    1
  else
    UI.msg_box(main_window, 'Warning', 'Please check "Should Quit"')
    0
  end
end

preferences_item = UI.menu_append_preferences_item(file_menu)
UI.menu_item_on_clicked(preferences_item) do
  next if preferences_window

  preferences_window = UI.new_window('Preferences', 300, 200, 0)
  UI.window_set_margined(preferences_window, 1)

  preferences_box = UI.new_vertical_box
  UI.box_set_padded(preferences_box, 1)

  preferences_label = UI.new_label('Preferences')
  UI.box_append(preferences_box, preferences_label, 0)

  preferences_form = UI.new_form
  UI.form_set_padded(preferences_form, 1)
  UI.form_append(preferences_form, 'name: ', UI.new_entry, 0)
  UI.form_append(preferences_form, 'mail: ', UI.new_entry, 0)
  UI.form_append(preferences_form, 'password: ', UI.new_password_entry, 0)
  UI.box_append(preferences_box, preferences_form, 1)

  preferences_grid = UI.new_grid
  UI.grid_set_padded(preferences_grid, 1)
  6.times do |index|
    UI.grid_append(
      preferences_grid,
      UI.new_checkbox("Check #{index + 1}"),
      index % 2,
      index / 2,
      1,
      1,
      1,
      UI::AlignFill,
      1,
      UI::AlignFill
    )
  end
  UI.box_append(preferences_box, preferences_grid, 1)

  preferences_button = UI.new_button('OK')
  UI.button_on_clicked(preferences_button) do
    UI.label_set_text(preferences_label, 'Preferences saved')
  end
  UI.box_append(preferences_box, preferences_button, 0)

  UI.window_set_child(preferences_window, preferences_box)
  UI.window_on_closing(preferences_window) do
    puts 'Preferences window closed'
    preferences_window = nil
    1
  end
  UI.control_show(preferences_window)

  main_x, main_y = UI.window_position(main_window)
  main_width_pointer = Fiddle::Pointer.malloc(
    Fiddle::SIZEOF_INT,
    Fiddle::RUBY_FREE
  )
  main_height_pointer = Fiddle::Pointer.malloc(
    Fiddle::SIZEOF_INT,
    Fiddle::RUBY_FREE
  )
  UI.window_content_size(
    main_window,
    main_width_pointer,
    main_height_pointer
  )
  main_width = main_width_pointer[0, Fiddle::SIZEOF_INT].unpack1('i')
  main_height = main_height_pointer[0, Fiddle::SIZEOF_INT].unpack1('i')

  width_pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)
  height_pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)
  UI.window_content_size(preferences_window, width_pointer, height_pointer)
  width = width_pointer[0, Fiddle::SIZEOF_INT].unpack1('i')
  height = height_pointer[0, Fiddle::SIZEOF_INT].unpack1('i')

  UI.window_set_position(
    preferences_window,
    main_x + ((main_width - width) / 2),
    main_y + ((main_height - height) / 2)
  )
end

# Edit menu
edit_menu = UI.new_menu('Edit')
UI.menu_append_check_item(edit_menu, 'Checkable Item_')
UI.menu_append_separator(edit_menu)
disabled_item = UI.menu_append_item(edit_menu, 'Disabled Item_')
UI.menu_item_disable(disabled_item)

# Help menu
help_menu = UI.new_menu('Help')
UI.menu_append_item(help_menu, 'Help')
about_item = UI.menu_append_about_item(help_menu)
UI.menu_item_on_clicked(about_item) do |_item, window|
  UI.msg_box(
    window,
    'About',
    "This is a control gallery example.\nVersion: #{UI::VERSION}"
  )
end

# Main window
main_window = UI.new_window('Control Gallery', 600, 500, 1)
UI.window_set_margined(main_window, 1)
UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  if preferences_window
    UI.control_destroy(preferences_window)
    preferences_window = nil
  end
  UI.quit
  1
end

vbox = UI.new_vertical_box
UI.box_set_padded(vbox, 1)
UI.window_set_child(main_window, vbox)

hbox = UI.new_horizontal_box
UI.box_set_padded(hbox, 1)
UI.box_append(vbox, hbox, 1)

# Basic controls
basic_group = UI.new_group('Basic Controls')
UI.group_set_margined(basic_group, 1)
UI.box_append(hbox, basic_group, 1)

basic_box = UI.new_vertical_box
UI.box_set_padded(basic_box, 1)
UI.group_set_child(basic_group, basic_box)

button = UI.new_button('Button')
UI.button_on_clicked(button) do
  UI.msg_box(main_window, 'Information', 'You clicked the button')
end
UI.box_append(basic_box, button, 0)

checkbox = UI.new_checkbox('Checkbox')
UI.checkbox_on_toggled(checkbox) do |sender|
  checked = UI.checkbox_checked(sender) == 1
  UI.window_set_title(main_window, "Checkbox is #{checked}")
  UI.checkbox_set_text(sender, "I am the checkbox (#{checked})")
end
UI.box_append(basic_box, checkbox, 0)

UI.box_append(basic_box, UI.new_label('Label'), 0)
UI.box_append(basic_box, UI.new_horizontal_separator, 0)

date_picker = UI.new_date_picker
date = UI::FFI::TM.malloc
date.to_ptr.free = Fiddle::RUBY_FREE
UI.date_time_picker_on_changed(date_picker) do |sender|
  UI.date_time_picker_time(sender, date)
  puts format(
    'DatePicker changed: %04d-%02d-%02d',
    date.tm_year + 1900,
    date.tm_mon + 1,
    date.tm_mday
  )
end
UI.box_append(basic_box, date_picker, 0)

time_picker = UI.new_time_picker
time = UI::FFI::TM.malloc
time.to_ptr.free = Fiddle::RUBY_FREE
UI.date_time_picker_on_changed(time_picker) do |sender|
  UI.date_time_picker_time(sender, time)
  puts format(
    'TimePicker changed: %02d:%02d:%02d',
    time.tm_hour,
    time.tm_min,
    time.tm_sec
  )
end
UI.box_append(basic_box, time_picker, 0)

date_time_picker = UI.new_date_time_picker
date_time = UI::FFI::TM.malloc
date_time.to_ptr.free = Fiddle::RUBY_FREE
UI.date_time_picker_on_changed(date_time_picker) do |sender|
  UI.date_time_picker_time(sender, date_time)
  puts format(
    'DateTimePicker changed: %04d-%02d-%02d %02d:%02d:%02d',
    date_time.tm_year + 1900,
    date_time.tm_mon + 1,
    date_time.tm_mday,
    date_time.tm_hour,
    date_time.tm_min,
    date_time.tm_sec
  )
end
UI.box_append(basic_box, date_time_picker, 0)

font_button = UI.new_font_button
font_descriptor = UI::FFI::FontDescriptor.malloc
font_descriptor.to_ptr.free = Fiddle::RUBY_FREE
UI.font_button_on_changed(font_button) do |sender|
  UI.font_button_font(sender, font_descriptor)
  begin
    puts format(
      'Font changed: family=%s, size=%s, weight=%s, italic=%s, stretch=%s',
      font_descriptor.Family.to_s,
      font_descriptor.Size,
      font_descriptor.Weight,
      font_descriptor.Italic,
      font_descriptor.Stretch
    )
  ensure
    UI.free_font_button_font(font_descriptor)
  end
end
UI.box_append(basic_box, font_button, 0)

color_button = UI.new_color_button
color_pointers = Array.new(4) do
  Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE)
end
UI.color_button_on_changed(color_button) do |sender|
  UI.color_button_color(sender, *color_pointers)
  red, green, blue, alpha = color_pointers.map do |pointer|
    pointer[0, Fiddle::SIZEOF_DOUBLE].unpack1('d')
  end
  puts "Color changed: R=#{red}, G=#{green}, B=#{blue}, A=#{alpha}"
end
UI.box_append(basic_box, color_button, 0)

# Right column
right_column = UI.new_vertical_box
UI.box_set_padded(right_column, 1)
UI.box_append(hbox, right_column, 1)

# Numbers
numbers_group = UI.new_group('Numbers')
UI.group_set_margined(numbers_group, 1)
UI.box_append(right_column, numbers_group, 0)

numbers_box = UI.new_vertical_box
UI.box_set_padded(numbers_box, 1)
UI.group_set_child(numbers_group, numbers_box)

spinbox = UI.new_spinbox(0, 100)
UI.spinbox_set_value(spinbox, 42)
UI.spinbox_on_changed(spinbox) do |sender|
  puts "New Spinbox value: #{UI.spinbox_value(sender)}"
end
UI.box_append(numbers_box, spinbox, 0)

slider = UI.new_slider(0, 100)
progressbar = UI.new_progress_bar
UI.slider_on_changed(slider) do |sender|
  value = UI.slider_value(sender)
  puts "New Slider value: #{value}"
  UI.progress_bar_set_value(progressbar, value)
end
UI.box_append(numbers_box, slider, 0)
UI.box_append(numbers_box, progressbar, 0)

# Lists
lists_group = UI.new_group('Lists')
UI.group_set_margined(lists_group, 1)
UI.box_append(right_column, lists_group, 0)

lists_box = UI.new_vertical_box
UI.box_set_padded(lists_box, 1)
UI.group_set_child(lists_group, lists_box)

combobox = UI.new_combobox
['Combobox Item 1', 'Combobox Item 2', 'Combobox Item 3'].each do |item|
  UI.combobox_append(combobox, item)
end
UI.combobox_on_selected(combobox) do |sender|
  puts "New combobox selection: #{UI.combobox_selected(sender)}"
end
UI.box_append(lists_box, combobox, 0)

editable_combobox = UI.new_editable_combobox
['Editable Item 1', 'Editable Item 2', 'Editable Item 3'].each do |item|
  UI.editable_combobox_append(editable_combobox, item)
end
UI.editable_combobox_on_changed(editable_combobox) do |sender|
  text_pointer = UI.editable_combobox_text(sender)
  begin
    puts "Editable Combobox changed: #{text_pointer.to_s}"
  ensure
    UI.free_text(text_pointer) unless text_pointer.null?
  end
end
UI.box_append(lists_box, editable_combobox, 0)

radio_buttons = UI.new_radio_buttons
['Radio Button 1', 'Radio Button 2', 'Radio Button 3'].each do |item|
  UI.radio_buttons_append(radio_buttons, item)
end
UI.radio_buttons_on_selected(radio_buttons) do |sender|
  puts "Radio button selected: index #{UI.radio_buttons_selected(sender)}"
end
UI.box_append(lists_box, radio_buttons, 1)

# Tab
tab = UI.new_tab
page_one = UI.new_horizontal_box
UI.tab_append(tab, 'Page 1', page_one)
UI.tab_append(tab, 'Page 2', UI.new_horizontal_box)
UI.tab_append(tab, 'Page 3', UI.new_horizontal_box)
UI.tab_on_selected(tab) do |sender|
  puts "Tab selected: index #{UI.tab_selected(sender)}"
end
UI.box_append(right_column, tab, 1)

text_entry = UI.new_entry
UI.entry_set_text(text_entry, 'Please enter your feelings')
UI.entry_on_changed(text_entry) do |sender|
  text_pointer = UI.entry_text(sender)
  begin
    puts "Current textbox data: #{text_pointer.to_s}"
  ensure
    UI.free_text(text_pointer) unless text_pointer.null?
  end
end
UI.box_append(page_one, text_entry, 1)

UI.control_show(main_window)

begin
  UI.main
ensure
  UI.uninit
end
