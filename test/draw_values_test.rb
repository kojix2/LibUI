require 'test_helper'

class DrawValuesTest < Minitest::Test
  def test_brush_keeps_gradient_stops_alive
    brush = LibUI::Brush.new(type: LibUI::DrawBrushTypeLinearGradient,
                             stops: [[0.0, 1.0, 0.0, 0.0, 1.0],
                                     [1.0, 0.0, 0.0, 1.0, 1.0]])
    GC.start
    native = LibUI::FFI::DrawBrush.new(brush.to_ptr)
    assert_equal 2, native.NumStops
    first = LibUI::FFI::DrawBrushGradientStop.new(native.Stops)
    second = LibUI::FFI::DrawBrushGradientStop.new(native.Stops + LibUI::FFI::DrawBrushGradientStop.size)
    assert_equal 1.0, first.R
    assert_equal 1.0, second.B
  end

  def test_stroke_keeps_dashes_alive
    stroke = LibUI::StrokeParams.new(dashes: [2.0, 3.0])
    GC.start
    native = LibUI::FFI::DrawStrokeParams.new(stroke.to_ptr)
    assert_equal 2, native.NumDashes
    assert_equal [2.0, 3.0], native.Dashes[0, 16].unpack('d*')
  end

  def test_matrix_methods_return_ruby_coordinates
    matrix = LibUI::Matrix.new.translate(4, 5)
    assert_equal [5.0, 7.0], matrix.transform_point(1, 2)
    assert_equal [1.0, 2.0], matrix.transform_size(1, 2)
  end

  def test_draw_fill_accepts_brush_and_native_struct
    passed = []
    ffi = LibUI::FFI
    original = ffi.method(:uiDrawFill)
    ffi.singleton_class.send(:remove_method, :uiDrawFill)
    ffi.define_singleton_method(:uiDrawFill) { |_context, _path, brush| passed << brush }
    brush = LibUI::Brush.new
    native = LibUI::FFI::DrawBrush.malloc
    LibUI.draw_fill(nil, nil, brush)
    LibUI.draw_fill(nil, nil, native)
    assert_equal brush.to_ptr.to_i, passed.first.to_i
    assert_same native, passed.last
  ensure
    if original
      ffi.singleton_class.send(:remove_method, :uiDrawFill)
      ffi.define_singleton_method(:uiDrawFill, original)
    end
  end
end
