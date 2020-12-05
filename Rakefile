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
    command = file.end_with?('.zip') ? 'unzip' : 'tar xf'
    system "#{command} #{file}"
    path = remote_lib.to_s
    FileUtils.cp(path, File.expand_path("vendor/#{library}", __dir__))
    puts "Saved vendor/#{library}"
  end
end

namespace :vendor do
  task :linux do
    download_official('libui.so', 'libui.so.0', 'libui-alpha4.1-linux-amd64-shared.tgz')
  end

  task :mac do
    download_official('libui.dylib', 'libui.A.dylib', 'libui-alpha4.1-darwin-amd64-shared.tgz')
  end

  task :windows do
    download_official('libui.dll', 'libui.dll', 'libui-alpha4.1-windows-amd64-shared.zip')
  end

  task all: %i[linux mac windows]
end
