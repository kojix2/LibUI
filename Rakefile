# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rbconfig'
require 'digest'
require 'fileutils'
require 'open-uri'
require 'tmpdir'
require 'zip'
require 'open3'

require_relative 'lib/libui/version'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

def log_message(message)
  Kernel.puts("[Rake] #{message}")
end

# `gem help platform`

# RubyGems platforms are composed of three parts, a CPU, an OS, and a
# version.  These values are taken from values in rbconfig.rb.  You can view
# your current platform by running `gem environment`.

# RubyGems matches platforms as follows:

#   * The CPU must match exactly unless one of the platforms has
#     "universal" as the CPU or the local CPU starts with "arm" and the gem's
#     CPU is exactly "arm" (for gems that support generic ARM architecture).
#   * The OS must match exactly.
#   * The versions must match exactly unless one of the versions is nil.

# For commands that install, uninstall and list gems, you can override what
# RubyGems thinks your platform is with the --platform option.  The platform
# you pass must match "#{cpu}-#{os}" or "#{cpu}-#{os}-#{version}".  On mswin
# platforms, the version is the compiler version, not the OS version.  (Ruby
# compiled with VC6 uses "60" as the compiler version, VC8 uses "80".)

# For the ARM architecture, gems with a platform of "arm-linux" should run on a
# reasonable set of ARM CPUs and not depend on instructions present on a limited
# subset of the architecture.  For example, the binary should run on platforms
# armv5, armv6hf, armv6l, armv7, etc.  If you use the "arm-linux" platform
# please test your gem on a variety of ARM hardware before release to ensure it
# functions correctly.

# Example platforms:

#   x86-freebsd        # Any FreeBSD version on an x86 CPU
#   universal-darwin-8 # Darwin 8 only gems that run on any CPU
#   x86-mswin32-80     # Windows gems compiled with VC8
#   armv7-linux        # Gem complied for an ARMv7 CPU running linux
#   arm-linux          # Gem compiled for any ARM CPU running linux

# When building platform gems, set the platform in the gem specification to
# Gem::Platform::CURRENT.  This will correctly mark the gem with your ruby's
# platform.

platforms = %w[
  x86_64-linux
  aarch64-linux
  x86_64-darwin
  arm64-darwin
  x64-mingw
  x86-mingw32
]

task :build_platform do
  platforms.each do |platform|
    sh 'gem', 'build', '--platform', platform
  end

  FileUtils.mkdir_p('pkg')
  Dir['*.gem'].each do |file|
    FileUtils.move(file, 'pkg')
  end
end

task :release_platform do
  Dir["pkg/libui-#{LibUI::VERSION}-*.gem"].each do |file|
    sh 'gem', 'push', file
  end
end

def build_libui_ng_with_meson(commit_hash)
  FileUtils.mkdir_p(File.expand_path('vendor', __dir__))
  target_path = File.expand_path("vendor/libui.#{RbConfig::CONFIG['host_cpu']}.#{RbConfig::CONFIG['SOEXT']}", __dir__)

  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      log_message 'Downloading libui-ng'
      commit_hash = 'master' if commit_hash.nil?
      url = libui_ng_source_zip_url(commit_hash)
      begin
        content = URI.open(url)
        File.binwrite('libui-ng.zip', content.read)
      rescue StandardError => e
        log_message "Failed. #{e.message}. Please check #{url}"
        return false
      end

      log_message 'Extracting zip file'
      Zip::File.open('libui-ng.zip') do |zip|
        zip.each do |entry|
          entry.extract(entry.name)
        end
      end

      Dir.chdir(Dir['libui-ng-*'].first) do
        build_log_path = File.expand_path('build.log', __dir__)

        log_message 'Building libui-ng (meson)'
        begin
          output, status = Open3.capture2e('meson', 'build', '--buildtype=release')
        rescue Errno::ENOENT => e
          log_message e.message
          log_message 'Make sure that meson is installed.'
          return false
        end
        File.open(build_log_path, 'a') do |f|
          f.puts output
        end
        unless status.success?
          log_message 'Error: Failed to build libui-ng. (meson)'
          log_message "Error: See #{build_log_path}"
          return false
        end

        log_message 'Building libui-ng (ninja)'
        begin
          output, status = Open3.capture2e('ninja', '-C', 'build')
        rescue Errno::ENOENT => e
          log_message e.message
          log_message 'Make sure that ninja is installed.'
          return false
        end
        File.open(build_log_path, 'a') do |f|
          f.puts output
        end
        unless status.success?
          log_message 'Error: Failed to build libui-ng. (ninja)'
          log_message "Error: See #{build_log_path}"
          return false
        end

        log_message "Saved #{build_log_path}"

        path = "build/meson-out/libui.#{RbConfig::CONFIG['SOEXT']}"

        if File.exist?(path)
          log_message "Successfully built #{path}"
        elsif path2 = Dir["#{path}.*"].select { |f| File.file?(f) }.max
          path = path2
          log_message "Successfully built #{path}"
        else
          log_message "Error: #{Dir['build/meson-out/*']}"
          log_message "Error: #{path} does not exist. Please check the build log."
          return false
        end

        log_message "Copying #{path} to #{target_path}"
        if File.symlink?(path)
          tpath = File.expand_path(File.readlink(path), File.dirname(path))
          FileUtils.cp(tpath, target_path)
        else
          FileUtils.cp(path, target_path)
        end

        log_message 'Scceeded.'
      end
    end
  end
