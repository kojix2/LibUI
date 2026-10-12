require 'test_helper'

class CallbackLifetimeTest < Minitest::Test
  def teardown
    LibUI.const_get(:CallbackRegistry).clear
  end

  def test_control_callback_survives_pointer_gc_and_is_released_on_destroy
    callbacks = []
    destroyed = []
    with_ffi_stub(:uiButtonOnClicked, proc { |_button, callback, _data| callbacks << callback }) do
      with_ffi_stub(:uiControlOnDestroyed, proc { |_button, callback, _data| destroyed << callback }) do
        pointer = Fiddle::Pointer.malloc(8)
        address = pointer.to_i
        events = []
        LibUI.button_on_clicked(pointer) { events << :first }
        LibUI.button_on_clicked(Fiddle::Pointer.new(address)) { events << :second }
        LibUI.control_on_destroyed(Fiddle::Pointer.new(address)) { |_native, _data| events << :destroyed }

        assert_equal 1, destroyed.length
        GC.start
        callbacks.last.call(address, 0)
        assert_equal [:second], events
        destroyed.first.call(Fiddle::Pointer.new(address), 0)
        assert_equal [:second, :destroyed], events
        registry = LibUI.const_get(:CallbackRegistry)
        refute registry.instance_variable_get(:@controls).key?(address)
      end
    end
  end

  def test_callback_exceptions_do_not_cross_native_boundary
    callback = nil
    with_ffi_stub(:uiWindowOnClosing, proc { |_window, cb, _data| callback = cb }) do
      with_ffi_stub(:uiControlOnDestroyed, proc { |_window, _cb, _data| }) do
        pointer = Fiddle::Pointer.malloc(8)
        _out, err = capture_io do
          LibUI.window_on_closing(pointer) { raise 'failed in callback' }
          assert_equal 0, callback.call(pointer.to_i, 0)
        end
        assert_includes err, 'failed in callback'
      end
    end
  end

  def test_one_shot_and_timer_callbacks_release_their_roots
    queued = nil
    timed = nil
    with_ffi_stub(:uiQueueMain, proc { |callback, _data| queued = callback }) do
      with_ffi_stub(:uiTimer, proc { |_interval, callback, _data| timed = callback }) do
        registry = LibUI.const_get(:CallbackRegistry)
        LibUI.queue_main { :done }
        LibUI.timer(1) { false }
        assert_equal 2, registry.instance_variable_get(:@global).length
        queued.call(0)
        assert_equal 1, registry.instance_variable_get(:@global).length
        assert_equal 0, timed.call(0)
        assert_empty registry.instance_variable_get(:@global)
      end
    end
  end

  def test_attached_toolbar_keeps_item_callbacks_until_detached_and_freed
    window = Fiddle::Pointer.malloc(8)
    toolbar = Fiddle::Pointer.malloc(8)
    item = Fiddle::Pointer.malloc(8)
    destroyed = nil
    freed = 0
    with_ffi_stub(:uiWindowSetToolbar, proc { |_window, _toolbar| }) do
      with_ffi_stub(:uiControlOnDestroyed, proc { |_window, callback, _data| destroyed = callback }) do
        with_ffi_stub(:uiToolbarAppendButton, proc { |_toolbar, _text, _icon| item }) do
          with_ffi_stub(:uiToolbarItemOnClicked, proc { |_item, _callback, _data| }) do
            with_ffi_stub(:uiFreeToolbar, proc { |_toolbar| freed += 1 }) do
              LibUI.toolbar_append_button(toolbar, 'Test')
              LibUI.toolbar_item_on_clicked(item) { :clicked }
              LibUI.window_set_toolbar(window, toolbar)
              assert_raises(RuntimeError) { LibUI.free_toolbar(toolbar) }
              assert_equal 0, freed
              destroyed.call(Fiddle::Pointer.new(window.to_i), 0)
              LibUI.free_toolbar(toolbar)
              assert_equal 1, freed
              refute LibUI.const_get(:CallbackRegistry).instance_variable_get(:@other).key?(item.to_i)
            end
          end
        end
      end
    end
  end

  private

  def with_ffi_stub(name, replacement)
    ffi = LibUI::FFI
    original = ffi.method(name)
    ffi.singleton_class.send(:remove_method, name)
    ffi.define_singleton_method(name, &replacement)
    yield
  ensure
    if original
      ffi.singleton_class.send(:remove_method, name)
      ffi.define_singleton_method(name, original)
    end
  end
end
