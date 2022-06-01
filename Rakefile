# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'digest'
require_relative 'lib/libui/version'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

def version
  'alpha4.1'
end

def lib_name
  require 'rbconfig'
  "libui.#{RbConfig::CONFIG['SOEXT']}"
end

def libui_ng_url_zip(commit_hash = 'master')
  "https://github.com/libui-ng/libui-ng/archive/#{commit_hash}.zip"
end

def download_libui_ng_development(libname, lib_path, file_name)
  url = "https://nightly.link/libui-ng/libui-ng/workflows/build/master/#{file_name}"
  download_from_url(libname, lib_path, file_name, true, url)
end

def download_kojix2_release(libname, lib_path, file_name, sha256sum_expected)
  url = "https://github.com/kojix2/LibUI/releases/download/v#{LibUI::VERSION}/#{file_name}"
  download_from_url(libname, lib_path, file_name, sha256sum_expected, url)
end

def download_andlabs_release(libname, lib_path, file_name, sha256sum_expected)
  url = "https://github.com/andlabs/libui/releases/download/#{version}/#{file_name}"
  download_from_url(libname, lib_path, file_name, sha256sum_expected, url)
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
      puts "[Rake] Downloading #{file_name}"
      begin
        File.binwrite(file_name, URI.open(url).read)
      rescue StandardError => e
        puts "[Rake] Failed. #{e.message}. Please check #{url}"
        return false
      end

      puts "[Rake] Extracting #{file_name}"
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
        puts '[Rake] Skip sha256sum check (development build)'
      else
        puts '[Rake] Check sha256sum'
        v = check_sha256sum(lib_path, sha256sum_expected)
        retrun false unless v
      end

      puts "[Rake] Copying #{lib_path} to #{target_path}"
      FileUtils.cp(lib_path, target_path)
    end
  end
end

def check_file_exist(path, sha256sum)
  if File.exist?(path)
    puts "[Rake] #{path} already exist."
    if check_sha256sum(path, sha256sum)
      puts '[Rake] Skip downloading.'
      return true
    else
      puts '[Rake] Download the file and replace it.'
    end
  end
  false
end

def check_sha256sum(path, sha256sum_expected)
  return nil if sha256sum_expected == true

  actual_sha256sum = Digest::SHA256.hexdigest(File.binread(path))
  if actual_sha256sum == sha256sum_expected
    puts '[Rake] sha256sum matches.'
    true
  else
    puts '[Rake] Warning: sha256sum does not match'
    puts "[Rake]  path:               #{path}"
    puts "[Rake]  actual_sha256sum:   #{actual_sha256sum}"
    puts "[Rake]  expected_sha256sum: #{sha256sum_expected}"
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
  target_path = File.expand_path("vendor/#{lib_name}", __dir__)

  # check_file_exist(target_path, sha256sum_expected)

  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      puts '[Rake] Downloading libui-ng'
      commit_hash = 'master' if commit_hash.nil?
      url = libui_ng_url_zip(commit_hash)
      begin
        content = URI.open(url)
        File.binwrite('libui-ng.zip', content.read)
      rescue StandardError => e
        puts "[Rake] Failed. #{e.message}. Please check #{url}"
        return false
      end

      puts '[Rake] Extracting zip file'
      Zip::File.open('libui-ng.zip') do |zip|
        zip.each do |entry|
          entry.extract(entry.name)
        end
      end

      Dir.chdir(Dir['libui-ng-*'].first) do
        build_log_path = File.expand_path('build.log', __dir__)

        puts '[Rake] Building libui-ng (meson)'
        begin
          output, status = Open3.capture2e('meson', 'build', '--buildtype=release')
        rescue Errno::ENOENT => e
          puts "[Rake] #{e.message}"
          return false
        end
        File.open(build_log_path, 'a') do |f|
          f.puts output
        end
        unless status.success?
          puts '[Rake] Error: Failed to build libui-ng. (meson)'
          puts "[Rake] Error: See #{build_log_path}"
          return false
        end

        puts '[Rake] Building libui-ng (ninja)'
        begin
          output, status = Open3.capture2e('ninja', '-C', 'build')
        rescue Errono::ENOENT => e
          puts "[Rake] #{e.message}"
          return false
        end
        File.open(build_log_path, 'a') do |f|
          f.puts output
        end
        unless status.success?
          puts '[Rake] Error: Failed to build libui-ng. (ninja)'
          puts "[Rake] Error: See #{build_log_path}"
          return false
        end

        puts "[Rake] Saved #{build_log_path}"

        path = "build/meson-out/#{lib_name}"

        if File.exist?(path)
          puts "[Rake] Successfully built #{path}"
        elsif !Dir["#{path}.*"].empty?
          path = Dir["#{path}.*"].max
          puts "[Rake] Successfully built #{path}"
        else
          puts "[Rake] Error: #{Dir['build/meson-out/*']}"
          puts "[Rake] Error: #{path} does not exist. Please check the build log."
          return false
        end

        puts "[Rake] Copying #{path} to #{target_path}"
        if File.symlink?(path)
          tpath = File.expand_path(File.readlink(path), File.dirname(path))
          FileUtils.cp(tpath, target_path)
        else
          FileUtils.cp(path, target_path)
        end

        puts '[Rake] Scceeded.'
      end
    end
  end
