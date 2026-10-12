module LibUI
  # A Ruby value. to_native allocates a fresh uiTableValue whose ownership is
  # transferred to libui-ng when returned from CellValue.
  class TableValue
    attr_reader :type, :value

    def initialize(type, value)
      @type = Integer(type)
      @value = value
    end

    def to_native
      case type
      when TableValueTypeString
        raise TypeError, 'string table value must be a String' unless value.is_a?(String)
        LibUI.new_table_value_string(value)
      when TableValueTypeImage
        raise TypeError, 'image table value must be a pointer or nil' unless value.nil? || value.is_a?(Fiddle::Pointer)
        LibUI.new_table_value_image(value)
      when TableValueTypeInt
        LibUI.new_table_value_int(Integer(value))
      when TableValueTypeColor
        unless value.is_a?(Array) && value.length == 4 && value.all? { |part| part.is_a?(Numeric) }
          raise TypeError, 'color table value must be an RGBA array'
        end
        LibUI.new_table_value_color(*value)
      else
        raise ArgumentError, "unknown table value type: #{type}"
      end
    end

    def self.from_native(pointer)
      return nil if pointer.nil? || pointer.to_i.zero?

      type = LibUI.table_value_get_type(pointer)
      value = case type
              when TableValueTypeString then LibUI.table_value_string(pointer)
              when TableValueTypeImage then LibUI.table_value_image(pointer)
              when TableValueTypeInt then LibUI.table_value_int(pointer)
              when TableValueTypeColor then LibUI.table_value_color(pointer)
              else raise ArgumentError, "unknown table value type: #{type}"
              end
      new(type, value)
    end
  end

  class TableModelHandler
    attr_reader :column_types

    def initialize(column_types:, rows:, cell_value: nil, set_cell_value: nil)
      unless column_types.is_a?(Array) && column_types.all? { |type| type.is_a?(Integer) && (0..3).cover?(type) }
        raise ArgumentError, 'column_types must be an array of table value types'
      end
      unless rows.is_a?(Array) || rows.respond_to?(:call)
        raise TypeError, 'rows must be an Array or a row-count callback'
      end
      if rows.respond_to?(:call) && !cell_value
        raise ArgumentError, 'cell_value is required when rows is a callback'
      end

      @column_types = column_types.dup.freeze
      @rows = rows
      @cell_value = cell_value || ->(row, column) { @rows.fetch(row).fetch(column) }
      @set_cell_value = set_cell_value || (rows.is_a?(Array) ? ->(row, column, value) { @rows.fetch(row)[column] = value } : nil)
      @native = FFI::TableModelHandler.malloc
      @native.to_ptr.free = Fiddle::RUBY_FREE
      @closures = {}
      install_callbacks
    end

    def to_ptr
      @native.to_ptr
    end

    private

    def install_callbacks
      pointer = Fiddle::TYPE_VOIDP
      integer = Fiddle::TYPE_INT
      @closures[:num_columns] = callback(integer, [pointer, pointer]) { @column_types.length }
      @closures[:column_type] = callback(integer, [pointer, pointer, integer]) do |_handler, _model, column|
        @column_types.fetch(column)
      end
      @closures[:num_rows] = callback(integer, [pointer, pointer]) do
        @rows.respond_to?(:call) ? Integer(@rows.call) : @rows.length
      end
      @closures[:cell_value] = callback(pointer, [pointer, pointer, integer, integer]) do |_handler, _model, row, column|
        type = @column_types.fetch(column)
        begin
          value = @cell_value.call(row, column)
          table_value = value.is_a?(TableValue) ? value : TableValue.new(type, value)
          raise TypeError, 'table value type does not match model column' unless table_value.type == type
          table_value.to_native.to_i
        rescue StandardError => e
          CallbackRegistry.report(e)
          fallback = case type
                     when TableValueTypeString then ''
                     when TableValueTypeImage then nil
                     when TableValueTypeInt then 0
                     when TableValueTypeColor then [0.0, 0.0, 0.0, 0.0]
                     end
          TableValue.new(type, fallback).to_native.to_i
        end
      end
      @closures[:set_cell_value] = callback(Fiddle::TYPE_VOID,
                                            [pointer, pointer, integer, integer, pointer]) do |_handler, _model, row, column, native_value|
        @set_cell_value&.call(row, column, TableValue.from_native(native_value)&.value)
      end
      @native.NumColumns = @closures[:num_columns]
      @native.ColumnType = @closures[:column_type]
      @native.NumRows = @closures[:num_rows]
      @native.CellValue = @closures[:cell_value]
      @native.SetCellValue = @closures[:set_cell_value]
    end

    def callback(return_type, argument_types, &block)
      Fiddle::Closure::BlockCaller.new(return_type, argument_types) do |*args|
        begin
          block.call(*args)
        rescue StandardError => e
          CallbackRegistry.report(e)
          0
        end
      end
    end
  end

  class TableModel
    attr_reader :handler

    def initialize(handler = nil, **options)
      @handler = handler || TableModelHandler.new(**options)
      raise TypeError, 'expected LibUI::TableModelHandler' unless @handler.is_a?(TableModelHandler)

      @pointer = LibUI.new_table_model(@handler)
      @attached_tables = 0
      @freed = false
    end

    def to_ptr
      raise RuntimeError, 'table model has been freed' if @freed

      @pointer
    end

    def row_inserted(index)
      LibUI.table_model_row_inserted(to_ptr, index)
    end

    def row_changed(index)
      LibUI.table_model_row_changed(to_ptr, index)
    end

    def row_deleted(index)
      LibUI.table_model_row_deleted(to_ptr, index)
    end

    def free
      raise RuntimeError, 'table model is still attached to a table' if @attached_tables.positive?
      return if @freed

      LibUI.free_table_model(@pointer)
      @freed = true
      nil
    end

    def attach_table
      @attached_tables += 1
    end

    def detach_table
      @attached_tables -= 1
    end
  end
end
