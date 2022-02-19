require 'bundler/gem_tasks'
require 'rake/testtask'
require 'digest'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

def version
  'alpha4.1'
end

def download_kojix2_release(library, remote_lib, file, sha256sum_expected)
  url = "https://github.com/kojix2/LibUI/releases/download/v0.0.14/#{file}"
  download_from_url(library, remote_lib, file, sha256sum_expected, url)
end

def download_andlabs_release(library, remote_lib, file, sha256sum_expected)
  url = "https://github.com/andlabs/libui/releases/download/#{version}/#{file}"
  download_from_url(library, remote_lib, file, sha256sum_expected, url)
end

def download_from_url(library, remote_lib, file, sha256sum_expected, url)
  require 'fileutils'
  require 'open-uri'
  require 'tmpdir'


  FileUtils.mkdir_p(File.expand_path('vendor', __dir__))
  target_path = File.expand_path("vendor/#{library}", __dir__)

  if File.exist?(target_path)
    puts "#{target_path} already exist."
    if check_sha256sum(target_path, sha256sum_expected)
      puts "No need to download #{library}."
      return
    else
      puts 'Download the file and replace it.'
    end
  end

  puts "Downloading #{file}..."
  Dir.mktmpdir do |dir|
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
      path = remote_lib
      if check_sha256sum(path, sha256sum_expected)
        FileUtils.cp(path, target_path)
        puts "Saved #{target_path}"
      end
    end
  end
end

def check_sha256sum(path, sha256sum_expected)
  print 'Check sha256sum...'
  actual_sha256sum = Digest::SHA256.hexdigest(File.binread(path))
  if actual_sha256sum == sha256sum_expected
    puts 'OK.'
    true
  else
    puts 'Failed.'
    warn 'Error: sha256sum does not match'
    warn "  path:               #{path}"
    warn "  actual_sha256sum:   #{actual_sha256sum}"
    warn "  expected_sha256sum: #{sha256sum_expected}"
    false
  end
end

namespace :vendor do
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

  desc 'Download libui.dylib for Mac to vendor directory'
  task :mac_arm do
    download_kojix2_release(
      'libui.dylib',
      'libui.dylib',
      'libui-alpha4.1-macos-arm64-dylib.tgz',
      '6da2ff5acb6fba09b47eae0219b3aaefd002ace00003ab5d59689e396bcefff7',
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

  desc 'Download libui.so, libui.dylib, and libui.dll to vendor directory'
  task all_x64: %i[linux_x64 mac_x64 windows_x64]
end
