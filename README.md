# LibUI

![build](https://github.com/kojix2/libui/workflows/build/badge.svg)
[![Gem Version](https://badge.fury.io/rb/libui.svg)](https://badge.fury.io/rb/libui)

:radio_button: [libui](https://github.com/andlabs/libui) - a portable GUI library - for Ruby

## Installation

```sh
gem install libui
```

* The gem package contains the [official release](https://github.com/andlabs/libui/releases/tag/alpha4.1) of the libui shared library versions 4.1 for Windows, Mac, and Linux. 
  * Namely `libui.dll`, `libui.dylib`, and `libui.so` (only 1.4MB in total).
* No dependency
  * The libui gem uses the standard Ruby library [Fiddle](https://github.com/ruby/fiddle) to call C functions. 

| Windows | Mac | Linux |
|---------|-----|-------|
|<img src="https://user-images.githubusercontent.com/5798442/103118046-900ea780-46b0-11eb-81fc-32626762e4df.png">|<img src="https://user-images.githubusercontent.com/5798442/103118059-99980f80-46b0-11eb-9d12-324ec4d297c9.png">|<img src="https://user-images.githubusercontent.com/5798442/103118068-a0bf1d80-46b0-11eb-8c5c-3bdcc3dcfb26.png">|

Note: If you are using the 32-bit (x86) version of Ruby, you need to download the 32-bit (x86) native dll. See [Development](#development).

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
  * Even in that case, it is possible to omit the last argument nil.

You can use [the documentation for libui's Go bindings](https://pkg.go.dev/github.com/andlabs/ui) as a reference.

### Not object oriented?

* At the moment, it is not object-oriented.
  * Instead of providing a half-baked object-oriented approach, leave it as is.

### DSLs for LibUI
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
  * In Ruby/Fiddle, C callback function is written as an object of
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

```sh
git clone https://github.com/kojix2/libui
cd libui
bundle install
bundle exec rake vendor:all_x64 # download shared libraries for all platforms
bundle exec rake test
```

You can use the following rake tasks to download the shared library required for your platform.

`rake -T`

```
rake vendor:all_x64      # Download libui.so, libui.dylib, and libui.dll to...
rake vendor:linux_x64    # Download libui.so for Linux to vendor directory
rake vendor:linux_x86    # Download libui.so for Linux to vendor directory
rake vendor:mac_x64      # Download libui.dylib for Mac to vendor directory
rake vendor:windows_x64  # Download libui.dll for Windows to vendor directory
rake vendor:windows_x86  # Download libui.dll for Windows to vendor directory
```

For example, If you are using a 32-bit (x86) version of Ruby on Windows, type `rake vendor:windows_x86`.

Or Set environment variable `LIBUIDIR` to specify the path to the shared library.

## Contributing

Would you like to add your commits to libui?
* Please feel free to send us your [pull requests](https://github.com/kojix2/libui/pulls).
  * Small corrections, such as typofixes, are appreciated.
* Did you find any bugs?　Write it in the [issues](https://github.com/kojix2/LibUI/issue) section!

## Acknowledgement

This project is inspired by libui-ruby.

* https://github.com/jamescook/libui-ruby

While libui-ruby uses [Ruby-FFI](https://github.com/ffi/ffi), this gem uses [Fiddle](https://github.com/ruby/fiddle).

## License

[MIT License](https://opensource.org/licenses/MIT).
