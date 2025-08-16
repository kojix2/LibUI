require_relative 'lib/libui/version'

Gem::Specification.new do |spec|
  spec.name          = 'libui'
  spec.version       = LibUI::VERSION
  spec.summary       = 'Ruby bindings to libui'
  spec.homepage      = 'https://github.com/kojix2/libui'
  spec.license       = 'MIT'

  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.files = Dir['*.{md,txt}', '{lib}/**/*', 'vendor/{LICENSE,README}.md']
  spec.require_paths = 'lib'

  spec.required_ruby_version = '>= 2.6'

  # See `gem help platform` for information on platform matching.

  case spec.platform.to_s
  when 'x86_64-linux'
    spec.files << 'vendor/libui.x86_64.so'
  when 'arm-linux'
    spec.files << 'vendor/libui.arm.so'
  when 'x86_64-darwin'
    spec.files << 'vendor/libui.x86_64.dylib'
  when 'arm64-darwin'
    spec.files << 'vendor/libui.arm64.dylib'
  when 'x64-mingw32', 'x64-mingw-ucrt'
    spec.files << 'vendor/libui.x64.dll'
  when 'x86-mingw32'
    spec.files << 'vendor/libui.x86.dll'
  else
    spec.files.concat(Dir['vendor/*.{dll,dylib,so}']) # all
  end

  spec.add_dependency 'fiddle'
end
