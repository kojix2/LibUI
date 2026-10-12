require 'test_helper'

class PathTest < Minitest::Test
  def test_open_frees_path_after_drawing
    native_path = Fiddle::Pointer.new(123)
    freed = []
    filled = []
    with_ffi_stub(:uiDrawNewPath, proc { |_mode| native_path }) do
      with_ffi_stub(:uiDrawPathAddRectangle, proc { |*_| }) do
        with_ffi_stub(:uiDrawPathEnd, proc { |_| }) do
          with_ffi_stub(:uiDrawFill, proc { |_context, path, _brush| filled << path }) do
            with_ffi_stub(:uiDrawFreePath, proc { |path| freed << path }) do
              LibUI::Path.open do |path|
                path.add_rectangle(0, 0, 10, 10).end_path
                LibUI.draw_fill(nil, path, LibUI::Brush.new)
              end
            end
          end
        end
      end
    end
    assert_equal [native_path], filled
    assert_equal [native_path], freed
  end

  def test_open_frees_path_after_exception
    native_path = Fiddle::Pointer.new(456)
    freed = []
    path = nil
    with_ffi_stub(:uiDrawNewPath, proc { |_mode| native_path }) do
      with_ffi_stub(:uiDrawFreePath, proc { |pointer| freed << pointer }) do
        assert_raises(ArgumentError) do
          LibUI::Path.open do |opened_path|
            path = opened_path
            raise ArgumentError, 'draw failed'
          end
        end
      end
    end
    assert_equal [native_path], freed
    assert_raises(RuntimeError) { path.to_ptr }
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
