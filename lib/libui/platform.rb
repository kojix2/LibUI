require 'rbconfig'

module LibUI
  module Platform
    CONFIG = {
      'arm64-darwin' => {
        vendor: 'vendor/libui.arm64.dylib',
        lib_names: ['libui.arm64.dylib', 'libui.dylib'],
        release_zip: 'macOS-arm64-shared-release.zip',
        release_src: 'builddir/meson-out/libui.dylib'
      },
      'x86_64-darwin' => {
        vendor: 'vendor/libui.x86_64.dylib',
        lib_names: ['libui.x86_64.dylib', 'libui.dylib'],
        release_zip: 'macOS-x64-shared-release.zip',
        release_src: 'builddir/meson-out/libui.dylib'
      },
      'x86_64-linux' => {
        vendor: 'vendor/libui.x86_64.so',
        lib_names: ['libui.x86_64.so', 'libui.so'],
        release_zip: 'Ubuntu-x64-shared-release.zip',
        release_src: 'builddir/meson-out/libui.so'
      },
      'aarch64-linux' => {
        vendor: 'vendor/libui.aarch64.so',
        lib_names: ['libui.aarch64.so', 'libui.so'],
        release_zip: 'Ubuntu-arm64-shared-release.zip',
        release_src: 'builddir/meson-out/libui.so'
      },
      'x64-mingw32' => {
        vendor: 'vendor/libui.x64.dll',
        lib_names: ['libui.x64.dll', 'libui.dll'],
        release_zip: 'Windows-x64-msvc-shared-release.zip',
        release_src: 'builddir/meson-out/libui.dll'
      },
      'x86-mingw32' => {
        vendor: 'vendor/libui.x86.dll',
        lib_names: ['libui.x86.dll', 'libui.dll'],
        release_zip: 'Windows-x86-msvc-shared-release.zip',
        release_src: 'builddir/meson-out/libui.dll'
      }
    }.freeze

    class << self
      def config_keys
        CONFIG.keys
      end

      def config_for(platform_key)
        CONFIG[normalize_platform_key(platform_key)]
      end

      def current_config
        config_for(detect_platform_key)
      end

      def detect_platform_key
        native_platform_key || rubygems_platform_key
      end

      def native_platform_key
        platform_key = case host_os
                       when /darwin/
                         "#{normalized_cpu}-darwin"
                       when /linux/
                         # libc variants (glibc vs musl) are not supported as
                         # separate prebuilt targets yet; the shipped Linux
                         # binaries are built on Ubuntu. Supporting musl would
                         # require adding explicit *-linux-musl entries.
                         "#{normalized_cpu}-linux"
                       when /mingw|mswin/
                         windows_platform_key
                       end

        CONFIG.key?(platform_key) ? platform_key : nil
      end

      def rubygems_platform_key
        current_platform = Gem::Platform.local
        platform_key = normalize_platform_key(current_platform.to_s)
        return platform_key if CONFIG.key?(platform_key)

        CONFIG.keys.find do |config_key|
          config_platform = Gem::Platform.new(config_key)

          # NOTE: match_platforms? is a private RubyGems API. It is used to
          # reuse RubyGems' own platform matching (including the libc wildcard
          # behaviour), but it may change or disappear across RubyGems versions.
          if Gem::Platform.send(:match_platforms?, current_platform, [config_platform])
            true
          elsif config_key == 'x64-mingw32' &&
                current_platform.os.start_with?('mingw') &&
                %w[x64 x86_64 amd64].include?(current_platform.cpu)
            true
          elsif config_key == 'x86-mingw32' &&
                current_platform.os.start_with?('mingw') &&
                %w[x86 i386 i686].include?(current_platform.cpu)
            true
          else
            false
          end
        end
      end

      # Canonicalizes alternate platform spellings to the keys used in CONFIG.
      # Linux libc suffixes (-gnu / -musl) are intentionally not stripped here;
      # adding libc-specific artifacts should be an explicit CONFIG change.
      def normalize_platform_key(platform_key)
        platform_key.to_s
                    .sub(/\Aarm64-linux\z/, 'aarch64-linux')
                    .sub(/\Ax64-linux\z/, 'x86_64-linux')
                    .sub(/-mingw-ucrt\z/, '-mingw32')
      end

      def vendor_file_for(platform_key)
        config = config_for(platform_key)
        config && config[:vendor]
      end

      def current_lib_names
        # host_lib_name and the bare "libui.<soext>" are fallbacks for locally
        # built or manually placed libraries (e.g. via LIBUIDIR or a source
        # checkout) whose file names may not match the CONFIG lib_names.
        host_lib_name = "libui.#{host_cpu}.#{RbConfig::CONFIG['SOEXT']}"
        names = current_config ? current_config[:lib_names] : []
        ([host_lib_name] + names + ["libui.#{RbConfig::CONFIG['SOEXT']}"]).uniq
      end

      private

      def host_cpu
        RbConfig::CONFIG['host_cpu']
      end

      def host_os
        RbConfig::CONFIG['host_os']
      end

      def normalized_cpu
        case host_cpu
        when /i\d86/
          'x86'
        when 'amd64', 'x64'
          'x86_64'
        when 'aarch64'
          host_os =~ /darwin/ ? 'arm64' : host_cpu
        when 'arm64'
          host_os =~ /linux/ ? 'aarch64' : host_cpu
        else
          host_cpu
        end
      end

      def windows_platform_key
        case normalized_cpu
        when 'x86_64'
          'x64-mingw32'
        when 'x86'
          'x86-mingw32'
        end
      end
    end
  end
end
