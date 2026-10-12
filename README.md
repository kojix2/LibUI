# LibUI

[![Tests](https://github.com/kojix2/LibUI/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/LibUI/actions/workflows/test.yml)
[![Gem Version](https://img.shields.io/gem/v/libui)](https://rubygems.org/gems/libui)

LibUI is a procedural Ruby binding for [libui-ng](https://github.com/libui-ng/libui-ng),
a native GUI library for Windows, macOS, and Linux. It uses
[Fiddle](https://github.com/ruby/fiddle) and keeps the C API's names and
structure, with Ruby-friendly values where they help.

## Screenshots

| Windows | macOS | Linux |
| --- | --- | --- |
| <img alt="LibUI window on Windows" src="https://user-images.githubusercontent.com/5798442/103118046-900ea780-46b0-11eb-81fc-32626762e4df.png"> | <img alt="LibUI window on macOS" src="https://user-images.githubusercontent.com/5798442/103118059-99980f80-46b0-11eb-9d12-324ec4d297c9.png"> | <img alt="LibUI window on Linux" src="https://user-images.githubusercontent.com/5798442/103118068-a0bf1d80-46b0-11eb-8c5c-3bdcc3dcfb26.png"> |

## Install

```sh
gem install libui
```

To install a prerelease version, use `gem install libui --pre`. Gems for
supported platforms include the libui-ng shared library. For a local libui-ng
build, set `LIBUIDIR` to the directory containing its `.dll`, `.dylib`, or
`.so` file. On Windows, the library may also need the
[Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist).

## Quick start

```ruby
require 'libui'

UI = LibUI
UI.init

window = UI.new_window('Hello', 300, 100, 0)
button = UI.new_button('Click me')
UI.button_on_clicked(button) do
  UI.msg_box(window, 'Hello', 'Button clicked')
end
UI.window_set_child(window, button)
UI.window_on_closing(window) do
  UI.quit
  1
end

UI.control_show(window)
UI.main
UI.uninit
```

Run the example with `ruby hello.rb`. Explore [examples](examples) for
individual controls and [examples2](examples2) for larger applications.

## API

Names follow libui-ng with `ui` removed and CamelCase converted to
`snake_case`: `uiNewWindow` becomes `LibUI.new_window`. Event callbacks accept
a block or `Proc`; LibUI retains them for the native owner's lifetime. The
[libui-ng API reference](https://libui-ng.github.io/libui-ng/) documents the
underlying controls and functions. `LibUI::FFI` exposes the original C bindings
when needed.

### Ruby values

Native controls, images, attributes, and text layouts are still represented by
Fiddle pointers. Common getters and setters use Ruby values:

- Text and file dialog results are strings; a canceled file dialog returns `nil`.
- Size, position, color, and table selection results are arrays.
- Date and time picker methods use Ruby `Time`, `DateTime`, or `Date` values.
- Font getters return `LibUI::Font` values.

For example, inside a running UI session:

```ruby
width, height = UI.window_content_size(window)
rows = UI.table_get_selection(table)
UI.table_set_selection(table, [1, 3])
UI.table_set_selection(table, []) # Clear the selection

path = UI.open_file(window) # A String, or nil if canceled
UI.date_time_picker_set_time(picker, Time.now)
selected_time = UI.date_time_picker_time(picker)
```

Selection indices must exist in the table model; the selection mode controls
how many rows may be selected. `LibUI.version` returns the loaded libui-ng build
identifier as a string; `LibUI::VERSION` is the gem version.

### Drawing and tables

The Ruby value classes `Font`, `Brush`, `StrokeParams`, and `Matrix` hide native
structs. `AreaHandler` and `TableModel` manage their callbacks. A drawing area
can use Ruby objects instead of manually allocating native structs:

```ruby
brush = UI::Brush.new(color: [0.4, 0.4, 0.8, 1.0])
handler = UI::AreaHandler.new(draw: ->(event) do
  UI::Path.open do |path|
    path.add_rectangle(0, 0, event.area_width, event.area_height).end_path
    event.context.fill(path, brush)
  end
end)
area = UI.new_area(handler)
```

`Path.open` frees the drawing path when the block exits. For a table, provide
Ruby rows and their libui-ng column types:

```ruby
rows = [%w[cat meow], %w[dog woof]]
model = UI::TableModel.new(column_types: [UI::TableValueTypeString] * 2,
                           rows: rows)
table = UI.new_table(model: model)
UI.table_append_text_column(table, 'Animal', 0, -1)
UI.table_append_text_column(table, 'Sound', 1, -1)
# After destroying the table: model.free
```

See [basic_area.rb](examples/basic_area.rb),
[basic_draw_text.rb](examples/basic_draw_text.rb), and
[basic_table.rb](examples/basic_table.rb) for complete programs.

### Images

Apart from library configuration, **`image_append_rgba` is the only procedural
helper without a direct C counterpart**. The C API's `uiImageAppend` requires
premultiplied RGBA bytes; `LibUI.image_append` has the same requirement.
`image_append_rgba(image, bytes, width, height)` accepts ordinary RGBA bytes,
converts a copy, and calls `image_append`:

```ruby
image = UI.new_image(width, height)
UI.image_append_rgba(image, rgba_bytes, width, height)
```

See [basic_table_image.rb](examples/basic_table_image.rb) for an example using
PNG data in a table.

## Ownership

Native controls follow libui-ng's parent-child ownership rules. Destroy a
top-level control with `control_destroy`; destroying a parent also destroys its
children. Standalone resources such as images and text layouts have matching
`free_*` methods. Free a `TableModel` after the table using it has been
destroyed. `Path.open` handles path cleanup.

## Development

```sh
git clone https://github.com/kojix2/LibUI.git
cd LibUI
bundle install
bundle exec rake vendor:auto
bundle exec rake test
```

The tests need a GUI display. On macOS with JRuby, set
`JRUBY_OPTS=-J-XstartOnFirstThread`. `bundle exec rake vendor:clean` removes
downloaded binaries. The [RubyGems release workflow](.github/workflows/release-rubygems.yml)
builds and publishes gems from version tags using trusted publishing.

## Related projects and contributing

For an object-oriented DSL built on LibUI, see
[Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui).
LibUI was inspired by [libui-ruby](https://github.com/jamescook/libui-ruby).
Bug reports and pull requests are welcome in the
[GitHub repository](https://github.com/kojix2/LibUI).

## License

[MIT](LICENSE.txt)
