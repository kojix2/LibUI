# frozen_string_literal: true

require_relative 'lib/libui/version'

Gem::Specification.new do |spec|
  spec.name          = 'libui'
  spec.version       = Libui::VERSION
  spec.summary       = 'Ruby bindings to libui'
  spec.homepage      = 'https://github.com/kojix2/libui'
  spec.license       = 'MIT'

  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.required_ruby_version = '>= 2.5'

  spec.files         = Dir['*.{md,txt}', '{lib,vendor}/**/*']
  spec.require_paths = 'lib'

  # spec.add_dependency 'fiddle'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
end
