# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

def version
  'alpha4.1'
end

def download_official(library, remote_lib, file)
  require 'fileutils'
  require 'open-uri'
  require 'tmpdir'

  url = "https://github.com/andlabs/libui/releases/download/#{version}/#{file}"
  puts "Downloading #{file}..."
  dir = Dir.mktmpdir
  Dir.chdir(dir) do
    File.binwrite(file, URI.open(url).read)
    if file.end_with?('zip')
      # `unzip` not available on Windows
      require 'zip'
      Zip::File.open(file) do |zip|
        zip.each do |entry|
          entry.extract(entry.name)
        end
      end
    else
      # Tar available on Windows 10
      system "tar xf #{file}"
    end
    path = remote_lib.to_s
    FileUtils.cp(path, File.expand_path("vendor/#{library}", __dir__))
    puts "Saved vendor/#{library}"
  end
end

namespace :vendor do
  desc 'Download libui.so for Linux to vendor directory'
  task :linux do
    download_official('libui.so', 'libui.so.0', 'libui-alpha4.1-linux-amd64-shared.tgz')
  end

  desc 'Download libui.dylib for Mac to vendor directory'
  task :mac do
    download_official('libui.dylib', 'libui.A.dylib', 'libui-alpha4.1-darwin-amd64-shared.tgz')
  end

  desc 'Download libui.dll for Windows to vendor directory'
  task :windows do
    download_official('libui.dll', 'libui.dll', 'libui-alpha4.1-windows-amd64-shared.zip')
  end

  desc 'Download libui.so, libui.dylib, and libui.dll to vendor directory'
  task all: %i[linux mac windows]
end
