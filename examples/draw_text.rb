require 'libui'

UI = LibUI

def append_with_attribute(attr_str, what, attr1, attr2)
  start_pos = UI.attributed_string_len(attr_str)
  end_pos = start_pos + what.length
  UI.attributed_string_append_unattributed(attr_str, what)
  UI.attributed_string_set_attribute(attr_str, attr1, start_pos, end_pos)
  UI.attributed_string_set_attribute(attr_str, attr2, start_pos, end_pos) if attr2
end

def make_attribute_string
  attr_str = UI.new_attributed_string(
    "Drawing strings with libui is done with the uiAttributedString and uiDrawTextLayout objects.\n" \
     'uiAttributedString lets you have a variety of attributes: '
  )

  attr1 = UI.new_family_attribute('Courier New')
  append_with_attribute(attr_str, 'font family', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  attr1 = UI.new_size_attribute(18)
  append_with_attribute(attr_str, 'font size', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  attr1 = UI.new_weight_attribute(UI::TextWeightBold)
  append_with_attribute(attr_str, 'font weight', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  attr1 = UI.new_italic_attribute(UI::TextItalicItalic)
  append_with_attribute(attr_str, 'font italicness', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  attr1 = UI.new_stretch_attribute(UI::TextStretchCondensed)
  append_with_attribute(attr_str, 'font stretch', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  attr1 = UI.new_color_attribute(0.75, 0.25, 0.5, 0.75)
  append_with_attribute(attr_str, 'text color', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  attr1 = UI.new_background_attribute(0.5, 0.5, 0.25, 0.5)
  append_with_attribute(attr_str, 'text background color', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  attr1 = UI.new_underline_attribute(UI::UnderlineSingle)
  append_with_attribute(attr_str, 'underline style', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ', ')

  UI.attributed_string_append_unattributed(attr_str, 'and ')
  attr1 = UI.new_underline_attribute(UI::UnderlineDouble)
  attr2 = UI.new_underline_color_attribute(UI::UnderlineColorCustom, 1.0, 0.0, 0.5, 1.0)
  append_with_attribute(attr_str, 'underline color', attr1, attr2)
  UI.attributed_string_append_unattributed(attr_str, '. ')

  UI.attributed_string_append_unattributed(attr_str, 'Furthermore, there are attributes allowing for ')
  attr1 = UI.new_underline_attribute(UI::UnderlineSuggestion)
  attr2 = UI.new_underline_color_attribute(UI::UnderlineColorSpelling, 0, 0, 0, 0)
  append_with_attribute(attr_str, 'special underlines for indicating spelling errors', attr1, attr2)
  UI.attributed_string_append_unattributed(attr_str, ' (and other types of errors) ')

  UI.attributed_string_append_unattributed(attr_str,
                                           'and control over OpenType features such as ligatures (for instance, ')
  otf = UI.new_open_type_features
  UI.open_type_features_add(otf, 'l', 'i', 'g', 'a', 0)
  attr1 = UI.new_features_attribute(otf)
  append_with_attribute(attr_str, 'afford', attr1, nil)
  UI.attributed_string_append_unattributed(attr_str, ' vs. ')
  UI.open_type_features_add(otf, 'l', 'i', 'g', 'a', 1)
  attr1 = UI.new_features_attribute(otf)
  append_with_attribute(attr_str, 'afford', attr1, nil)
  UI.free_open_type_features(otf)
  UI.attributed_string_append_unattributed(attr_str, ").\n")

  UI.attributed_string_append_unattributed(attr_str,
                                           'Use the controls opposite to the text to control properties of the text.')
  attr_str
end

def on_font_changed(area)
  UI.area_queue_redraw_all(area)
end

def on_combobox_selected(area)
  UI.area_queue_redraw_all(area)
end

def draw_event(adp, attr_str, font_button, alignment)
  area_draw_params = UI::FFI::AreaDrawParams.new(adp)
  default_font = UI::FFI::FontDescriptor.malloc
  default_font.to_ptr.free = Fiddle::RUBY_FREE
  default_font = UI::FFI::FontDescriptor.malloc
  default_font.to_ptr.free = Fiddle::RUBY_FREE
  params = UI::FFI::DrawTextLayoutParams.malloc
  params.to_ptr.free = Fiddle::RUBY_FREE

  params.String = attr_str
  UI.font_button_font(font_button, default_font)
  params.DefaultFont = default_font
  params.Width = area_draw_params.AreaWidth
  params.Align = UI.combobox_selected(alignment)
  text_layout = UI.draw_new_text_layout(params)
  UI.draw_text(area_draw_params.Context, text_layout, 0, 0)
  UI.draw_free_text_layout(text_layout)
  UI.free_font_button_font(default_font)
end

UI.init

handler = UI::FFI::AreaHandler.malloc
handler.to_ptr.free = Fiddle::RUBY_FREE

handler_draw_event = Fiddle::Closure::BlockCaller.new(0, [1, 1, 1]) do |_, _area, adp|
  draw_event(adp, @attr_str, @font_button, @alignment)
end

handler.Draw = handler_draw_event

do_nothing = Fiddle::Closure::BlockCaller.new(0, [0]) {}
key_event  = Fiddle::Closure::BlockCaller.new(1, [0]) { 0 }
handler.MouseEvent   = do_nothing
handler.MouseCrossed = do_nothing
handler.DragBroken   = do_nothing
handler.KeyEvent     = key_event

UI.on_should_quit do
  UI.control_destroy(main_window)
end

@attr_str = make_attribute_string

main_window = UI.new_window('Text-Drawing Example', 640, 480, 1)
UI.window_set_margined(main_window, 1)
UI.window_on_closing(main_window) do
  UI.control_destroy(main_window)
  UI.quit
  0
end

hbox = UI.new_horizontal_box
UI.box_set_padded(hbox, 1)
UI.window_set_child(main_window, hbox)

vbox = UI.new_vertical_box
UI.box_set_padded(vbox, 1)
UI.box_append(hbox, vbox, 0)

@font_button = UI.new_font_button
UI.font_button_on_changed(@font_button) { on_font_changed(@area) }
UI.box_append(vbox, @font_button, 0)

form = UI.new_form
UI.form_set_padded(form, 1)
UI.box_append(vbox, form, 0)

@alignment = UI.new_combobox
UI.combobox_append(@alignment, 'Left')
UI.combobox_append(@alignment, 'Center')
UI.combobox_append(@alignment, 'Right')
UI.combobox_set_selected(@alignment, 0)
UI.combobox_on_selected(@alignment) { on_combobox_selected(@area) }
UI.form_append(form, 'Alignment', @alignment, 0)

@area = UI.new_area(handler)
UI.box_append(hbox, @area, 1)

UI.control_show(main_window)
UI.main

UI.free_attributed_string(@attr_str)
UI.uninit
