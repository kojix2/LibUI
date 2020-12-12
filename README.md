# libui

![build](https://github.com/kojix2/libui/workflows/build/badge.svg)
[![Gem Version](https://badge.fury.io/rb/libui.svg)](https://badge.fury.io/rb/libui)

:radio_button: [libui](https://github.com/andlabs/libui) - a portable GUI library -for Ruby

## Installation

```sh
gem install libui --pre
```

The libui gem package contains the official release of the libui shared library version 4.1 for Windows, Mac, and Linux.

## Usage

```ruby
require 'libui'
UI = LibUI

UI.init

main_window = UI.new_window('hello world', 300, 200, 1)
UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.control_destroy(main_window)
  UI.quit
  0
end

button = UI.new_button('Button')
UI.button_on_clicked(button) do
  UI.msg_box(main_window, 'Information', 'You clicked the button')
  0
end

UI.window_set_child(main_window, button)
UI.control_show(main_window)

UI.main
UI.quit
```

See [examples](https://github.com/kojix2/libui/tree/main/examples) directory.

## Development

```sh
git clone https://github.com/kojix2/libui
cd libui
bundle install
bundle exec rake vendor:all
bundle exec rake test
```

* Keep it simple.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/libui.

## Acknowledgement

This project is inspired by libui-ruby.

* https://github.com/jamescook/libui-ruby

While libui-ruby uses [Ruby-FFI](https://github.com/ffi/ffi), this gem uses [Fiddle](https://github.com/ruby/fiddle).

## License

[MIT License](https://opensource.org/licenses/MIT).