end

namespace 'vendor' do
  desc 'Download libui.so for Linux to vendor directory'
  task :linux_x64 do
    download_andlabs_release(
      'libui.so',
      'libui.so.0',
      'libui-alpha4.1-linux-amd64-shared.tgz',
      'ad517cfc4e402b6070138bfd25804508f9115f91db9330344f0a07f39f6470de'
    )
  end

  desc 'Download libui.so for Linux to vendor directory'
  task :linux_x86 do
    download_andlabs_release(
      'libui.so',
      'libui.so.0',
      'libui-alpha4.1-linux-386-shared.tgz',
      '9a67de44d3dd3b2134bc801b0fab58eec247f6b18fdc3e43917845cac2217bcb'
    )
  end

  desc 'Download libui.dylib for Mac to vendor directory (universal binary)'
  task :mac_arm do
    download_kojix2_release(
      'libui.dylib',
      'libui.dylib',
      'libui-alpha4.1-macos-arm64-dylib.tgz',
      '6da2ff5acb6fba09b47eae0219b3aaefd002ace00003ab5d59689e396bcefff7'
    )
  end

  desc 'Download libui.dylib for Mac to vendor directory'
  task :mac_x64 do
    download_andlabs_release(
      'libui.dylib',
      'libui.A.dylib',
      'libui-alpha4.1-darwin-amd64-shared.tgz',
      'a3ff09380c1d117d76b6afc68d6e29b7a19c65286c8f1d1039a88e03e999aab4'
    )
  end

  desc 'Download libui.dll for Windows to vendor directory'
  task :windows_x64 do
    download_andlabs_release(
      'libui.dll',
      'libui.dll',
      'libui-alpha4.1-windows-amd64-shared.zip',
      '9635cab1528af6ce11dca22e08bf505d7e6b728f2f4c1d97fe7986ea91a0e168'
    )
  end

  desc 'Download libui.dll for Windows to vendor directory'
  task :windows_x86 do
    download_andlabs_release(
      'libui.dll',
      'libui.dll',
      'libui-alpha4.1-windows-386-shared.zip',
      'e2b8b1e6710c7461e55dfc0454606613942109e4b0c0212b97eb682b3ae3a1b3'
    )
  end

  desc 'Downlaod [linux_x64, mac_arm, windows_x64] to vendor directory'
  task default: %i[linux_x64 mac_arm windows_x64]
end

namespace 'libui-ng' do
  desc 'Build libui-ng latest master'
  task 'build', 'hash' do |_, args|
    s = build_libui_ng(args['hash'])
    abort if s == false
  end

  desc 'Download latest dev build for Ubuntu to vendor directory'
  task :ubuntu_x64 do
    download_libui_ng_development(
      'libui.so',
      'builddir/meson-out/libui.so',
      'Ubuntu-x64-shared-debug.zip'
    )
  end

  desc 'Download latest dev build for Mac to vendor directory'
  task :mac do
    download_libui_ng_development(
      'libui.dylib',
      'builddir/meson-out/libui.dylib',
      'macOS-x64-shared-debug.zip'
    )
  end
end
