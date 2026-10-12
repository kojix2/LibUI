# Widget examples

Each Ruby file in this directory demonstrates one widget with the current
procedural LibUI API on `main` (0.3.x). The `0.2-stable` branch maintains the
older libui-ng API compatibility line.

Run an example from the repository root after installing dependencies and the
native library:

```sh
bundle install
bundle exec rake vendor:auto
bundle exec ruby -Ilib examples2/button.rb
```

A GUI display is required. Close the example window to exit.

| Example | What it shows |
| --- | --- |
| [button.rb](button.rb) | Button text and click callback |
| [checkbox.rb](checkbox.rb) | Checked state and toggle callback |
| [color_button.rb](color_button.rb) | RGBA color as a Ruby array |
| [combobox.rb](combobox.rb) | Items and selected index |
| [date_picker.rb](date_picker.rb) | Ruby `Date` and `Time` values |
| [editable_combobox.rb](editable_combobox.rb) | Editable text |
| [entry.rb](entry.rb) | Single-line text |
| [font_button.rb](font_button.rb) | `LibUI::Font` values |
| [grid.rb](grid.rb) | Grid placement and padding |
| [multiline_entry.rb](multiline_entry.rb) | Multiline text |
| [password_entry.rb](password_entry.rb) | Password entry |
| [progress_bar.rb](progress_bar.rb) | Progress value |
| [search_entry.rb](search_entry.rb) | Search entry |
| [slider.rb](slider.rb) | Slider range and callbacks |
| [window.rb](window.rb) | Window properties and content size array |

Controls are still passed as native handles. Callbacks can be Ruby blocks or
`Proc` objects. Methods such as text, font, color, date, and size getters return
Ruby values; the examples use those values directly.

For drawing, tables, images, and larger applications, see [../examples](../examples).
