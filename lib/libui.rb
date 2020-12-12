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
    FFI.func_map.keys.each do |original_method_name|
      name = original_method_name.delete_prefix('ui')
                                 .gsub(/::/, '/')
                                 .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                                 .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                                 .tr('-', '_')
                                 .downcase
      func = FFI.func_map[original_method_name]
      define_method(name) do |*args, &blk|
        args << blk if blk
        args.map!.with_index do |arg, idx|
          if arg.is_a?(Proc)
            Fiddle::Closure::BlockCaller.new(*func.inner_functions[idx][1..2], &arg)
          else
            arg
          end
        end
        siz = func.argtype.size
        if args.size < siz
          args[siz-1] = nil
        end
        FFI.public_send(original_method_name, *args)
      end
    end
  end
end
