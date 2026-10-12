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
        destroyed.first.call(address, 0)
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
