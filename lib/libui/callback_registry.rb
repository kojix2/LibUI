module LibUI
  # Native controls can outlive the Ruby pointer returned by their constructor.
  # Keep closures by native address until libui-ng reports destruction.
  module CallbackRegistry
    @controls = {}
    @destroy_hooks = {}
    @other = {}
    @other_children = {}
    @attached_toolbars = {}
    @toolbar_window_hooks = {}
    @global = {}

    class << self
      def control(pointer, key, callback)
        address = pointer.to_i
        callbacks = (@controls[address] ||= {})
        unless @destroy_hooks.key?(address)
          hook = nil
          hook = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOID,
                                                   [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP]) do |native, _data|
            destroyed_address = native.to_i
            begin
              callbacks = @controls[destroyed_address]
              callbacks&.fetch(:cleanup, [])&.each do |cleanup|
                begin
                  cleanup.call
                rescue StandardError => e
                  report(e)
                end
              end
              user = callbacks&.delete(:on_destroyed)
              user[0].call(native, user[1]) if user && user[0]
            rescue StandardError => e
              report(e)
            ensure
              @controls.delete(destroyed_address)
              @destroy_hooks.delete(destroyed_address)
              hook.to_i
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

      def on_cleanup(pointer, &block)
        control(pointer, :cleanup, []) unless @controls.dig(pointer.to_i, :cleanup)
        @controls[pointer.to_i][:cleanup] << block
      end

      def other(pointer, key, callback)
        (@other[pointer.to_i] ||= {})[key] = callback
      end

      def release_other(pointer)
        address = pointer.to_i
        @other.delete(address)
        (@other_children.delete(address) || []).each { |child| @other.delete(child) }
        @attached_toolbars.delete(address)
      end

      def track_other_child(parent, child)
        (@other_children[parent.to_i] ||= []) << child.to_i
      end

      def attach_toolbar(window, toolbar)
        window_address = window.to_i
        @attached_toolbars.delete_if { |_toolbar, owner| owner == window_address }
        @attached_toolbars[toolbar.to_i] = window_address if toolbar && toolbar.to_i != 0
        return if @toolbar_window_hooks[window_address]

        on_cleanup(window) do
          @attached_toolbars.delete_if { |_toolbar, owner| owner == window_address }
          @toolbar_window_hooks.delete(window_address)
        end
        @toolbar_window_hooks[window_address] = true
      end

      def toolbar_attached?(toolbar)
        @attached_toolbars.key?(toolbar.to_i)
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
        @attached_toolbars.clear
        @toolbar_window_hooks.clear
        @global.clear
      end

      def report(error)
        warn "LibUI callback error: #{error.full_message}"
      end
    end
  end

  private_constant :CallbackRegistry
end
