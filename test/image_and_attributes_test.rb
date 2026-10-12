require 'test_helper'

class ImageAndAttributesTest < Minitest::Test
  def test_image_append_checks_dimensions_and_buffer_before_call
    calls = []
    with_ffi_stub(:uiImageAppend, proc { |*args| calls << args }) do
      LibUI.image_append(nil, "\0" * 8, 1, 2, 4)
      assert_raises(ArgumentError) { LibUI.image_append(nil, "\0" * 7, 1, 2, 4) }
      assert_raises(ArgumentError) { LibUI.image_append(nil, "\0" * 8, 2, 1, 4) }
      assert_raises(ArgumentError) { LibUI.image_append(nil, "\0" * 8, 0, 1, 4) }
      assert_raises(TypeError) { LibUI.image_append(nil, Object.new, 1, 1, 4) }
    end
    assert_equal 1, calls.length
  end

  def test_straight_rgba_is_premultiplied_without_modifying_input
    original = [255, 128, 1, 128].pack('C*')
    copied = nil
    with_ffi_stub(:uiImageAppend, proc { |_image, pixels, *_| copied = pixels.bytes }) do
      LibUI.image_append_rgba(nil, original, 1, 1)
    end
    assert_equal [128, 64, 1, 128], copied
    assert_equal [255, 128, 1, 128], original.bytes
  end

  def test_feature_iteration_and_snapshot
    callback_result = nil
    with_ffi_stub(:uiOpenTypeFeaturesForEach, proc do |_features, callback, _data|
      callback_result = callback.call(0, 108, 105, 103, 97, 1, 0)
    end) do
      assert_equal({ 'liga' => 1 }, LibUI.open_type_features_for_each(nil).to_h)
      assert_equal LibUI::ForEachContinue, callback_result
      LibUI.open_type_features_for_each(nil) { |_tag, _value| LibUI::ForEachStop }
      assert_equal LibUI::ForEachStop, callback_result
      assert_raises(RuntimeError) do
        LibUI.open_type_features_for_each(nil) { raise 'callback error' }
      end
    end
  end

  def test_attribute_iteration_copies_values_and_rethrows_errors
    with_ffi_stub(:uiAttributedStringForEachAttribute, proc do |_string, callback, _data|
      callback.call(0, 42, 0, 5, 0)
    end) do
      with_ffi_stub(:uiAttributeGetType, proc { |_attribute| LibUI::AttributeTypeSize }) do
        with_ffi_stub(:uiAttributeSize, proc { |_attribute| 12.5 }) do
          assert_equal [[{ type: LibUI::AttributeTypeSize, value: 12.5 }, 0, 5]],
                       LibUI.attributed_string_for_each_attribute(nil).to_a
          assert_raises(RuntimeError) do
            LibUI.attributed_string_for_each_attribute(nil) { raise 'callback error' }
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
