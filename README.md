# LibUI

[![test](https://github.com/kojix2/LibUI/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/LibUI/actions/workflows/test.yml)
[![Gem Version](https://badge.fury.io/rb/libui.svg)](https://badge.fury.io/rb/libui)
<a href="https://github.com/AndyObtiva/glimmer-dsl-libui"><img alt="glimmer-dsl-libui" src="https://github.com/AndyObtiva/glimmer/blob/master/images/glimmer-logo-hi-res.svg" width="50" height="50" align="right"></a>
[![Pre-build](https://github.com/kojix2/libui-ng/actions/workflows/pre-build.yml/badge.svg?branch=pre-build)](https://github.com/kojix2/libui-ng/actions/workflows/pre-build.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2FLibUI%2Flines)](https://tokei.kojix2.net/github/kojix2/LibUI)

LibUI is a Ruby wrapper for libui family.

:rocket: [libui-ng](https://github.com/libui-ng/libui-ng) - A cross-platform portable GUI library

:wrench: [libui-dev](https://github.com/petabyt/libui-dev) - Native UI library for C - with some extras

:radio_button: [libui](https://github.com/andlabs/libui) - Original version by andlabs.

## Installation

It is recommended to use libui-ng, via the --pre commandline flag:

```sh
gem install libui --pre # libui-ng; this will fetch libui-0.1.3.pre-x86_64-linux.gem
```

If for some reason you would like to install the slightly older libui-0.1.2.gem release, issue:

```sh
gem install libui
```

- The gem package includes the libui-ng shared library for Windows, Mac, and Linux.
  - Namely `libui.dll`, `libui.dylib`, or `libui.so`.
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
  UI.control_destroy(main_window)
  UI.quit
  0
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

You can use [the documentation for libui's Go bindings](https://pkg.go.dev/github.com/andlabs/ui) as a reference.

### DSLs for LibUI

LibUI is not object-oriented because it is a thin Ruby wrapper (binding) for the procedural C libui library, mirroring its API structure.

To build actual applications, it is recommended to use a DSL for LibUI, as they enable writing object-oriented code the Ruby way (instead of procedural code the C way):

- [Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui)
- [libui_paradise](https://rubygems.org/gems/libui_paradise)

### Working with fiddle pointers

```ruby
require 'libui'
UI = LibUI
UI.init
```

To convert a pointer to a string:

```ruby
label = UI.new_label("Ruby")
p pointer = UI.label_text(label) # #<Fiddle::Pointer>
p pointer.to_s # Ruby
```

If you need to use C structs, you can do the following:

```ruby
font_button = UI.new_font_button

# Allocate memory
font_descriptor = UI::FFI::FontDescriptor.malloc
font_descriptor.to_ptr.free = Fiddle::RUBY_FREE
# font_descriptor = UI::FFI::FontDescriptor.malloc(Fiddle::RUBY_FREE) # fiddle 1.0.1 or higher

UI.font_button_on_changed(font_button) do
  UI.font_button_font(font_button, font_descriptor)
  p family:  font_descriptor.Family.to_s,
    size:    font_descriptor.Size,
    weight:  font_descriptor.Weight,
    italic:  font_descriptor.Italic,
    stretch: font_descriptor.Stretch
end
```

- Callbacks
  - In Ruby/Fiddle, a C callback function is written as an object of
    `Fiddle::Closure::BlockCaller` or `Fiddle::Closure`.
    Be careful about Ruby's garbage collection - if the function object is collected, memory will be freed resulting in a segmentation violation when the callback is invoked.

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
bundle exec rake vendor:auto # vendor:build
bundle exec rake test
```

### Pre-built shared libraries for libui-ng

Use the following rake tasks to download the shared library required for your platform:

`rake -T`

```
rake vendor:build[hash]          # Build libui-ng latest master [commit hash]
rake vendor:libui-ng:macos       # Download latest official pre-build for Mac to vendor directory
rake vendor:libui-ng:ubuntu_x64  # Download latest official pre-build for Ubuntu to vendor directory
rake vendor:macos_arm64          # Download pre-build for Mac to vendor directory
rake vendor:macos_x64            # Download pre-build for Mac to vendor directory
rake vendor:raspbian_aarch64     # Download pre-build for Raspbian to vendor directory
rake vendor:ubuntu_x64           # Download pre-build for Ubuntu to vendor directory
rake vendor:windows_x64          # Download pre-build for Windows to vendor directory
rake vendor:windows_x86          # Download pre-build for Windows to vendor directory
```

For example, if you are using a 32-bit (x86) version of Ruby on Windows, type `vendor:windows_x86`.
These shared libraries are [artifacts](https://github.com/kojix2/libui-ng/actions/workflows/pre-build.yml) of the [pre-build branch](https://github.com/kojix2/libui-ng/tree/pre-build) of [kojix2/libui-ng](https://github.com/kojix2/libui-ng). In that case, please let us know.

### Using C libui compiled from source code

The following Rake task will compile libui-ng. meson or ninja is required.

`bundle exec rake vendor:build`

Alternatively, you can tell Ruby LibUI the location of shared libraries. Set the environment variable `LIBUIDIR` to specify the path to the shared library. (See [#46](https://github.com/kojix2/LibUI/issues/46#issuecomment-1041575792)). This is especially useful on platforms where the LibUI gem does not provide shared library, such as the ARM architecture (used in devices like Raspberry Pi).

Another simple approach is to replace the shared libraries in the gem vendor directory with the ones you have compiled.

### Publishing gems

#### Automated Publishing

Push a version tag to automatically publish platform-specific gems:

```sh
git tag v0.1.3
git push origin v0.1.3
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

### libui or libui-ng

- From version 0.1.X, we plan to support only libui-ng/libui-ng.
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
