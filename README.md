# LibUI

![build](https://github.com/kojix2/libui/workflows/build/badge.svg)
[![Gem Version](https://badge.fury.io/rb/libui.svg)](https://badge.fury.io/rb/libui)
<a href="https://github.com/AndyObtiva/glimmer-dsl-libui"><img alt="glimmer-dsl-libui" src="https://github.com/AndyObtiva/glimmer/blob/master/images/glimmer-logo-hi-res.svg" width="50" height="50" align="right"></a>

LibUI is a Ruby wrapper for libui and libui-ng.

:rocket: [libui-ng](https://github.com/libui-ng/libui-ng) - A cross-platform portable GUI library

:radio_button: [libui](https://github.com/andlabs/libui) - Original version by andlabs

## Installation

```sh
gem install libui
```

* The gem package contains the [official release](https://github.com/andlabs/libui/releases/tag/alpha4.1) of the libui shared library versions 4.1 for Windows, Mac, and Linux. 
  * Namely `libui.dll`, `libui.dylib`, and `libui.so` (only 1.8MB in total).
* No dependency
  * The libui gem uses the standard Ruby library [Fiddle](https://github.com/ruby/fiddle) to call C functions. 

| Windows | Mac | Linux |
|---------|-----|-------|
|<img src="https://user-images.githubusercontent.com/5798442/103118046-900ea780-46b0-11eb-81fc-32626762e4df.png">|<img src="https://user-images.githubusercontent.com/5798442/103118059-99980f80-46b0-11eb-9d12-324ec4d297c9.png">|<img src="https://user-images.githubusercontent.com/5798442/103118068-a0bf1d80-46b0-11eb-8c5c-3bdcc3dcfb26.png">|

Note:
* If you are using the 32-bit (x86) version of Ruby, you need to download the 32-bit (x86) native dll. See [Development](#development).
* On Windows, libui may not work due to missing DLLs. In that case, you need to install [Visual C++ Redistributable](https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist). See ([#48](https://github.com/kojix2/LibUI/issues/48))
* [Raspberry Pi](https://www.raspberrypi.com/) and other platform users will need to compile C libui. See [Development](#development).

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

See [examples](https://github.com/kojix2/libui/tree/main/examples) directory.

### General Rules

Compared to original libui written in C,

* The method names are snake_case.
* If the last argument is nil, it can be omitted.
* You can pass a block as a callback. 
  * The block will be converted to a Proc object and added to the last argument.
  * Even in that case, it is possible to omit the last argument when nil.

You can use [the documentation for libui's Go bindings](https://pkg.go.dev/github.com/andlabs/ui) as a reference.

### DSLs for LibUI

LibUI is intentionally not object-oriented because it is a thin Ruby wrapper (binding) for the procedural C libui library, so it mirrors its API structure.

It is recommended that you build actual applications using a DSL for LibUI because DSLs enable writing object-oriented code the Ruby way (instead of procedural code the C way):

* [Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui)
* [libui_paradise](https://rubygems.org/gems/libui_paradise)

### How to use fiddle pointers?

```ruby
require 'libui'
UI = LibUI
UI.init
```

Convert a pointer to a string.

```ruby
label = UI.new_label("Ruby")
p pointer = UI.label_text(label) # #<Fiddle::Pointer>
p pointer.to_s # Ruby
```

If you need to use C structs, you can do the following.

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

* Callbacks
  * In Ruby/Fiddle, a C callback function is written as an object of
    `Fiddle::Closure::BlockCaller` or `Fiddle::Closure`. 
    In this case, you need to be careful about Ruby's garbage collection. 
    If the function object is collected, memory will be freed 
    and a segmentation violation will occur when the callback is invoked.

```ruby
# to a local variable to prevent it from being collected by GC.
handler.MouseEvent   = (c1 = Fiddle::Closure::BlockCaller.new(0, [0]) {})
handler.MouseCrossed = (c2 = Fiddle::Closure::BlockCaller.new(0, [0]) {})
handler.DragBroken   = (c3 = Fiddle::Closure::BlockCaller.new(0, [0]) {})
```

### How to create an executable (.exe) on Windows 

OCRA (One-Click Ruby Application) builds Windows executables from Ruby source code. 
* https://github.com/larsch/ocra/

In order to build a exe with Ocra, include 3 DLLs from ruby_builtin_dlls folder:

```sh
ocra examples/control_gallery.rb        ^
  --dll ruby_builtin_dlls/libssp-0.dll  ^
  --dll ruby_builtin_dlls/libgmp-10.dll ^
  --dll ruby_builtin_dlls/libffi-7.dll  ^
  --gem-all=fiddle                      ^
```

Add additional options below if necessary.

```sh
  --window                              ^
  --add-all-core                        ^
  --chdir-first                         ^
  --icon assets\app.ico                 ^
  --verbose                             ^
  --output out\gallery.exe
```

## Development

LibUI is not object-oriented, but it provides high portability with a minimal implementation. 

```sh
git clone https://github.com/kojix2/libui
cd libui
bundle install
bundle exec rake vendor:default # download shared libraries for all platforms
bundle exec rake test
```

You can use the following rake tasks to download the shared library required for your platform.

`rake -T`

```
rake vendor:kojix2:auto           # Download kojix2 pre-build for your platform to vendor directory
rake vendor:kojix2:mac            # Download kojix2 pre-build for Mac to vendor directory
rake vendor:kojix2:ubuntu_x64     # Download kojix2 pre-build for Ubuntu to vendor directory
rake vendor:kojix2:windows_x64    # Download kojix2 pre-build for Windows to vendor directory
rake vendor:kojix2:windows_x86    # Download kojix2 pre-build for Windows to vendor directory
rake vendor:libui-ng:build[hash]  # Build libui-ng latest master [commit hash]
rake vendor:libui-ng:mac          # Download latest dev build for Mac to vendor directory
rake vendor:libui-ng:ubuntu_x64   # Download latest dev build for Ubuntu to vendor directory
```

For example, If you are using a 32-bit (x86) version of Ruby on Windows, type `vendor:kojix2:windows_x86`.
These shared libraries are built using Github Actions; if the pre-build branch of kojix2/libui-ng is not updated for 3 months, it will not be available for download. Please let me know when that happens.

### Use C libui compiled from source code

You can compile C libui from source code on your platform and tell ruby LibUI where to find the shared libraries. Set environment variable `LIBUIDIR` to specify the path to the shared library. (See [#46](https://github.com/kojix2/LibUI/issues/46#issuecomment-1041575792)). This is especially useful on platforms where the LibUI gem does not provide shared library, such as the ARM architecture (used in devices like Raspberry Pi).

Another simple approach is to replace the shared libraries in the gem vendor directory with the ones you have compiled.

### Publish gems

```sh
ls vendor             # check the vendor directory
rm -rf pkg            # removed previously built gems
rake build_platform
rake release_platform 
```

### libui or libui-ng

* From version 0.1.X, we plan to support only libui-ng/libui-ng.
* Version 0.0.X only supports andlabs/libui. 

## Contributing

Would you like to add your commits to libui?
* Please feel free to send us your [pull requests](https://github.com/kojix2/libui/pulls).
  * Small corrections, such as typo fixes, are appreciated.
* Did you find any bugs? Enter in the [issues](https://github.com/kojix2/LibUI/issues) section!

I have seen many OSS projects abandoned. The main reason is that no one has the right to commit to the original repository, except the founder.
Do you need commit rights to my repository? Do you want to get admin rights and take over the project? If so, please feel free to contact me @kojix2.

## Acknowledgement

This project is inspired by libui-ruby.

* https://github.com/jamescook/libui-ruby

While libui-ruby uses [Ruby-FFI](https://github.com/ffi/ffi), this gem uses [Fiddle](https://github.com/ruby/fiddle).

## License

[MIT License](https://opensource.org/licenses/MIT).
