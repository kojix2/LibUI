# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rbconfig'
require 'digest'
require_relative 'lib/libui/version'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

def puts(str)
  Kernel.puts("[Rake] #{str}")
end

platforms = %w[
  x86_64-linux
  aarch64-linux
  x86_64-darwin
  arm64-darwin
  x64-mingw
  x86-mingw32
]

task :build_platform do
  require 'fileutils'

  platforms.each do |platform|
    sh 'gem', 'build', '--platform', platform
  end

  FileUtils.mkdir_p('pkg')
  Dir['*.gem'].each do |file|
    FileUtils.move(file, 'pkg')
  end
end

task :release_platform do
  require_relative 'lib/libui/version'

  Dir["pkg/libui-#{LibUI::VERSION}-*.gem"].each do |file|
    sh 'gem', 'push', file
  end
end

def url_libui_ng_source_zip(commit_hash = 'master')
  "https://github.com/libui-ng/libui-ng/archive/#{commit_hash}.zip"
end

def url_libui_ng_nightly(file_name)
  "https://nightly.link/libui-ng/libui-ng/workflows/build/master/#{file_name}"
end

# kojix2/libui-ng (pre-build)
# - release
# - shared
def url_kojix2_libui_ng_nightly(file_name)
  "https://nightly.link/kojix2/libui-ng/workflows/pre-build/pre-build/#{file_name}"
end

def download_libui_ng_nightly(libname, lib_path, file_name)
  url = url_libui_ng_nightly(file_name)
  download_from_url(libname, lib_path, file_name, true, url)
end

def download_kojix2_libui_ng_nightly(libname, lib_path, file_name)
  url = url_kojix2_libui_ng_nightly(file_name)
  download_from_url(libname, lib_path, file_name, true, url)
end

def download_from_url(libname, lib_path, file_name, sha256sum_expected, url)
  require 'fileutils'
  require 'open-uri'
  require 'tmpdir'

  FileUtils.mkdir_p(File.expand_path('vendor', __dir__))
  target_path = File.expand_path("vendor/#{libname}", __dir__)

  return if check_file_exist(target_path, sha256sum_expected)

  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      puts "Downloading #{file_name}"
      begin
        File.binwrite(file_name, URI.open(url).read)
      rescue StandardError => e
        puts "Failed. #{e.message}. Please check #{url}"
        return false
      end

      puts "Extracting #{file_name}"
      if file_name.end_with?('zip')
        # `unzip` not available on Windows
        require 'zip'
        Zip::File.open(file_name) do |zip|
          zip.each do |entry|
            entry.extract(entry.name)
          end
        end
      else
        # Tar available on Windows 10
        system "tar xf #{file_name}"
      end

      if sha256sum_expected == true
        puts 'Skip sha256sum check (development build)'
      else
        puts 'Check sha256sum'
        v = check_sha256sum(lib_path, sha256sum_expected)
        retrun false unless v
      end

      puts "Copying #{lib_path} to #{target_path}"
      FileUtils.cp(lib_path, target_path)
    end
  end
end

def check_file_exist(path, sha256sum)
  if File.exist?(path)
    puts "#{path} already exist."
    if check_sha256sum(path, sha256sum)
      puts 'Skip downloading.'
      return true
    else
      puts 'Download the file and replace it.'
    end
  end
  false
end

def check_sha256sum(path, sha256sum_expected)
  return nil if sha256sum_expected == true

  actual_sha256sum = Digest::SHA256.hexdigest(File.binread(path))
  if actual_sha256sum == sha256sum_expected
    puts 'sha256sum matches.'
    true
  else
    puts 'Warning: sha256sum does not match'
    puts " path:               #{path}"
    puts " actual_sha256sum:   #{actual_sha256sum}"
    puts " expected_sha256sum: #{sha256sum_expected}"
    false
  end
end