end

def fetch_kojix2_libui_ng_nightly(library_name, library_path, file_name)
  url = url_kojix2_libui_ng_nightly(file_name)
  fetch_and_extract_file(library_name, library_path, file_name, true, url)
end

def fetch_and_extract_file(library_name, library_path, file_name, expected_sha256sum, url)
  FileUtils.mkdir_p(File.expand_path('vendor', __dir__))
  target_path = File.expand_path("vendor/#{library_name}", __dir__)

  return if file_already_exists?(target_path, expected_sha256sum)

  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      download_and_verify(file_name, url, dir, expected_sha256sum)
      extract_file(file_name, dir)
      copy_file_to_target(library_path, target_path)
    end
  end
end

def download_and_verify(file_name, url, temp_dir, expected_sha256sum)
  file_path = download_file(file_name, url, temp_dir)
  return if expected_sha256sum == true # Skip checksum verification for development builds

  return if verify_sha256sum(file_path, expected_sha256sum)

  raise "Checksum verification failed for #{file_name}"
end

def download_file(file_name, url, temp_dir)
  log_message("Downloading #{file_name} from #{url}")
  file_path = File.join(temp_dir, file_name)
  File.binwrite(file_path, URI.open(url).read)
  log_message("Downloaded #{file_name} to #{file_path} (#{File.size(file_path)} bytes).")
  file_path
rescue StandardError => e
  log_error("Failed to download #{file_name}: #{e.message}")
  raise e
end

def extract_file(file_name, dir)
  log_message "Extracting #{file_name}"
  if file_name.end_with?('.zip')
    extract_zip(file_name, dir)
  elsif file_name.end_with?('.so', '.dylib', '.dll')
    # Do nothing
  else
    extract_tar(file_name)
  end
rescue StandardError => e
  log_message "Failed to extract #{file_name}: #{e.message}"
  raise e
end

def extract_zip(file_name, dir)
  Zip::File.open(file_name) do |zip|
    zip.each do |entry|
      FileUtils.mkdir_p(File.dirname(entry.name))
      # FIXME: rubyzip stable version is v2.3.2 (2024-07-20).
      # If you do not specify the dist file absolute path,
      # it outputs a warning "unsafe" and does not extract the file on Windows.
      # rubyzip github master branch does not have this problem.
      entry.extract(File.expand_path(entry.name, dir))
    end
  end
end

def extract_tar(file_name)
  # Tar available on Windows 10
  success = system "tar xf #{file_name}"
  raise "Failed to extract #{file_name}" unless success

  log_message "Extracted #{file_name} successfully."
end

def file_already_exists?(path, _sha256sum)
  log_message "#{path} already exists." if File.exist?(path)
  false
end

def verify_sha256sum(path, expected_sha256sum)
  return nil if expected_sha256sum == true

  actual_sha256sum = Digest::SHA256.hexdigest(File.binread(path))
  if actual_sha256sum == expected_sha256sum
    log_message 'sha256sum matches.'
    true
  else
    log_message 'Warning: sha256sum does not match'
    log_message " path:               #{path}"
    log_message " actual_sha256sum:   #{actual_sha256sum}"
    log_message " expected_sha256sum: #{expected_sha256sum}"
    false
  end
