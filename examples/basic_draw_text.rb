require 'libui'

UI = LibUI

UI.init

# Michael Ende (1929-1995)
# The Neverending Story is a fantasy novel by German writer Michael Ende,
# The English version, translated by Ralph Manheim, was published in 1983.

TITLE = 'Michael Ende (1929-1995) The Neverending Story'

str1 = \
  '  At last Ygramul sensed that something was coming toward ' \
  'her. With the speed of lightning, she turned about, confronting ' \
  'Atreyu with an enormous steel-blue face. Her single eye had a ' \
  'vertical pupil, which stared at Atreyu with inconceivable malignancy. '

str2 = \
  '  A cry of fear escaped Bastian. '

str3 = \
  '  A cry of terror passed through the ravine and echoed from ' \
  'side to side. Ygramul turned her eye to left and right, to see if ' \
  'someone else had arrived, for that sound could not have been ' \
  'made by the boy who stood there as though paralyzed with ' \
  'horror. '

str4 = \
  '  Could she have heard my cry? Bastion wondered in alarm. ' \
  "But that's not possible. "

str5 = \
  '  And then Atreyu heard Ygramuls voice. It was very high ' \
  'and slightly hoarse, not at all the right kind of voice for that ' \
  'enormous face. Her lips did not move as she spoke. It was the ' \
  'buzzing of a great swarm of hornets that shaped itself into ' \
  'words. '

str = ''
attr_str = UI.new_attributed_string(str)

def attr_str.append(what, color)
  c = case color
      when :red
        [0.0, 0.5, 0.0, 0.7]
      when :green
        [0.5, 0.0, 0.25, 0.7]
      end
  color_attribute = UI.new_color_attribute(*c)
  start = UI.attributed_string_len(self)
  UI.attributed_string_append_unattributed(self, what)
  UI.attributed_string_set_attribute(self, color_attribute, start, start + what.size)
  UI.attributed_string_append_unattributed(self, "\n\n")
end

attr_str.append(str1, :green)
attr_str.append(str2, :red)
attr_str.append(str3, :green)
attr_str.append(str4, :red)
attr_str.append(str5, :green)

default_font = UI::Font.new(family: 'Georgia', size: 13, weight: 500)

handler = UI::AreaHandler.new(draw: ->(event) do
  text_layout = UI.draw_new_text_layout(
    attr_str, font: default_font, width: event.area_width
  )
  begin
    event.context.draw_text(text_layout, 0, 0)
  ensure
    UI.draw_free_text_layout(text_layout)
  end
end)
area = UI.new_area(handler)

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.box_append(box, area, 1)

main_window = UI.new_window(TITLE, 600, 400, 1)
UI.window_set_margined(main_window, 1)
UI.window_set_child(main_window, box)

UI.window_on_closing(main_window) do
  UI.quit
  1
end
UI.control_show(main_window)

UI.main
UI.free_attributed_string(attr_str)
UI.uninit
