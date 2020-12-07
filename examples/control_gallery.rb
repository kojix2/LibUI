require "libui"

options =  LibUI::FFI::InitOptions.malloc
init    =  LibUI::FFI.uiInit(options)

unless init.size.zero?
  warn 'error'
  warn LibUI::FFI.uiFreeInitError(init)
end

should_quit = Fiddle::Closure::BlockCaller.new(0, []) do
  puts 'Bye Bye'
  LibUI::FFI.uiControlDestroy(main_window)
  LibUI::FFI.uiQuit
  0
end

checkbox_toggle = Fiddle::Closure::BlockCaller.new(0, []) do
  checked = LibUI::FFI.uiCheckboxChecked(ptr) == 1
  LibUI::FFI.uiWindowSetTitle(MAIN_WINDOW, "Checkbox is #{checked}")
  LibUI::FFI.uiCheckboxSetText(ptr, "I am the checkbox (#{checked})")
  0
end

open_menu_item_clicked = Fiddle::Closure::BlockCaller.new(0, []) do
  puts "Clicked 'Open'"
  0
end

save_menu_item_clicked = Fiddle::Closure::BlockCaller.new(0, []) do
  puts "Clicked 'Save'"
  0
end

# Create 'File' menu with a few items and callbacks
# when the items are clicked
menu = LibUI::FFI.uiNewMenu("File")
open_menu_item = LibUI::FFI.uiMenuAppendItem(menu, "Open")
LibUI::FFI.uiMenuItemOnClicked(open_menu_item, open_menu_item_clicked, nil)
save_menu_item = LibUI::FFI.uiMenuAppendItem(menu, "Save")
LibUI::FFI.uiMenuItemOnClicked(save_menu_item, save_menu_item_clicked, nil)
LibUI::FFI.uiMenuAppendQuitItem(menu)
LibUI::FFI.uiOnShouldQuit(should_quit, nil)

# Create 'Edit' menu
edit_menu = LibUI::FFI.uiNewMenu("Edit")
LibUI::FFI.uiMenuAppendCheckItem(edit_menu, "Checkable Item")
LibUI::FFI.uiMenuAppendSeparator(edit_menu)
disabled_item = LibUI::FFI.uiMenuAppendItem(edit_menu, "Disabled Item");
LibUI::FFI.uiMenuItemDisable(disabled_item);

preferences = LibUI::FFI.uiMenuAppendPreferencesItem(menu)

help_menu = LibUI::FFI.uiNewMenu("Help")
LibUI::FFI.uiMenuAppendItem(help_menu, "Help")
LibUI::FFI.uiMenuAppendAboutItem(help_menu)


vbox = LibUI::FFI.uiNewVerticalBox
hbox = LibUI::FFI.uiNewHorizontalBox
LibUI::FFI.uiBoxSetPadded(vbox, 1)
LibUI::FFI.uiBoxSetPadded(hbox, 1)

LibUI::FFI.uiBoxAppend(vbox, hbox , 1)

group = LibUI::FFI.uiNewGroup("Basic Controls")
LibUI::FFI.uiGroupSetMargined(group, 1)
LibUI::FFI.uiBoxAppend(hbox, group, 0)

inner = LibUI::FFI.uiNewVerticalBox
LibUI::FFI.uiBoxSetPadded(inner, 1)
LibUI::FFI.uiGroupSetChild(group, inner)

button = LibUI::FFI.uiNewButton("Button")
button_clicked_callback = Fiddle::Closure::BlockCaller.new(0, []) do
  LibUI::FFI.uiMsgBox(MAIN_WINDOW, "Information", "You clicked the button")
  0
end

LibUI::FFI.uiButtonOnClicked(button, button_clicked_callback, nil)
LibUI::FFI.uiBoxAppend(inner, button, 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewCheckbox("Checkbox"), 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewLabel("Label"), 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewHorizontalSeparator, 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewDatePicker, 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewTimePicker, 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewDateTimePicker, 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewFontButton, 0)
LibUI::FFI.uiBoxAppend(inner, LibUI::FFI.uiNewColorButton, 0)

inner2 = LibUI::FFI.uiNewVerticalBox
LibUI::FFI.uiBoxSetPadded(inner2, 1)
LibUI::FFI.uiBoxAppend(hbox, inner2, 1)

group = LibUI::FFI.uiNewGroup("Numbers")
LibUI::FFI.uiGroupSetMargined(group, 1)
LibUI::FFI.uiBoxAppend(inner2, group, 0)

inner = LibUI::FFI.uiNewVerticalBox
LibUI::FFI.uiBoxSetPadded(inner, 1)
LibUI::FFI.uiGroupSetChild(group, inner)