end

def copy_file_to_target(src, dest)
  FileUtils.mkdir_p(File.dirname(dest))
  overwrite = File.exist?(dest)
  FileUtils.cp(src, dest)
  if overwrite
    log_message "Overwritten #{src} (#{File.size(src)} bytes) to #{dest}"
  else
    log_message "Copied #{src} (#{File.size(src)} bytes) to #{dest}"
  end
rescue StandardError => e
  log_message "Failed to copy #{src} to #{dest}: #{e.message}"
  raise e
end

def libui_ng_source_zip_url(commit_hash = 'master')
  "https://github.com/libui-ng/libui-ng/archive/#{commit_hash}.zip"
end

def url_kojix2_libui_ng_nightly(file_name)
  "https://nightly.link/kojix2/libui-ng/workflows/pre-build/pre-build/#{file_name}"
end

namespace 'vendor' do
  desc 'Build libui-ng latest master [commit hash]'
  task 'build', 'hash' do |_, args|
    commit_hash = args['hash']
    s = build_libui_ng_with_meson(commit_hash)
    abort if s == false
  end

  platforms = {
    ubuntu_x64: ['libui.x86_64.so', 'builddir/meson-out/libui.so', 'Ubuntu-x64-shared-release.zip'],
    # raspbian_aarch64: ['libui.aarch64.so', 'builddir/meson-out/libui.so', 'Raspbian-aarch64-shared-release.zip'],
    macos_x64: ['libui.x86_64.dylib', 'builddir/meson-out/libui.dylib', 'macOS-x64-shared-release.zip'],
    macos_arm64: ['libui.arm64.dylib', 'builddir/meson-out/libui.dylib', 'macOS-x64-shared-release.zip'],
    windows_x64: ['libui.x64.dll', 'builddir/meson-out/libui.dll', 'Win-x64-shared-release.zip'],
    windows_x86: ['libui.x86.dll', 'builddir/meson-out/libui.dll', 'Win-x86-shared-release.zip']
  }

  platforms.each do |name, args|
    name.to_s.split('_')
    # desc "Download pre-build for #{os} #{arch} to vendor directory"
    task name do
      fetch_kojix2_libui_ng_nightly(*args)
    end
  end

  desc 'Download pre-build for your platform to vendor directory'
  task :auto do
    case RUBY_PLATFORM
    when /linux/
      Rake::Task['vendor:ubuntu_x64'].invoke
    when /darwin/ && /arm/
      Rake::Task['vendor:macos_arm64'].invoke
    when /darwin/ && /x86_64/
      Rake::Task['vendor:macos_x64'].invoke
    when /mingw/
      Rake::Task['vendor:windows_x64'].invoke
    else
      log_message "Unknown platform: #{RUBY_PLATFORM}"
      log_message 'TODO: Add support for your platform'
    end
  end

  task :clean do
    (Dir['vendor/*'] - Dir['vendor/{LICENSE,README}.md']).each do |f|
      FileUtils.rm_rf(f)
    end
  end

  namespace :dev do
    {
      linux: ['libui.x86_64.so', 'libui_x86_64_gtk.so', 'libui_x86_64_gtk.so',
              'e4af4f9a34c7391d59996e776e9b925526186e15ff24de805529dd304f654284',
              'https://github.com/petabyt/libui-dev/releases/download/5-beta/libui_x86_64_gtk.so'],
      macos: ['libui.x86_64.dylib', 'libui_x86_64.dylib', 'libui_x86_64.dylib',
              '105f8c88cef6233c4befb3e82e5543dda82dc323ee92254699caa3aa43d29cfd',
              'https://github.com/petabyt/libui-dev/releases/download/5-beta/libui_x86_64.dylib']
    }.each do |name, args|
      # desc "Download pre-build for #{name} to vendor directory"
      task name do
        fetch_and_extract_file(*args)
      end
    end

    desc 'Download libui-dev for your platform to vendor directory'
    task :auto do
      case RUBY_PLATFORM
      when /linux/
        Rake::Task['vendor:dev:linux'].invoke
      when /darwin/
        Rake::Task['vendor:dev:macos'].invoke
      else
        log_message "Unknown platform: #{RUBY_PLATFORM}"
        log_message 'TODO: Add support for your platform'
      end
    end
  end
end
