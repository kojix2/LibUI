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

  case spec.platform.to_s
  when 'x86_64-linux'
    spec.files << 'vendor/libui.x86_64.so'
  when 'aarch64-linux'
    spec.files << 'vendor/libui.aarch64.so' # raspberry pi
  when 'x86_64-darwin'
    spec.files << 'vendor/libui.x86_64.dylib' # universal binary
  when 'arm64-darwin'
    spec.files << 'vendor/libui.arm64.dylib' # universal binary
  when 'x64-mingw'
    spec.files << 'vendor/libui.x64.dll'
  when 'x86-mingw32'
    spec.files << 'vendor/libui.x86.dll'
  else
    spec.files.concat(Dir['vendor/*.{dll,dylib,so}']) # all
  end

  # spec.add_dependency 'fiddle'
end
