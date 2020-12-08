# frozen_string_literal: true

require_relative 'libui/version'

module LibUI
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  self.ffi_lib = case RbConfig::CONFIG['host_os']
                 when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                   # File.expand_path("libui.dll", ENV['LIBUIDIR'])
                   File.expand_path('../vendor/libui.dll', __dir__)
                 when /darwin|mac os/
                   # File.expand_path("libui.dylib", ENV['LIBUIDIR'])
                   File.expand_path('../vendor/libui.dylib', __dir__)
                 else # TODO: Mac
                   # File.expand_path("libui.so", ENV['LIBUIDIR'])
                   File.expand_path('../vendor/libui.so', __dir__)
                 end

  require_relative 'libui/ffi'

  class << self
    FFI.ffi_methods.each do |original_method_name|
      name = original_method_name.delete_prefix('ui')
                                 .gsub(/::/, '/')
                                 .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                                 .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                                 .tr('-', '_')
                                 .downcase
      define_method(name) do |*args|
        FFI.public_send(original_method_name, *args)
      end
    end
  end
end
