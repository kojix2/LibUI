# frozen_string_literal: true

require 'rake/testtask'
require 'rbconfig'
require 'fileutils'
require 'zip'

require_relative 'lib/libui/version'

# Configuration
COMMIT_HASH = ENV['LIBUI_NG_COMMIT_HASH'] || '8347960'

# Path constants
BUILD_DIR = 'builddir'
MESON_OUT_DIR = "#{BUILD_DIR}/meson-out"
DEBUG_DIR = 'libui/debug'

# Platform-specific configuration for shared libraries
PLATFORM_CONFIG = {
  darwin: [
    { zip: 'macOS-x64-shared-release.zip', src: 'builddir/meson-out/libui.dylib', dest: 'vendor/libui.x86_64.dylib' }
  ],
  linux: [
    { zip: 'Ubuntu-x64-shared-release.zip', src: 'builddir/meson-out/libui.so', dest: 'vendor/libui.x86_64.so' }
  ],
  mingw: [
    { zip: 'Win-x64-shared-release.zip', src: 'builddir/meson-out/libui.dll', dest: 'vendor/libui.x64.dll' }
  ]
}.freeze

# Test configuration
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

# Utility functions
def log_message(message)
  puts "[Rake] #{message}"
end

def url_for_libui_ng_commit(file_name)
  "https://github.com/kojix2/libui-ng/releases/download/commit-#{COMMIT_HASH}/#{file_name}"
end

def download_file(file_name, url)
  log_message "Running: curl -L -o #{file_name} #{url}"
  curl_status = system("curl -L -o #{file_name} #{url}")
  return if curl_status && File.exist?(file_name)

  warn "Error: Failed to download #{file_name} from #{url}"
  exit 1
end

def extract_zip_files(file_name, lib_paths)
  return unless file_name.end_with?('.zip')

  Zip::File.open(file_name) do |zip_file|
    zip_file.each do |entry|
      # Extract only exact matches for shared libraries
      next unless lib_paths.include?(entry.name)

      print "Extracting #{entry.name} from #{file_name}..."

      # Preserve complete directory structure
      target_path = entry.name
      FileUtils.mkdir_p(File.dirname(target_path)) unless entry.directory?

      unless entry.directory?
        entry.extract(target_path) { true } # Overwrite if exists
      end
      puts 'done'
    end
  end
end

def download_from_url(lib_paths, file_name, url)
  log_message "Downloading #{lib_paths} from #{url}"

  download_file(file_name, url)
  extract_zip_files(file_name, lib_paths)
ensure
  File.delete(file_name) if File.exist?(file_name)
end

# Mid-level functions
def download_libui_ng_nightly(lib_paths, file_name)
  url = url_for_libui_ng_commit(file_name)
  download_from_url(lib_paths, file_name, url)
end

def download_and_place(zip_name, src, dest)
  download_libui_ng_nightly([src], zip_name)
  FileUtils.mkdir_p File.dirname(dest)
  FileUtils.cp src, dest
end

# High-level processing functions
def process_config_entry(entry)
  # Standard download and place for shared libraries only
  download_and_place(entry[:zip], entry[:src], entry[:dest])
end

def process_platform(platform_entries)
  platform_entries.each do |entry|
    process_config_entry(entry)
  end
end

def detect_platform
  case RUBY_PLATFORM
  when /darwin/
    :darwin
  when /linux/
    :linux
  when /mingw/
    :mingw
  when /mswin/
    :msvc
  else
    log_message "Unknown platform: #{RUBY_PLATFORM}"
    log_message 'TODO: Add support for your platform'
    nil
  end
end

# Platform gem building
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

# Vendor tasks
namespace 'vendor' do
  desc 'Download pre-built libraries for current platform'
  task :auto do
    platform = detect_platform
    if platform && PLATFORM_CONFIG[platform]
      log_message "Processing platform: #{platform}"
      process_platform(PLATFORM_CONFIG[platform])
    else
      log_message 'No configuration found for current platform'
      exit 1
    end
  end

  desc 'Clean vendor directory'
  task :clean do
    vendor_files = Dir['vendor/*'] - Dir['vendor/{LICENSE,README}.md']
    vendor_files.each do |f|
      FileUtils.rm_rf(f)
      log_message "Removed #{f}"
    end
  end

  desc 'Clean vendor directory keeping only shared libraries'
  task :clean_keep_libs do
    # Keep only shared library files and documentation
    keep_patterns = [
      'vendor/LICENSE*',
      'vendor/README*',
      'vendor/*.dylib',  # macOS shared libraries
      'vendor/*.so',     # Linux shared libraries
      'vendor/*.dll'     # Windows shared libraries
    ]

    all_files = Dir['vendor/*']
    files_to_keep = keep_patterns.flat_map { |pattern| Dir[pattern] }
    files_to_remove = all_files - files_to_keep

    files_to_remove.each do |f|
      FileUtils.rm_rf(f)
      log_message "Removed non-library file: #{f}"
    end

    log_message "Kept #{files_to_keep.length} files (shared libraries and docs)"
  end

  # Clean up temporary directory
  task :cleanup do
    if Dir.exist?(BUILD_DIR)
      FileUtils.rm_rf BUILD_DIR
      log_message "Cleaned up #{BUILD_DIR}"
    end
  end
end

# Add cleanup to auto task
task 'vendor:auto' => 'vendor:cleanup'
