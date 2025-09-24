#!/usr/bin/env ruby

require 'open-uri'
require 'tempfile'

UI_H_URL = 'https://raw.githubusercontent.com/libui-ng/libui-ng/master/ui.h'.freeze

ui_h = []
Tempfile.open(['ui', '.h']) do |tf|
  tf.write URI.open(UI_H_URL).read
  tf.close

  cmd_gcc = 'gcc -fpreprocessed -P -dD -E'

  ui_h = `#{cmd_gcc} #{tf.path}` # Remove comments
         .split("\n").select { !_1.strip.start_with?('#') }.join("\n") # Remove macros
         .split(';').map do
           _1.split("\n").map(&:strip).join(' ')
             .strip.squeeze(' ')
         end
end
# Count
# - Count the occurrences of '_UI_EXTERN'

puts 'count _UI_EXTERN'
puts(ui_h.count { _1.start_with?('_UI_EXTERN') })

# Functions
# - Print the definitions of functions marked with '_UI_EXTERN'

puts(ui_h.select { _1.start_with?('_UI_EXTERN') }
         .map { _1.delete_prefix('_UI_EXTERN ').squeeze(' ') })

# Enums
# - Print the names of enums marked with '_UI_ENUM'

puts(ui_h.select { _1.include?('_UI_ENUM') }
         .map { _1.match(/_UI_ENUM\(ui(\w+)/)[1] })
