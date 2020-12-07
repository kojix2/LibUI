require "libui"
UI = LibUI

options =  UI::FFI::InitOptions.malloc
init    =  UI::FFI.uiInit(options)

unless init.size.zero?
  warn 'error'
  warn UI::FFI.uiFreeInitError(init)
end

should_quit = Fiddle::Closure::BlockCaller.new(0, []) do
  puts 'Bye Bye'
  UI::FFI.uiControlDestroy(MAIN_WINDOW)
  UI::FFI.uiQuit
  0
end

checkbox_toggle = Fiddle::Closure::BlockCaller.new(0, []) do
  checked = UI::FFI.uiCheckboxChecked(ptr) == 1
  UI::FFI.uiWindowSetTitle(MAIN_WINDOW, "Checkbox is #{checked}")
  UI::FFI.uiCheckboxSetText(ptr, "I am the checkbox (#{checked})")
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
menu = UI::FFI.uiNewMenu("File")
open_menu_item = UI::FFI.uiMenuAppendItem(menu, "Open")
UI::FFI.uiMenuItemOnClicked(open_menu_item, open_menu_item_clicked, nil)
save_menu_item = UI::FFI.uiMenuAppendItem(menu, "Save")
UI::FFI.uiMenuItemOnClicked(save_menu_item, save_menu_item_clicked, nil)
UI::FFI.uiMenuAppendQuitItem(menu)
UI::FFI.uiOnShouldQuit(should_quit, nil)

# Create 'Edit' menu
edit_menu = UI::FFI.uiNewMenu("Edit")
UI::FFI.uiMenuAppendCheckItem(edit_menu, "Checkable Item")
UI::FFI.uiMenuAppendSeparator(edit_menu)
disabled_item = UI::FFI.uiMenuAppendItem(edit_menu, "Disabled Item");
UI::FFI.uiMenuItemDisable(disabled_item);

preferences = UI::FFI.uiMenuAppendPreferencesItem(menu)

help_menu = UI::FFI.uiNewMenu("Help")
UI::FFI.uiMenuAppendItem(help_menu, "Help")
UI::FFI.uiMenuAppendAboutItem(help_menu)


vbox = UI::FFI.uiNewVerticalBox
hbox = UI::FFI.uiNewHorizontalBox
UI::FFI.uiBoxSetPadded(vbox, 1)
UI::FFI.uiBoxSetPadded(hbox, 1)

UI::FFI.uiBoxAppend(vbox, hbox , 1)

group = UI::FFI.uiNewGroup("Basic Controls")
UI::FFI.uiGroupSetMargined(group, 1)
UI::FFI.uiBoxAppend(hbox, group, 0)

inner = UI::FFI.uiNewVerticalBox
UI::FFI.uiBoxSetPadded(inner, 1)
UI::FFI.uiGroupSetChild(group, inner)

button = UI::FFI.uiNewButton("Button")
button_clicked_callback = Fiddle::Closure::BlockCaller.new(0, []) do
  UI::FFI.uiMsgBox(MAIN_WINDOW, "Information", "You clicked the button")
  0
end

UI::FFI.uiButtonOnClicked(button, button_clicked_callback, nil)
UI::FFI.uiBoxAppend(inner, button, 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewCheckbox("Checkbox"), 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewLabel("Label"), 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewHorizontalSeparator, 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewDatePicker, 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewTimePicker, 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewDateTimePicker, 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewFontButton, 0)
UI::FFI.uiBoxAppend(inner, UI::FFI.uiNewColorButton, 0)

inner2 = UI::FFI.uiNewVerticalBox
UI::FFI.uiBoxSetPadded(inner2, 1)
UI::FFI.uiBoxAppend(hbox, inner2, 1)

group = UI::FFI.uiNewGroup("Numbers")
UI::FFI.uiGroupSetMargined(group, 1)
UI::FFI.uiBoxAppend(inner2, group, 0)

inner = UI::FFI.uiNewVerticalBox
UI::FFI.uiBoxSetPadded(inner, 1)
UI::FFI.uiGroupSetChild(group, inner)

