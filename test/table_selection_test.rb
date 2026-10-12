require 'test_helper'

class TableSelectionTest < Minitest::Test
  def test_table_set_selection_accepts_row_arrays_and_clears_with_empty_array
    captured = []
    with_ffi_stub(:uiTableSetSelection, proc do |_table, selection|
      GC.start
      rows = selection.Rows
      captured << [selection.NumRows, rows.null?,
                   Array.new(selection.NumRows) do |index|
                     rows[index * Fiddle::SIZEOF_INT, Fiddle::SIZEOF_INT].unpack1('i')
                   end]
      nil
    end) do
      assert_nil LibUI.table_set_selection(nil, [1, 3])
      assert_nil LibUI.table_set_selection(nil, [])
    end

    assert_equal [[2, false, [1, 3]], [0, true, []]], captured
  end

  def test_table_set_selection_rejects_invalid_row_indices_before_native_call
    calls = 0
    with_ffi_stub(:uiTableSetSelection, proc { |_table, _selection| calls += 1 }) do
      max_int = (1 << (Fiddle::SIZEOF_INT * 8 - 1)) - 1
      assert_raises(TypeError) { LibUI.table_set_selection(nil, [1.5]) }
      assert_raises(RangeError) { LibUI.table_set_selection(nil, [-1]) }
      assert_raises(RangeError) { LibUI.table_set_selection(nil, [max_int + 1]) }
      assert_raises(TypeError) { LibUI.table_set_selection(nil, nil) }
      assert_raises(TypeError) { LibUI.table_set_selection(nil, Fiddle::Pointer.new(0)) }
    end
    assert_equal 0, calls
  end

  def test_table_set_selection_keeps_native_struct_and_pointer_arguments
    passed = []
    with_ffi_stub(:uiTableSetSelection, proc { |_table, selection| passed << selection }) do
      selection = LibUI::FFI::TableSelection.malloc
      selection.NumRows = 0
      selection.Rows = Fiddle::Pointer.new(0)
      LibUI.table_set_selection(nil, selection)
      LibUI.table_set_selection(nil, selection.to_ptr)
      assert_same selection, passed[0]
      assert_equal selection.to_ptr.to_i, passed[1].to_i
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
