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
          next arg unless arg.is_a?(Proc)

          # now arg must be Proc

          # The types of the function arguments are stored in advance.
          # See the monkey patch in ffi.rb.
          _f, ret_type, arg_types = func.callback_argument_types[idx]
          # TODO: raise some nice error if _f is nil.
          
          callback = Fiddle::Closure::BlockCaller.new(
            ret_type, arg_types, &arg
          )
          # Protect from GC
          # by giving the owner object a reference to the callback.
          # See https://github.com/kojix2/LibUI/issues/8
          owner = if idx == 0 or   # UI.queue_main{}
                     owner.frozen? # UI.timer(100) {}
                    LibUIBase # or UI is better?
                  else
                    args[0] # receiver
                  end
          if owner.instance_variable_defined?(:@callbacks)
            owner.instance_variable_get(:@callbacks) << callback
          else
            owner.instance_variable_set(:@callbacks, [callback])
          end
          callback
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
