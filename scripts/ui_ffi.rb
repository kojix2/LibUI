#!/usr/bin/env ruby

libui_ffi_path = File.expand_path('../lib/libui/ffi.rb', __dir__)
libui_path = File.expand_path('../lib/libui.rb', __dir__)

# Read the files into arrays by each line
ffi_lines = File.readlines(libui_ffi_path).map(&:strip)
libui_lines = File.readlines(libui_path)

# Count try_extern
matches = ffi_lines.select { _1.start_with?('try_extern') }
puts 'count try_extern'
puts matches.count

# Print try_extern calls
puts matches.map { _1.delete_prefix("try_extern '").delete_suffix("'") }

# Print enum names
puts libui_lines.select { _1.start_with?('  # ') }
                .map { _1.delete_prefix('  # ').strip }