spinbox = LibUI::FFI.uiNewSpinbox(0, 100)
spinbox_changed_callback = Fiddle::Closure::BlockCaller.new(0, [1,1]) do |ptr|
  puts "New Spinbox value: #{LibUI::FFI.uiSpinboxValue(ptr)}"
  0
end
LibUI::FFI.uiSpinboxSetValue(spinbox,42)
LibUI::FFI.uiSpinboxOnChanged(spinbox, spinbox_changed_callback, nil)
LibUI::FFI.uiBoxAppend(inner, spinbox, 0);

slider = LibUI::FFI.uiNewSlider(0, 100)
slider_changed_callback = Fiddle::Closure::BlockCaller.new(0, [1,1]) do |ptr|
  puts "New Slider value: #{LibUI::FFI.uiSliderValue(ptr)}"
  0
end
LibUI::FFI.uiSliderOnChanged(slider, slider_changed_callback, nil)
LibUI::FFI.uiBoxAppend(inner, slider, 0)

progressbar = LibUI::FFI.uiNewProgressBar
LibUI::FFI.uiBoxAppend(inner, progressbar, 0)

group = LibUI::FFI.uiNewGroup("Lists")
LibUI::FFI.uiGroupSetMargined(group, 1)
LibUI::FFI.uiBoxAppend(inner2, group, 0)

inner = LibUI::FFI.uiNewVerticalBox
LibUI::FFI.uiBoxSetPadded(inner, 1)
LibUI::FFI.uiGroupSetChild(group, inner)

combobox_selected_callback = Fiddle::Closure::BlockCaller.new(0, [1, 1]) do |ptr|
  puts "New combobox selection: #{LibUI::FFI.uiComboboxSelected(ptr)}"
end
cbox = LibUI::FFI.uiNewCombobox
LibUI::FFI.uiComboboxAppend(cbox, "Combobox Item 1")
LibUI::FFI.uiComboboxAppend(cbox, "Combobox Item 2")
LibUI::FFI.uiComboboxAppend(cbox, "Combobox Item 3")
LibUI::FFI.uiBoxAppend(inner, cbox, 0)
LibUI::FFI.uiComboboxOnSelected(cbox, combobox_selected_callback, nil)

ebox = LibUI::FFI.uiNewEditableCombobox
LibUI::FFI.uiEditableComboboxAppend(ebox, "Editable Item 1")
LibUI::FFI.uiEditableComboboxAppend(ebox, "Editable Item 2")
LibUI::FFI.uiEditableComboboxAppend(ebox, "Editable Item 3")
LibUI::FFI.uiBoxAppend(inner, ebox, 0)

rb = LibUI::FFI.uiNewRadioButtons
LibUI::FFI.uiRadioButtonsAppend(rb, "Radio Button 1")
LibUI::FFI.uiRadioButtonsAppend(rb, "Radio Button 2")
LibUI::FFI.uiRadioButtonsAppend(rb, "Radio Button 3")
LibUI::FFI.uiBoxAppend(inner, rb, 1)

tab = LibUI::FFI.uiNewTab
hbox1 = LibUI::FFI.uiNewHorizontalBox 
LibUI::FFI.uiTabAppend(tab, "Page 1", hbox1)
LibUI::FFI.uiTabAppend(tab, "Page 2", LibUI::FFI.uiNewHorizontalBox)
LibUI::FFI.uiTabAppend(tab, "Page 3", LibUI::FFI.uiNewHorizontalBox)
LibUI::FFI.uiBoxAppend(inner2, tab, 1)

text_changed_callback = Fiddle::Closure::BlockCaller.new(0, [1, 1]) do |ptr|
  puts "Current textbox data: '#{LibUI::FFI.uiEntryText(ptr)}'"
end

text_entry = LibUI::FFI.uiNewEntry
LibUI::FFI.uiEntrySetText text_entry, "Please enter your feeli/ngs"
LibUI::FFI.uiEntryOnChanged(text_entry, text_changed_callback, nil)
LibUI::FFI.uiBoxAppend(hbox1, text_entry, 1)

MAIN_WINDOW = LibUI::FFI.uiNewWindow("hello world", 600, 600, 1)
LibUI::FFI.uiWindowSetMargined(MAIN_WINDOW, 1)
LibUI::FFI.uiWindowSetChild(MAIN_WINDOW, vbox)

LibUI::FFI.uiWindowOnClosing(MAIN_WINDOW,should_quit, nil)
LibUI::FFI.uiControlShow(MAIN_WINDOW)

LibUI::FFI.uiMain
LibUI::FFI.uiQuit