def build_libui_ng(commit_hash)
  require 'open-uri'
  require 'fileutils'
  require 'tmpdir'
  require 'zip'
  require 'open3'

  FileUtils.mkdir_p(File.expand_path('vendor', __dir__))
  target_path = File.expand_path("vendor/libui.#{RbConfig::CONFIG['host_cpu']}.#{RbConfig::CONFIG['SOEXT']}", __dir__)

  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      puts 'Downloading libui-ng'
      commit_hash = 'master' if commit_hash.nil?
      url = url_libui_ng_source_zip(commit_hash)
      begin
        content = URI.open(url)
        File.binwrite('libui-ng.zip', content.read)
      rescue StandardError => e
        puts "Failed. #{e.message}. Please check #{url}"
        return false
      end

      puts 'Extracting zip file'
      Zip::File.open('libui-ng.zip') do |zip|
        zip.each do |entry|
          entry.extract(entry.name)
        end
      end

      Dir.chdir(Dir['libui-ng-*'].first) do
        build_log_path = File.expand_path('build.log', __dir__)

        puts 'Building libui-ng (meson)'
        begin
          output, status = Open3.capture2e('meson', 'build', '--buildtype=release')
        rescue Errno::ENOENT => e
          puts e.message
          puts 'Make sure that meson is installed.'
          return false
        end
        File.open(build_log_path, 'a') do |f|
          f.puts output
        end
        unless status.success?
          puts 'Error: Failed to build libui-ng. (meson)'
          puts "Error: See #{build_log_path}"
          return false
        end

        puts 'Building libui-ng (ninja)'
        begin
          output, status = Open3.capture2e('ninja', '-C', 'build')
        rescue Errono::ENOENT => e
          puts e.message
          puts 'Make sure that ninja is installed.'
          return false
        end
        File.open(build_log_path, 'a') do |f|
          f.puts output
        end
        unless status.success?
          puts 'Error: Failed to build libui-ng. (ninja)'
          puts "Error: See #{build_log_path}"
          return false
        end

        puts "Saved #{build_log_path}"

        path = "build/meson-out/libui.#{RbConfig::CONFIG['SOEXT']}"

        if File.exist?(path)
          puts "Successfully built #{path}"
        elsif path2 = Dir["#{path}.*"].select { |f| File.file?(f) }.max
          path = path2
          puts "Successfully built #{path}"
        else
          puts "Error: #{Dir['build/meson-out/*']}"
          puts "Error: #{path} does not exist. Please check the build log."
          return false
        end

        puts "Copying #{path} to #{target_path}"
        if File.symlink?(path)
          tpath = File.expand_path(File.readlink(path), File.dirname(path))
          FileUtils.cp(tpath, target_path)
        else
          FileUtils.cp(path, target_path)
        end

        puts 'Scceeded.'
      end
    end
  end
end

namespace 'vendor' do
  desc 'Build libui-ng latest master [commit hash]'
  task 'build', 'hash' do |_, args|
    s = build_libui_ng(args['hash'])
    abort if s == false
  end

  namespace 'libui-ng' do
    desc 'Download latest official pre-build for Ubuntu to vendor directory'
    task :ubuntu_x64 do
      download_libui_ng_nightly(
        'libui.x86_64.so',
        'builddir/meson-out/libui.so',
        'Ubuntu-x64-shared-debug.zip'
      )
    end

    desc 'Download latest official pre-build for Mac to vendor directory'
    task :macos do
      download_libui_ng_nightly(
        'libui.dylib',
        'builddir/meson-out/libui.dylib',
        'macOS-x64-shared-debug.zip'
      )
    end
  end

  desc 'Download pre-build for Ubuntu to vendor directory'
  task :ubuntu_x64 do
    download_kojix2_libui_ng_nightly(
      'libui.x86_64.so',
      'builddir/meson-out/libui.so',
      'Ubuntu-x64-shared-release.zip'
    )
  end

  desc 'Download pre-build for Raspbian to vendor directory'
  task :raspbian_aarch64 do
    download_kojix2_libui_ng_nightly(
      'libui.aarch64.so',
      'builddir/meson-out/libui.so',
      'Raspbian-aarch64-shared-release.zip'
    )
  end

  desc 'Download pre-build for Mac to vendor directory'
  task :macos_x64 do
    download_kojix2_libui_ng_nightly(
      'libui.x86_64.dylib',
      'builddir/meson-out/libui.dylib',
      'macOS-x64-shared-release.zip' # universal binary?
    )
  end

  desc 'Download pre-build for Mac to vendor directory'
  task :macos_arm64 do
    download_kojix2_libui_ng_nightly(
      'libui.arm64.dylib',
      'builddir/meson-out/libui.dylib',
      'macOS-x64-shared-release.zip' # universal binary?
    )
  end

  desc 'Download pre-build for Windows to vendor directory'
  task :windows_x64 do
    download_kojix2_libui_ng_nightly(
      'libui.x64.dll',
      'builddir/meson-out/libui.dll',
      'Win-x64-shared-release.zip'
    )
  end

  desc 'Download pre-build for Windows to vendor directory'
  task :windows_x86 do
    download_kojix2_libui_ng_nightly(
      'libui.x86.dll',
      'builddir/meson-out/libui.dll',
      'Win-x86-shared-release.zip'
    )
  end

  # desc 'Download pre-build for your platform to vendor directory'
  task :auto do
    case RUBY_PLATFORM
    when /linux/
      Rake::Task['vendor:ubuntu_x64'].invoke
    when /darwin/
      Rake::Task['vendor:mac_x64'].invoke # FIXME
    when /mingw/
      Rake::Task['vendor:windows_x64'].invoke
    else
      puts "Unknown platform: #{RUBY_PLATFORM}"
      puts 'TODO: Add support for your platform'
    end
  end

  task :clean do
    (Dir['vendor/*'] - Dir['vendor/{LICENSE,README}.md']).each do |f|
      FileUtils.rm_rf(f)
    end
  end
end
