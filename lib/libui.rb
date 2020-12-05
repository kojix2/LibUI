# frozen_string_literal: true

require_relative 'libui/version'

module Libui
  class Error < StandardError; end
  
  class << self
    attr_accessor :ffi_lib
  end
  self.ffi_lib = case RbConfig::CONFIG['host_os']
                 when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                   File.expand_path("libui.dll", ENV['LIBUIDIR'])
                 else # TODO: Mac
                   File.expand_path("libui.so", ENV['LIBUIDIR'])
                 end

  autoload :FFI, "libui/ffi"
end
