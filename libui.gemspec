require_relative 'lib/libui/version'

Gem::Specification.new do |spec|
  spec.name          = 'libui'
  spec.version       = LibUI::VERSION
  spec.summary       = 'Ruby bindings to libui'
  spec.homepage      = 'https://github.com/kojix2/libui'
  spec.license       = 'MIT'

  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.required_ruby_version = '>= 2.5'

  spec.files = Dir['*.{md,txt}', '{lib}/**/*',
                   'vendor/LICENSE', 'vendor/README.md',
                   'vendor/libui.dll', 'vendor/libui.dylib', 'vendor/libui.so']
  spec.require_paths = 'lib'

  # spec.add_dependency 'fiddle'
end
