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

  spec.require_paths = 'lib'

  spec.files = Dir['*.{md,txt}', '{lib}/**/*', 'vendor/{LICENSE,README}.md']
  case spec.platform.to_s
  when 'x86_64-linux'
    spec.files << 'vendor/libui.so'
    # when "aarch64-linux"
    # spec.files << "vendor/libui.so"
  when 'x86_64-darwin', 'arm64-darwin'
    spec.files << 'vendor/libui.dylib'
  when 'x64-mingw'
    spec.files << 'vendor/libui.dll'
  else
    spec.files.concat(Dir['vendor/*.{dll,dylib,so}'])
  end

  # spec.add_dependency 'fiddle'
end
