module LibUI
  # Native controls can outlive the Ruby pointer returned by their constructor.
  # Keep closures by native address until libui-ng reports destruction.
  module CallbackRegistry
    @controls = {}
    @destroy_hooks = {}
    @other = {}
    @other_children = {}
    @global = {}

    class << self
      def control(pointer, key, callback)
        address = pointer.to_i
        callbacks = (@controls[address] ||= {})
        unless @destroy_hooks.key?(address)
          hook = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOID,
                                                   [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]) do |native, _data|
            begin
              user = @controls[native]&.delete(:on_destroyed)
              user[0].call(native, user[1]) if user && user[0]
            rescue StandardError => e
              report(e)
            ensure
              @controls.delete(native)
              @destroy_hooks.delete(native)
            end
          end
          @destroy_hooks[address] = hook
          begin
            FFI.uiControlOnDestroyed(pointer, hook, nil)
          rescue StandardError
            @destroy_hooks.delete(address)
            @controls.delete(address) if callbacks.empty?
            raise
          end
        end
        callbacks[key] = callback
      end

      def on_destroyed(pointer, callback, data)
        control(pointer, :on_destroyed, [callback, data])
      end

      def other(pointer, key, callback)
        (@other[pointer.to_i] ||= {})[key] = callback
      end

      def release_other(pointer)
        address = pointer.to_i
        @other.delete(address)
        (@other_children.delete(address) || []).each { |child| @other.delete(child) }
      end

      def track_other_child(parent, child)
        (@other_children[parent.to_i] ||= []) << child.to_i
      end

      def global(key, callback)
        @global[key] = callback
      end

      def release_global(key)
        @global.delete(key)
      end

      def clear
        @controls.clear
        @destroy_hooks.clear
        @other.clear
        @other_children.clear
        @global.clear
      end

      def report(error)
        warn "LibUI callback error: #{error.full_message}"
      end
    end
  end

  private_constant :CallbackRegistry
end
