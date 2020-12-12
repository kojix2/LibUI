# frozen_string_literal: true

require_relative 'libui/version'

module LibUI
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  lib_name = case RbConfig::CONFIG['host_os']
             when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
               'libui.dll'
             when /darwin|mac os/
               'libui.dylib'
             else
               'libui.so'
             end

  self.ffi_lib = if ENV['LIBUIDIR'] && !ENV['LIBUIDIR'].empty?
                   File.expand_path(lib_name, ENV['LIBUIDIR'])
                 else
                   File.expand_path("../vendor/#{lib_name}", __dir__)
                 end

  require_relative 'libui/ffi'

  class << self
    FFI.func_map.keys.each do |original_method_name|
      # Convert snake_case to CamelCase.
      name = original_method_name.delete_prefix('ui')
                                 .gsub(/::/, '/')
                                 .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                                 .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                                 .tr('-', '_')
                                 .downcase

      func = FFI.func_map[original_method_name]

      define_method(name) do |*args, &blk|
        # Assume that block is the last argument.
        args << blk if blk

        # The proc object is converted to a Closure::BlockCaller object.
        args.map!.with_index do |arg, idx|
          if arg.is_a?(Proc)
            # The types of the function arguments are recorded beforehand.
            # See the monkey patch in ffi.rb.
            Fiddle::Closure::BlockCaller.new(*func.inner_functions[idx][1..2], &arg)
          else
            arg
          end
        end

        # Make it possible to omit the last nil. This may be an over-optimization.
        siz = func.argtype.size - 1
        args[siz] = nil if args.size == siz

        FFI.public_send(original_method_name, *args)
      end
    end

    module CustomMethods
      def init(opt = FFI::InitOptions.malloc)
        i = super(opt)
        unless i.size.zero?
          warn 'error'
          warn UI.free_init_error(init)
        end
      end
    end

    prepend CustomMethods
  end
end