spinbox = UI::FFI.uiNewSpinbox(0, 100)
spinbox_changed_callback = Fiddle::Closure::BlockCaller.new(0, [1,1]) do |ptr|
  puts "New Spinbox value: #{UI::FFI.uiSpinboxValue(ptr)}"
  0
end
UI::FFI.uiSpinboxSetValue(spinbox,42)
UI::FFI.uiSpinboxOnChanged(spinbox, spinbox_changed_callback, nil)
UI::FFI.uiBoxAppend(inner, spinbox, 0);

slider = UI::FFI.uiNewSlider(0, 100)
slider_changed_callback = Fiddle::Closure::BlockCaller.new(0, [1,1]) do |ptr|
  puts "New Slider value: #{UI::FFI.uiSliderValue(ptr)}"
  0
end
UI::FFI.uiSliderOnChanged(slider, slider_changed_callback, nil)
UI::FFI.uiBoxAppend(inner, slider, 0)

progressbar = UI::FFI.uiNewProgressBar
UI::FFI.uiBoxAppend(inner, progressbar, 0)

group = UI::FFI.uiNewGroup("Lists")
UI::FFI.uiGroupSetMargined(group, 1)
UI::FFI.uiBoxAppend(inner2, group, 0)

inner = UI::FFI.uiNewVerticalBox
UI::FFI.uiBoxSetPadded(inner, 1)
UI::FFI.uiGroupSetChild(group, inner)

combobox_selected_callback = Fiddle::Closure::BlockCaller.new(0, [1, 1]) do |ptr|
  puts "New combobox selection: #{UI::FFI.uiComboboxSelected(ptr)}"
end
cbox = UI::FFI.uiNewCombobox
UI::FFI.uiComboboxAppend(cbox, "Combobox Item 1")
UI::FFI.uiComboboxAppend(cbox, "Combobox Item 2")
UI::FFI.uiComboboxAppend(cbox, "Combobox Item 3")
UI::FFI.uiBoxAppend(inner, cbox, 0)
UI::FFI.uiComboboxOnSelected(cbox, combobox_selected_callback, nil)

ebox = UI::FFI.uiNewEditableCombobox
UI::FFI.uiEditableComboboxAppend(ebox, "Editable Item 1")
UI::FFI.uiEditableComboboxAppend(ebox, "Editable Item 2")
UI::FFI.uiEditableComboboxAppend(ebox, "Editable Item 3")
UI::FFI.uiBoxAppend(inner, ebox, 0)

rb = UI::FFI.uiNewRadioButtons
UI::FFI.uiRadioButtonsAppend(rb, "Radio Button 1")
UI::FFI.uiRadioButtonsAppend(rb, "Radio Button 2")
UI::FFI.uiRadioButtonsAppend(rb, "Radio Button 3")
UI::FFI.uiBoxAppend(inner, rb, 1)

tab = UI::FFI.uiNewTab
hbox1 = UI::FFI.uiNewHorizontalBox 
UI::FFI.uiTabAppend(tab, "Page 1", hbox1)
UI::FFI.uiTabAppend(tab, "Page 2", UI::FFI.uiNewHorizontalBox)
UI::FFI.uiTabAppend(tab, "Page 3", UI::FFI.uiNewHorizontalBox)
UI::FFI.uiBoxAppend(inner2, tab, 1)

text_changed_callback = Fiddle::Closure::BlockCaller.new(0, [1, 1]) do |ptr|
  puts "Current textbox data: '#{UI::FFI.uiEntryText(ptr)}'"
end

text_entry = UI::FFI.uiNewEntry
UI::FFI.uiEntrySetText text_entry, "Please enter your feeli/ngs"
UI::FFI.uiEntryOnChanged(text_entry, text_changed_callback, nil)
UI::FFI.uiBoxAppend(hbox1, text_entry, 1)

MAIN_WINDOW = UI::FFI.uiNewWindow("hello world", 600, 600, 1)
UI::FFI.uiWindowSetMargined(MAIN_WINDOW, 1)
UI::FFI.uiWindowSetChild(MAIN_WINDOW, vbox)

UI::FFI.uiWindowOnClosing(MAIN_WINDOW,should_quit, nil)
UI::FFI.uiControlShow(MAIN_WINDOW)

UI::FFI.uiMain
UI::FFI.uiQuit