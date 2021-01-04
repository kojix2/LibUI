# LibUI

![build](https://github.com/kojix2/libui/workflows/build/badge.svg)
[![Gem Version](https://badge.fury.io/rb/libui.svg)](https://badge.fury.io/rb/libui)

:radio_button: [libui](https://github.com/andlabs/libui) - a portable GUI library -for Ruby

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
  
### Not object oriented?

* At the moment, it is not object-oriented.
  * Instead of providing a half-baked object-oriented approach, leave it as is.

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

### How to create an executable (.exe) on Windows 

OCRA (One-Click Ruby Application) builds Windows executables from Ruby source code. 
* https://github.com/larsch/ocra/

## Development

```sh
git clone https://github.com/kojix2/libui
cd libui
bundle install
bundle exec rake vendor:all
bundle exec rake test
```

Use the following rake tasks to download the libui binary files and save them in the vendor directory.

`rake -T`

```
rake vendor:all       # Download libui.so, libui.dylib, and libui.dll to ve...
rake vendor:linux     # Download libui.so for Linux to vendor directory
rake vendor:mac       # Download libui.dylib for Mac to vendor directory
rake vendor:windows   # Download libui.dll for Windows to vendor directory
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/libui.

## Acknowledgement

This project is inspired by libui-ruby.

* https://github.com/jamescook/libui-ruby

While libui-ruby uses [Ruby-FFI](https://github.com/ffi/ffi), this gem uses [Fiddle](https://github.com/ruby/fiddle).

## License

[MIT License](https://opensource.org/licenses/MIT).
