require_relative 'lib/libui/version'
require_relative 'lib/libui/platform'

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

  # Use the GEM_PLATFORM environment variable if specified
  gem_platform = ENV['GEM_PLATFORM']
  spec.platform = gem_platform if gem_platform && !gem_platform.empty? && gem_platform != 'ruby'

  platform_for_vendor = if gem_platform && !gem_platform.empty? && gem_platform != 'ruby'
                          gem_platform
                        else
                          spec.platform.to_s
                        end

  vendor_file = LibUI::Platform.vendor_file_for(platform_for_vendor)
  if vendor_file
    # Platform-specific gem: ship only the matching native library.
    spec.files << vendor_file
  else
    # Generic "ruby"-platform gem: include every bundled native library so
    # runtime platform detection can select the matching one.
    spec.files.concat(Dir['vendor/*.{dll,dylib,so}'])
  end

  spec.add_dependency 'fiddle'
end
