# LibUI

[![test](https://github.com/kojix2/LibUI/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/LibUI/actions/workflows/test.yml)
[![Gem Version](https://img.shields.io/badge/dynamic/json?label=gem%20version&query=%24%5B0%5D.number&url=https%3A%2F%2Frubygems.org%2Fapi%2Fv1%2Fversions%2Flibui.json&color=brightgreen)](https://rubygems.org/gems/libui/versions)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2FLibUI%2Flines)](https://tokei.kojix2.net/github/kojix2/LibUI)
<a href="https://github.com/AndyObtiva/glimmer-dsl-libui"><img alt="glimmer-dsl-libui" src="https://github.com/AndyObtiva/glimmer/blob/master/images/glimmer-logo-hi-res.svg" width="50" height="50" align="right"></a>

LibUI is a Ruby wrapper for libui family.

:rocket: [libui-ng](https://github.com/kojix2/libui-ng) - A cross-platform portable GUI library

## Installation

```sh
gem install libui # --pre
```

- The gem package includes the libui-ng shared library for Windows, Mac, and Linux.
  - Namely `libui.x64.dll`/`libui.x86.dll`, `libui.x86_64.dylib`/`libui.arm64.dylib`, or `libui.x86_64.so`/`libui.aarch64.so`.
- No dependencies required.
  - The libui gem uses the standard Ruby library [Fiddle](https://github.com/ruby/fiddle) to call C functions.

| Windows                                                                                                          | Mac                                                                                                              | Linux                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| <img src="https://user-images.githubusercontent.com/5798442/103118046-900ea780-46b0-11eb-81fc-32626762e4df.png"> | <img src="https://user-images.githubusercontent.com/5798442/103118059-99980f80-46b0-11eb-9d12-324ec4d297c9.png"> | <img src="https://user-images.githubusercontent.com/5798442/103118068-a0bf1d80-46b0-11eb-8c5c-3bdcc3dcfb26.png"> |

Notes:

- If you are using the 32-bit (x86) version of Ruby, you need to download the 32-bit (x86) native dll. See the [Development](#development) section.
- On Windows, libui may not work due to missing DLLs. In that case, you need to install [Visual C++ Redistributable](https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist). See ([#48](https://github.com/kojix2/LibUI/issues/48))
- Users with [Raspberry Pi](https://www.raspberrypi.com/) or other platforms will need to compile the C libui library. See the [Development](#development) section.

## Usage

```ruby
require 'libui'

UI = LibUI

UI.init

main_window = UI.new_window('hello world', 200, 100, 1)

button = UI.new_button('Button')

UI.button_on_clicked(button) do
  UI.msg_box(main_window, 'Information', 'You clicked the button')
end

UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

UI.window_set_child(main_window, button)
UI.control_show(main_window)

UI.main
UI.quit
```

For more examples, see the [examples](https://github.com/kojix2/libui/tree/main/examples) directory.

### General Rules

Compared to the original libui library written in C:

- Method names use snake_case.
- The last argument can be omitted if it's nil.
- A block can be passed as a callback.
  - The block will be converted to a Proc object and added as the last argument.
  - The last argument can still be omitted when nil.

You can use [the libui-ng API documentation](https://libui-ng.github.io/libui-ng/) as a reference.

### DSLs for LibUI

LibUI is not object-oriented because it is a thin Ruby wrapper (binding) for the procedural C libui library, mirroring its API structure.

To build actual applications, it is recommended to use a DSL for LibUI, as they enable writing object-oriented code the Ruby way (instead of procedural code the C way):

- [Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui)

### Working with fiddle pointers

```ruby
require 'libui'
UI = LibUI
UI.init
```

Text getters such as `label_text`, `entry_text`, and `window_title` return Ruby
strings. The wrapper releases libui-ng's copy after reading it. File dialogs
(`open_file`, `open_folder`, and `save_file`) return a path string, or `nil` if
the dialog is canceled.

`LibUI.version` returns the loaded libui-ng build identifier as a Ruby string.
`LibUI::VERSION` is the gem version.
`toolbar_item_text` and `toolbar_item_tooltip` also return Ruby strings.

```ruby
label = UI.new_label("Ruby")
p UI.label_text(label) # Ruby
```

Size and color getters return arrays. Table selection methods use arrays of
row indices; pass `[]` to clear the selection:

```ruby
width, height = UI.window_content_size(window)
red, green, blue, alpha = UI.color_button_color(color_button)
rows = UI.table_get_selection(table)
UI.table_set_selection(table, [1, 3])
UI.table_set_selection(table, [])
```

Selected row indices must be within the table model. The table's selection
mode determines how many rows can be selected. Native `uiTableSelection`
arguments remain supported.

`attribute_underline_color` returns `[underline, red, green, blue, alpha]`.
`draw_matrix_transform_point` and `draw_matrix_transform_size` accept numeric
coordinates and return a pair. `open_type_features_get` returns the feature
value, or `nil` when the tag is absent.

`open_type_features_for_each` yields a four-byte tag and its value. Use
`attribute_features` for an independent Ruby hash. The attribute iterator
copies values before yielding `{type:, value:}, start_byte, end_byte`.
libui-ng has no getter for a background attribute's color, so its snapshot
has `value: nil`. Return `LibUI::ForEachStop` to stop an iterator early.

`image_append` checks the dimensions, stride, and known buffer length. It
expects premultiplied RGBA bytes. For ordinary straight RGBA data from a PNG
decoder, use `image_append_rgba(image, bytes, width, height)`; it converts a
copy before calling libui-ng.

Date and time picker methods use Ruby objects directly. The getter returns a
local `Time`; the setter accepts `Time`, `DateTime`, or `Date`:

```ruby
UI.date_time_picker_set_time(picker, Time.now)
selected = UI.date_time_picker_time(picker)
```

The picker stores whole seconds. For date-only and time-only pickers, only the
displayed fields should be used; libui-ng does not specify the other fields.

Use `LibUI::FFI` for the original pointer based C API when needed.

`LibUI::Font` stores a reusable font value. `font_button_font` and
`load_control_font` return it and release libui-ng's descriptor internally.
The same value can be passed to a text layout:

```ruby
font_button = UI.new_font_button
font = UI.font_button_font(font_button)
p font.to_h # family, size, weight, italic, stretch
attributed_string = UI.new_attributed_string('Hello')
layout = UI.draw_new_text_layout(attributed_string, font: font, width: 300)
UI.draw_free_text_layout(layout)
UI.free_attributed_string(attributed_string)
```

Use `UI::Font.new(family: 'Georgia', size: 13)` to specify a font directly.
The default weight, italic, and stretch are normal. The original descriptor
arguments remain supported, and `LibUI::FFI` exposes the raw C API.

For a custom drawing area, `LibUI::AreaHandler` owns the Fiddle closures and
native handler struct. `new_area` and `new_scrolling_area` keep the handler
alive until the area is destroyed. Event fields are copied to Ruby objects;
the draw context is usable only during the draw callback.

```ruby
handler = UI::AreaHandler.new(draw: ->(event) {
  path = UI.draw_new_path(UI::DrawFillModeWinding)
  UI.draw_path_add_rectangle(path, 0, 0, event.area_width, event.area_height)
  UI.draw_path_end(path)
  event.context.fill(path, brush)
  UI.draw_free_path(path)
})
area = UI.new_area(handler)
```

`LibUI::TableModel` builds and retains a native table model handler from Ruby
rows and column types. `new_table(model: model)` keeps it alive while the table
exists. Free the model after destroying the table. Cell callbacks create fresh
`uiTableValue` objects, transferring those objects to libui-ng; image values
refer to images you own and must keep valid during use.

```ruby
rows = [%w[cat meow], %w[dog woof]]
model = UI::TableModel.new(column_types: [UI::TableValueTypeString] * 2,
                           rows: rows)
table = UI.new_table(model: model)
UI.table_append_text_column(table, 'Animal', 0, -1)
UI.table_append_text_column(table, 'Sound', 1, -1)
# After the table is destroyed:
model.free
```

Pass `cell_value:` and `set_cell_value:` callbacks to `TableModel.new` for a
custom data source. The setter receives copied Ruby values, or `nil` for a
button click. `row_inserted`, `row_changed`, and `row_deleted` notify tables
after the backing data changes. Text, image-text, and checkbox-text column
methods accept `color_model_column:` in place of a native optional-params
struct. Existing native structs and positional arguments remain accepted.

Ruby blocks passed to event methods are kept alive while their native control
exists. Replacing an event callback releases the previous closure. The
registry uses `uiControlOnDestroyed` to clear callbacks when a control is
destroyed, including when its parent destroys it. A user callback registered
with `control_on_destroyed` runs through the same notification. `queue_main`
callbacks are released after running; timers are released when they return
zero or `false`. Callback exceptions are reported to stderr and do not cross
the C callback boundary. Callbacks for raw `LibUI::FFI` structs still need
their own Ruby references:

```ruby
# Assign to a local variable to prevent it from being collected by GC.
handler.MouseEvent   = (c1 = Fiddle::Closure::BlockCaller.new(0, [0]) {})
handler.MouseCrossed = (c2 = Fiddle::Closure::BlockCaller.new(0, [0]) {})
handler.DragBroken   = (c3 = Fiddle::Closure::BlockCaller.new(0, [0]) {})
```

### Creating a Windows executable (.exe) with OCRA

OCRA (One-Click Ruby Application) builds Windows executables from Ruby source code.

- https://github.com/larsch/ocra/

To build an exe with Ocra, include 3 DLLs from the ruby_builtin_dlls folder:

```sh
ocra examples/control_gallery.rb        ^
  --dll ruby_builtin_dlls/libssp-0.dll  ^
  --dll ruby_builtin_dlls/libgmp-10.dll ^
  --dll ruby_builtin_dlls/libffi-7.dll  ^
  --gem-all=fiddle                      ^
```

Add additional options below if necessary:

```sh
  --window                              ^
  --add-all-core                        ^
  --chdir-first                         ^
  --icon assets\app.ico                 ^
  --verbose                             ^
  --output out\gallery.exe
```

## Development

```sh
git clone https://github.com/kojix2/libui
cd libui
bundle install
bundle exec rake vendor:auto
bundle exec rake test
```

JRuby on macOS needs Java and AppKit must start on the first thread:

```sh
export JAVA_HOME=/path/to/openjdk
export JRUBY_OPTS=-J-XstartOnFirstThread
jruby -Ilib examples/basic_button.rb
jruby -S rake test
```

Take note that, as the above code shows, LibUI works via jruby as well, so you have an additional
GUI library (aside from jruby-swing by default) to test simple User Interfaces too.

### Pre-built shared libraries for libui-ng

Download pre-built libui-ng shared libraries (per your current platform):

```sh
bundle exec rake vendor:auto
```

Clean downloaded vendor files (keeps `vendor/{LICENSE,README}.md`):

```sh
bundle exec rake vendor:clean
```

### Using your own libui build

If you build libui-ng yourself, set `LIBUIDIR` to the directory containing the compiled `.so/.dylib/.dll` so LibUI can load it. You may also replace files under `vendor/` with your build if preferred. See [#46](https://github.com/kojix2/LibUI/issues/46#issuecomment-1041575792).

### Publishing gems

#### Automated Publishing

Push a version tag to automatically publish platform-specific gems:

```sh
git tag v0.2.0
git push origin v0.2.0
```

Requires `RUBYGEMS_API_KEY` repository secret with scoped API key.

#### Manual Publishing

```sh
ls vendor             # check the vendor directory
rm -rf pkg            # remove previously built gems
rake build_platform   # build gems

# Check the contents of the gem
find pkg -name *.gem -exec sh -c "echo; echo \# {}; tar -O -f {} -x data.tar.gz | tar zt" \;

rake release_platform # publish gems
```

Windows Ruby (x64-mingw32 or x64-mingw-ucrt)

```sh
gem install rake rubyzip
GEM_PLATFORM=x64-mingw32 rake vendor:clean
GEM_PLATFORM=x64-mingw32 rake vendor:auto
GEM_PLATFORM=x64-mingw32 gem build libui.gemspec
gem push libui-0.2.0-x64-mingw32.gem
```

### libui or libui-ng

- From version 0.1.X, LibUI supports only libui-ng.
- Version 0.0.X only supports andlabs/libui.

## Contributing

Would you like to contribute to LibUI?

- Please feel free to send us your [pull requests](https://github.com/kojix2/libui/pulls).
  - Small corrections, such as typo fixes, are appreciated.
- Did you find any bugs? Submit them in the [issues](https://github.com/kojix2/LibUI/issues) section!

Do you need commit rights?

- If you need commit rights to my repository or want to get admin rights and take over the project, please feel free to contact @kojix2.
- Many OSS projects become abandoned because only the founder has commit rights to the original repository.

Support libui-ng development

- Contributing to the development of libui-ng is a contribution to the entire libui community, including Ruby's LibUI.
- For example, it would be easier to release LibUI in Ruby if libui-ng could be built easily and official shared libraries could be distributed.

## Acknowledgements

This project is inspired by libui-ruby.

- https://github.com/jamescook/libui-ruby

While libui-ruby uses [Ruby-FFI](https://github.com/ffi/ffi), this gem uses [Fiddle](https://github.com/ruby/fiddle).

## License

[MIT License](https://opensource.org/licenses/MIT).
