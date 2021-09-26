# frozen_string_literal: true

module LibUI
  module LibUIBase
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
            if receiver.instance_variable_defined?(:@callbacks)
              receiver.instance_variable_get(:@callbacks) << callback
            else
              receiver.instance_variable_set(:@callbacks, [callback])
            end
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
  end

  private_constant :LibUIBase
end
