require 'test_helper'

class TableModelTest < Minitest::Test
  def teardown
    LibUI.const_get(:CallbackRegistry).clear
  end

  def test_handler_returns_owned_native_values_and_reads_borrowed_input
    created = []
    native_value = Fiddle::Pointer.malloc(8)
    rows = [['cat']]
    handler = LibUI::TableModelHandler.new(column_types: [LibUI::TableValueTypeString], rows: rows)
    with_ffi_stub(:uiNewTableValueString, proc { |text| created << text; native_value }) do
      closure = handler.instance_variable_get(:@closures)[:cell_value]
      assert_equal native_value.to_i, closure.call(0, 0, 0, 0)
      assert_equal ['cat'], created
    end
    with_ffi_stub(:uiTableValueGetType, proc { |_value| LibUI::TableValueTypeString }) do
      with_ffi_stub(:uiTableValueString, proc { |_value| Fiddle::Pointer["dog\0"] }) do
        handler.instance_variable_get(:@closures)[:set_cell_value].call(0, 0, 0, 0, native_value.to_i)
        assert_equal [['dog']], rows
        handler.instance_variable_get(:@closures)[:set_cell_value].call(0, 0, 0, 0, 0)
        assert_equal [[nil]], rows
      end
    end
  end

  def test_model_cannot_be_freed_while_table_is_alive
    native_model = Fiddle::Pointer.malloc(8)
    native_table = Fiddle::Pointer.malloc(8)
    destroyed = nil
    freed = []
    with_ffi_stub(:uiNewTableModel, proc { |_handler| native_model }) do
      with_ffi_stub(:uiNewTable, proc { |_params| native_table }) do
        with_ffi_stub(:uiControlOnDestroyed, proc { |_table, callback, _data| destroyed = callback }) do
          with_ffi_stub(:uiFreeTableModel, proc { |model| freed << model }) do
            model = LibUI::TableModel.new(column_types: [LibUI::TableValueTypeString], rows: [['a']])
            assert_equal native_table, LibUI.new_table(model: model)
            assert_raises(RuntimeError) { model.free }
            destroyed.call(native_table.to_i, 0)
            model.free
            assert_equal [native_model], freed
            assert_raises(RuntimeError) { model.to_ptr }
          end
        end
      end
    end
  end

  def test_text_column_keyword_builds_optional_params
    captured = nil
    with_ffi_stub(:uiTableAppendTextColumn, proc { |*args| captured = args }) do
      LibUI.table_append_text_column(nil, 'Name', 0, -1, color_model_column: 2)
    end
    assert_equal 2, captured.last.ColorModelColumn
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
