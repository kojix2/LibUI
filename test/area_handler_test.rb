require 'test_helper'

class AreaHandlerTest < Minitest::Test
  def teardown
    LibUI.const_get(:CallbackRegistry).clear
  end

  def test_draw_event_copies_dimensions_and_invalidates_context
    event = nil
    handler = LibUI::AreaHandler.new(draw: ->(draw_event) { event = draw_event })
    params = LibUI::FFI::AreaDrawParams.malloc
    params.Context = Fiddle::Pointer.new(123)
    params.AreaWidth = 400.0
    params.AreaHeight = 200.0
    params.ClipX = 1.0
    params.ClipY = 2.0
    params.ClipWidth = 3.0
    params.ClipHeight = 4.0
    handler.instance_variable_get(:@closures)[:draw].call(0, 0, params.to_ptr.to_i)
    assert_equal 400.0, event.area_width
    assert_equal 4.0, event.clip_height
    assert_raises(RuntimeError) { event.context.to_ptr }
  end

  def test_key_event_returns_handled_flag
    seen = nil
    handler = LibUI::AreaHandler.new(key_event: ->(event) { seen = event; true })
    native = LibUI::FFI::AreaKeyEvent.malloc
    native.Key = 97
    native.ExtKey = 0
    native.Modifier = 0
    native.Modifiers = 0
    native.Up = 1
    assert_equal 1, handler.instance_variable_get(:@closures)[:key_event].call(0, 0, native.to_ptr.to_i)
    assert_equal 97, seen.key
    assert seen.up
  end

  def test_area_keeps_handler_until_destroyed
    native_area = Fiddle::Pointer.malloc(8)
    destroyed = nil
    with_ffi_stub(:uiNewArea, proc { |_handler| native_area }) do
      with_ffi_stub(:uiControlOnDestroyed, proc { |_area, callback, _data| destroyed = callback }) do
        handler = LibUI::AreaHandler.new
        assert_equal native_area, LibUI.new_area(handler)
        retained = LibUI.const_get(:CallbackRegistry).instance_variable_get(:@controls)
        assert_same handler, retained[native_area.to_i][:area_handler]
        destroyed.call(native_area.to_i, 0)
        refute retained.key?(native_area.to_i)
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
