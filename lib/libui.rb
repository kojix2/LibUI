# frozen_string_literal: true

require_relative 'libui/version'
require_relative 'libui/utils'

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
    FFI.func_map.each_key do |original_method_name|
      name = Utils.convert_to_ruby_method(original_method_name)
      func = FFI.func_map[original_method_name]

      define_method(name) do |*args, &blk|
        # Assume that block is the last argument.
        args << blk if blk

        # The proc object is converted to a Closure::BlockCaller object.
        args.map!.with_index do |arg, idx|
          if arg.is_a?(Proc)
            # The types of the function arguments are recorded beforehand.
            # See the monkey patch in ffi.rb.
            callback = Fiddle::Closure::BlockCaller.new(
              *func.callback_argument_types[idx][1..2], &arg
            )
            # Protect from GC
            # See https://github.com/kojix2/LibUI/issues/8
            receiver = args[0]
            callbacks = receiver.instance_variable_get(:@callbacks) || []
            callbacks << callback
            receiver.instance_variable_set(:@callbacks, callback)
            callback
          else
            arg
          end
        end

        # Make it possible to omit the last nil. This may be an over-optimization.
        siz = func.argument_types.size - 1
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
