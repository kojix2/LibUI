module LibUI
  module LibUIBase
    FFI.func_map.each_key do |original_method_name|
      name = Utils.convert_to_ruby_method(original_method_name)
      func = FFI.func_map[original_method_name]

      define_method(name) do |*args, &blk|
        args << blk if blk
        retained = []
        args.map!.with_index do |arg, idx|
          next arg unless arg.is_a?(Proc)

          _f, ret_type, arg_types = func.callback_argument_types[idx]
          raise ArgumentError, "#{name} does not accept a block at argument #{idx}" unless _f

          ruby_callback = arg
          callback = Fiddle::Closure::BlockCaller.new(ret_type, arg_types) do |*callback_args|
            begin
              ruby_callback.call(*callback_args)
            rescue StandardError => e
              CallbackRegistry.report(e)
              0
            end
          end
          retained << [idx, callback]
          callback
        end

        siz = func.argument_types.size - 1
        args[siz] = nil if args.size == siz

        result = FFI.public_send(original_method_name, *args)
        retained.each do |idx, callback|
          if idx.zero? || args.first.nil?
            CallbackRegistry.global(original_method_name, callback)
          elsif original_method_name.start_with?('uiMenuItem', 'uiToolbarItem')
            CallbackRegistry.other(args.first, original_method_name, callback)
          else
            CallbackRegistry.control(args.first, original_method_name, callback)
          end
        end
        result
      end
    end
  end

  private_constant :LibUIBase
end
