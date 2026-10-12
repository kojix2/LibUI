require_relative 'libui/version'
require_relative 'libui/utils'
require_relative 'libui/error'
require_relative 'libui/platform'
require 'date'

module LibUI
  class << self
    attr_accessor :ffi_lib
  end

  self.ffi_lib = \
    if ENV['LIBUIDIR'] && !ENV['LIBUIDIR'].empty?
      Platform.current_lib_names.lazy
              .map { |name| File.expand_path(name, ENV['LIBUIDIR']) }
              .find { |path| File.exist?(path) }
    else
      Platform.current_lib_names.lazy
              .map { |name| File.expand_path("../vendor/#{name}", __dir__) }
              .find { |path| File.exist?(path) }
    end

  require_relative 'libui/ffi'
  require_relative 'libui/callback_registry'
  require_relative 'libui/libui_base'
  require_relative 'libui/font'
  require_relative 'libui/area_handler'
  require_relative 'libui/table_model'
  require_relative 'libui/draw_values'

  extend LibUIBase

  class << self
    def control_on_destroyed(control, callback = nil, data = nil, &block)
      callback = block if block
      unless callback.nil? || callback.respond_to?(:call)
        raise TypeError, 'expected a callable destruction callback'
      end
      CallbackRegistry.on_destroyed(control, callback, data)
      nil
    end

    def queue_main(callback = nil, data = nil, &block)
      callback = block if block
      raise TypeError, 'expected a callable callback' unless callback.respond_to?(:call)

      key = Object.new
      closure = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_VOID, [Fiddle::TYPE_VOIDP]) do |native_data|
        begin
          callback.call(native_data)
        rescue StandardError => e
          CallbackRegistry.report(e)
        ensure
          CallbackRegistry.release_global(key)
        end
      end
      CallbackRegistry.global(key, closure)
      FFI.uiQueueMain(closure, data)
    rescue StandardError
      CallbackRegistry.release_global(key) if key
      raise
    end

    def timer(milliseconds, callback = nil, data = nil, &block)
      callback = block if block
      raise TypeError, 'expected a callable callback' unless callback.respond_to?(:call)

      key = Object.new
      closure = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_INT, [Fiddle::TYPE_VOIDP]) do |native_data|
        result = begin
          value = callback.call(native_data)
          value == true ? 1 : (value == false || value.nil? ? 0 : Integer(value))
        rescue StandardError => e
          CallbackRegistry.report(e)
          0
        end
        CallbackRegistry.release_global(key) if result.zero?
        result
      end
      CallbackRegistry.global(key, closure)
      FFI.uiTimer(milliseconds, closure, data)
    rescue StandardError
      CallbackRegistry.release_global(key) if key
      raise
    end

    def uninit
      result = super
      CallbackRegistry.clear
      result
    end

    def toolbar_append_button(toolbar, text, icon = nil)
      item = super(toolbar, text, icon)
      CallbackRegistry.track_other_child(toolbar, item)
      item
    end

    def toolbar_append_toggle_button(toolbar, text, icon = nil)
      item = super(toolbar, text, icon)
      CallbackRegistry.track_other_child(toolbar, item)
      item
    end

    def free_toolbar(toolbar)
      result = super(toolbar)
      CallbackRegistry.release_other(toolbar)
      result
    end

    def new_area(handler)
      return super(handler) unless handler.is_a?(AreaHandler)

      area = super(handler.to_ptr)
      CallbackRegistry.control(area, :area_handler, handler)
      area
    end

    def new_scrolling_area(handler, width, height)
      return super(handler, width, height) unless handler.is_a?(AreaHandler)

      area = super(handler.to_ptr, width, height)
      CallbackRegistry.control(area, :area_handler, handler)
      area
    end

    def new_table_model(handler)
      return super(handler) unless handler.is_a?(TableModelHandler)

      model = super(handler.to_ptr)
      CallbackRegistry.other(model, :table_model_handler, handler)
      model
    end

    def free_table_model(model)
      return model.free if model.is_a?(TableModel)

      result = super(model)
      CallbackRegistry.release_other(model)
      result
    end

    def new_table(params = nil, model: nil, row_background_color_model_column: -1)
      return super(params) if model.nil?
      raise ArgumentError, 'provide params or model, not both' unless params.nil?
      raise TypeError, 'expected LibUI::TableModel' unless model.is_a?(TableModel)

      native = FFI::TableParams.malloc
      native.to_ptr.free = Fiddle::RUBY_FREE
      native.Model = model.to_ptr
      native.RowBackgroundColorModelColumn = row_background_color_model_column
      table = super(native)
      model.attach_table
      CallbackRegistry.control(table, :table_model, model)
      CallbackRegistry.on_cleanup(table) { model.detach_table }
      table
    end

    def table_append_text_column(table, name, text_column, editable_column, options = nil,
                                 color_model_column: nil)
      super(table, name, text_column, editable_column,
            table_text_params(options, color_model_column))
    end

    def table_append_image_text_column(table, name, image_column, text_column,
                                       editable_column, options = nil, color_model_column: nil)
      super(table, name, image_column, text_column, editable_column,
            table_text_params(options, color_model_column))
    end

    def table_append_checkbox_text_column(table, name, checkbox_column,
                                          checkbox_editable_column, text_column,
                                          text_editable_column, options = nil,
                                          color_model_column: nil)
      super(table, name, checkbox_column, checkbox_editable_column,
            text_column, text_editable_column,
            table_text_params(options, color_model_column))
    end

    def draw_fill(context, path, brush)
      super(context, path, brush.is_a?(Brush) ? brush.to_ptr : brush)
    end

    def draw_stroke(context, path, brush, stroke_params)
      super(context, path,
            brush.is_a?(Brush) ? brush.to_ptr : brush,
            stroke_params.is_a?(StrokeParams) ? stroke_params.to_ptr : stroke_params)
    end

    def draw_transform(context, matrix)
      super(context, matrix.is_a?(Matrix) ? matrix.to_ptr : matrix)
    end

    def version
      super.to_s
    end

    def init(opt = nil)
      # Allocate uiInitOptions if not provided
      unless opt
        opt = FFI::InitOptions.malloc
        opt.to_ptr.free = Fiddle::RUBY_FREE
        opt.Size = FFI::InitOptions.size
      end

      err_ptr = super(opt) # uiInit returns const char* error or NULL on success
      return nil if err_ptr.null?

      # Convert C string to Ruby string and free the error string per API contract
      err_msg = err_ptr.to_s
      free_init_error(err_ptr)
      warn err_msg
      nil
    end

    def new_button(text = '')
      super(text)
    end

    def new_checkbox(text = '')
      super(text)
    end

    def window_set_title(window, title = '')
      super(window, title)
    end

    def button_set_text(button, text = '')
      super(button, text)
    end

    def checkbox_set_text(checkbox, text = '')
      super(checkbox, text)
    end

    def entry_set_text(entry, text = '')
      super(entry, text)
    end

    def label_set_text(label, text = '')
      super(label, text)
    end

    def new_label(text = '')
      super(text)
    end

    def group_set_title(group, title = '')
      super(group, title)
    end

    def new_group(title = '')
      super(title)
    end

    def combobox_append(combobox, text = '')
      super(combobox, text)
    end

    def combobox_insert_at(combobox, index, text = '')
      super(combobox, index, text)
    end

    def editable_combobox_append(combobox, text = '')
      super(combobox, text)
    end

    def editable_combobox_set_text(combobox, text = '')
      super(combobox, text)
    end

    def radio_buttons_append(radio_buttons, text = '')
      super(radio_buttons, text)
    end

    def multiline_entry_set_text(entry, text = '')
      super(entry, text)
    end

    def multiline_entry_append(entry, text = '')
      super(entry, text)
    end

    def menu_append_item(menu, name = '')
      super(menu, name)
    end

    def menu_append_check_item(menu, name = '')
      super(menu, name)
    end

    def new_menu(name = '')
      super(name)
    end

    def msg_box(parent, title, description = '')
      super(parent, title, description)
    end

    def msg_box_error(parent, title, description = '')
      super(parent, title, description)
    end

    def new_attributed_string(initial_string = '')
      super(initial_string)
    end

    def attributed_string_append_unattributed(attributed_string, str = '')
      super(attributed_string, str)
    end

    def new_table_value_string(str = '')
      super(str)
    end

    def load_control_font(descriptor = nil)
      return super(descriptor) if descriptor

      read_font_descriptor { |native| super(native) }
    end

    def font_button_font(button, descriptor = nil)
      return super(button, descriptor) if descriptor

      read_font_descriptor { |native| super(button, native) }
    end

    def draw_new_text_layout(string_or_params, font: nil, width: -1, align: DrawTextAlignLeft)
      return super(string_or_params) if font.nil?
      raise TypeError, 'expected LibUI::Font' unless font.is_a?(Font)

      native_family = Fiddle::Pointer.malloc(font.family.bytesize + 1, Fiddle::RUBY_FREE)
      native_family[0, font.family.bytesize + 1] = font.family + "\0"
      native_font = FFI::FontDescriptor.malloc
      native_font.to_ptr.free = Fiddle::RUBY_FREE
      native_font.Family = native_family
      native_font.Size = font.size
      native_font.Weight = font.weight
      native_font.Italic = font.italic
      native_font.Stretch = font.stretch

      params = FFI::DrawTextLayoutParams.malloc
      params.to_ptr.free = Fiddle::RUBY_FREE
      params.String = string_or_params
      params.DefaultFont = native_font
      params.Width = width
      params.Align = align
      result = super(params)
      # Keep both native allocations alive through the native call.
      native_font.to_ptr.to_i
      native_family.to_i
      result
    end

    def window_title(window)
      read_owned_text(super(window))
    end

    def button_text(button)
      read_owned_text(super(button))
    end

    def checkbox_text(checkbox)
      read_owned_text(super(checkbox))
    end

    def entry_text(entry)
      read_owned_text(super(entry))
    end

    def label_text(label)
      read_owned_text(super(label))
    end

    def group_title(group)
      read_owned_text(super(group))
    end

    def editable_combobox_text(combobox)
      read_owned_text(super(combobox))
    end

    def multiline_entry_text(entry)
      read_owned_text(super(entry))
    end

    def open_file(window)
      read_owned_text(super(window))
    end

    def open_folder(window)
      read_owned_text(super(window))
    end

    def save_file(window)
      read_owned_text(super(window))
    end

    def attribute_family(attribute)
      read_borrowed_text(super(attribute))
    end

    def attributed_string_string(attributed_string)
      read_borrowed_text(super(attributed_string))
    end

    def table_value_string(value)
      read_borrowed_text(super(value))
    end

    def date_time_picker_time(picker)
      tm = FFI::TM.malloc
      tm.to_ptr.free = Fiddle::RUBY_FREE
      super(picker, tm)
      if tm.tm_isdst.negative?
        Time.local(tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
                   tm.tm_hour, tm.tm_min, tm.tm_sec)
      else
        # The ten-argument form preserves which side of a repeated DST hour was selected.
        Time.local(tm.tm_sec, tm.tm_min, tm.tm_hour, tm.tm_mday,
                   tm.tm_mon + 1, tm.tm_year + 1900, 0, 0,
                   tm.tm_isdst != 0, nil)
      end
    end

    def date_time_picker_set_time(picker, value)
      local_time = case value
                   when Time, DateTime then value.to_time.getlocal
                   when Date then Time.local(value.year, value.month, value.day)
                   else raise TypeError, 'expected Time, DateTime, or Date'
                   end
      tm = FFI::TM.malloc
      tm.to_ptr.free = Fiddle::RUBY_FREE
      tm.to_ptr[0, FFI::TM.size] = "\0" * FFI::TM.size
      tm.tm_sec = local_time.sec
      tm.tm_min = local_time.min
      tm.tm_hour = local_time.hour
      tm.tm_mday = local_time.day
      tm.tm_mon = local_time.month - 1
      tm.tm_year = local_time.year - 1900
      tm.tm_wday = local_time.wday
      tm.tm_yday = local_time.yday - 1
      tm.tm_isdst = Fiddle::WINDOWS ? -1 : (local_time.dst? ? 1 : 0)
      super(picker, tm)
    end

    def toolbar_item_text(item)
      read_owned_text(super(item))
    end

    def toolbar_item_tooltip(item)
      read_owned_text(super(item))
    end

    def window_content_size(window)
      read_outputs('i', 2) { |width, height| super(window, width, height) }
    end

    def color_button_color(button)
      read_outputs('d', 4) { |r, g, b, a| super(button, r, g, b, a) }
    end

    def table_value_color(value)
      read_outputs('d', 4) { |r, g, b, a| super(value, r, g, b, a) }
    end

    def attribute_color(attribute)
      read_outputs('d', 4) { |r, g, b, a| super(attribute, r, g, b, a) }
    end

    def attribute_underline_color(attribute)
      color = nil
      underline = read_outputs('i', 1) do |type|
        color = read_outputs('d', 4) do |r, g, b, a|
          super(attribute, type, r, g, b, a)
        end
      end
      underline + color
    end

    def draw_text_layout_extents(layout)
      read_outputs('d', 2) { |width, height| super(layout, width, height) }
    end

    def draw_matrix_transform_point(matrix, x, y)
      matrix = matrix.to_ptr if matrix.is_a?(Matrix)
      x_pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE)
      y_pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE)
      x_pointer[0, Fiddle::SIZEOF_DOUBLE] = [x].pack('d')
      y_pointer[0, Fiddle::SIZEOF_DOUBLE] = [y].pack('d')
      super(matrix, x_pointer, y_pointer)
      [x_pointer[0, Fiddle::SIZEOF_DOUBLE].unpack1('d'),
       y_pointer[0, Fiddle::SIZEOF_DOUBLE].unpack1('d')]
    end

    def draw_matrix_transform_size(matrix, x, y)
      matrix = matrix.to_ptr if matrix.is_a?(Matrix)
      x_pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE)
      y_pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_DOUBLE, Fiddle::RUBY_FREE)
      x_pointer[0, Fiddle::SIZEOF_DOUBLE] = [x].pack('d')
      y_pointer[0, Fiddle::SIZEOF_DOUBLE] = [y].pack('d')
      super(matrix, x_pointer, y_pointer)
      [x_pointer[0, Fiddle::SIZEOF_DOUBLE].unpack1('d'),
       y_pointer[0, Fiddle::SIZEOF_DOUBLE].unpack1('d')]
    end

    def table_get_selection(table)
      selection = super(table)
      return nil if selection.nil? || selection.null?

      data = FFI::TableSelection.new(selection)
      rows = data.Rows
      Array.new(data.NumRows) do |index|
        rows[index * Fiddle::SIZEOF_INT, Fiddle::SIZEOF_INT].unpack1('i')
      end
    ensure
      free_table_selection(selection) if selection && !selection.null?
    end

    def table_set_selection(table, rows)
      unless rows.is_a?(Array)
        valid_native = rows.is_a?(FFI::TableSelection) ||
                       (rows.is_a?(Fiddle::Pointer) && !rows.null?)
        raise TypeError, 'expected an Array or native uiTableSelection' unless valid_native

        return super(table, rows)
      end

      max_int = (1 << (Fiddle::SIZEOF_INT * 8 - 1)) - 1
      raise RangeError, 'too many selected rows' if rows.length > max_int

      rows.each do |row|
        raise TypeError, 'row index must be an Integer' unless row.is_a?(Integer)
        raise RangeError, 'row index is out of range' unless row.between?(0, max_int)
      end

      native_rows = if rows.empty?
                      Fiddle::Pointer.new(0)
                    else
                      packed = rows.pack('i*')
                      pointer = Fiddle::Pointer.malloc(packed.bytesize, Fiddle::RUBY_FREE)
                      pointer[0, packed.bytesize] = packed
                      pointer
                    end
      selection = FFI::TableSelection.malloc
      selection.to_ptr.free = Fiddle::RUBY_FREE
      selection.NumRows = rows.length
      selection.Rows = native_rows
      result = super(table, selection)
      # Keep both native allocations alive until libui-ng copies the rows.
      selection.to_ptr.to_i
      native_rows.to_i
      result
    end

    # Gets the window position.
    # Coordinates are measured from the top left corner of the screen.
    # @param w [Fiddle::Pointer] Pointer of uiWindow instance.
    # @return [Array] position of the window. [x, y]
    # @note This method may return inaccurate or dummy values on Unix platforms.

    def window_position(w)
      x_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)
      y_ptr = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)
      super(w, x_ptr, y_ptr)
      x = x_ptr[0, Fiddle::SIZEOF_INT].unpack1('i*')
      y = y_ptr[0, Fiddle::SIZEOF_INT].unpack1('i*')
      [x, y]
    end

    # FIXME: This is a workaround for a old version of Fiddle.
    # Fiddle 1.1.2 and above should be able to handle one character string.
    # See https://github.com/ruby/fiddle/issues/96

    def open_type_features_add(otf, a, b, c, d, value)
      a, b, c, d = [a, b, c, d].map { |s| s.is_a?(String) ? s.ord : s }
      super(otf, a, b, c, d, value)
    end

    def open_type_features_remove(otf, a, b, c, d)
      a, b, c, d = [a, b, c, d].map { |s| s.is_a?(String) ? s.ord : s }
      super(otf, a, b, c, d)
    end

    def open_type_features_get(otf, a, b, c, d)
      a, b, c, d = [a, b, c, d].map { |s| s.is_a?(String) ? s.ord : s }
      value = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT, Fiddle::RUBY_FREE)
      return nil if super(otf, a, b, c, d, value).zero?

      value[0, Fiddle::SIZEOF_INT].unpack1('L')
    end

    # The native function copies the pixels before returning. The input must be
    # premultiplied RGBA, with rows separated by byte_stride bytes.
    def image_append(image, pixels, width, height, byte_stride)
      [width, height, byte_stride].each do |number|
        raise TypeError, 'image dimensions and stride must be Integers' unless number.is_a?(Integer)
      end
      raise ArgumentError, 'image dimensions must be positive' if width <= 0 || height <= 0
      raise ArgumentError, 'byte stride is too small' if byte_stride < width * 4
      raise TypeError, 'pixels must be a String or Fiddle::Pointer' unless pixels.is_a?(String) || pixels.is_a?(Fiddle::Pointer)
      if pixels.is_a?(String) && pixels.bytesize < byte_stride * height
        raise ArgumentError, 'pixel buffer is shorter than stride * height'
      end
      if pixels.is_a?(Fiddle::Pointer) && pixels.size.positive? && pixels.size < byte_stride * height
        raise ArgumentError, 'pixel buffer is shorter than stride * height'
      end

      super(image, pixels, width, height, byte_stride)
    end

    # Convert straight RGBA (as used by PNG libraries) to premultiplied RGBA.
    def image_append_rgba(image, pixels, width, height, byte_stride = width * 4)
      raise TypeError, 'pixels must be a String' unless pixels.is_a?(String)
      raise ArgumentError, 'byte stride is too small' if byte_stride < width * 4
      raise ArgumentError, 'pixel buffer is shorter than stride * height' if pixels.bytesize < byte_stride * height

      converted = pixels.b.dup
      height.times do |y|
        width.times do |x|
          offset = y * byte_stride + x * 4
          alpha = converted.getbyte(offset + 3)
          3.times do |channel|
            converted.setbyte(offset + channel, (converted.getbyte(offset + channel) * alpha + 127) / 255)
          end
        end
      end
      image_append(image, converted, width, height, byte_stride)
    end

    def open_type_features_for_each(features)
      return enum_for(__method__, features) unless block_given?

      error = nil
      callback = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_INT,
                                                  [Fiddle::TYPE_VOIDP] + [Fiddle::TYPE_CHAR] * 4 +
                                                  [Fiddle::TYPE_UINT32_T, Fiddle::TYPE_VOIDP]) do |_features, a, b, c, d, value, _data|
        begin
          tag = [a, b, c, d].pack('C*').force_encoding(Encoding::ASCII_8BIT)
          yield(tag, value) == ForEachStop ? ForEachStop : ForEachContinue
        rescue StandardError => e
          error = e
          ForEachStop
        end
      end
      FFI.uiOpenTypeFeaturesForEach(features, callback, nil)
      raise error if error

      features
    end

    def attribute_features(attribute)
      borrowed = super(attribute)
      return nil if borrowed.nil? || borrowed.null?

      open_type_features_for_each(borrowed).to_h
    end

    # Values are copied during the callback; native attribute pointers expire
    # as soon as the callback returns.
    def attributed_string_for_each_attribute(string)
      return enum_for(__method__, string) unless block_given?

      error = nil
      callback = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_INT,
                                                  [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP,
                                                   Fiddle::TYPE_SIZE_T, Fiddle::TYPE_SIZE_T,
                                                   Fiddle::TYPE_VOIDP]) do |_string, attribute, first, last, _data|
        begin
          yield(attribute_snapshot(attribute), first, last) == ForEachStop ? ForEachStop : ForEachContinue
        rescue StandardError => e
          error = e
          ForEachStop
        end
      end
      FFI.uiAttributedStringForEachAttribute(string, callback, nil)
      raise error if error

      string
    end

    private

    def table_text_params(options, color_model_column)
      return options if color_model_column.nil?
      raise ArgumentError, 'provide options or color_model_column, not both' unless options.nil?

      native = FFI::TableTextColumnOptionalParams.malloc
      native.to_ptr.free = Fiddle::RUBY_FREE
      native.ColorModelColumn = Integer(color_model_column)
      native
    end

    def attribute_snapshot(attribute)
      type = attribute_get_type(attribute)
      value = case type
              when AttributeTypeFamily then attribute_family(attribute)
              when AttributeTypeSize then attribute_size(attribute)
              when AttributeTypeWeight then attribute_weight(attribute)
              when AttributeTypeItalic then attribute_italic(attribute)
              when AttributeTypeStretch then attribute_stretch(attribute)
              when AttributeTypeColor then attribute_color(attribute)
              # libui-ng exposes no getter for a background attribute's color.
              when AttributeTypeBackground then nil
              when AttributeTypeUnderline then attribute_underline(attribute)
              when AttributeTypeUnderlineColor then attribute_underline_color(attribute)
              when AttributeTypeFeatures then attribute_features(attribute)
              else raise ArgumentError, "unknown attribute type: #{type}"
              end
      { type: type, value: value }
    end

    def read_font_descriptor
      descriptor = FFI::FontDescriptor.malloc
      descriptor.to_ptr.free = Fiddle::RUBY_FREE
      filled = false
      yield(descriptor)
      filled = true
      Font.new(family: descriptor.Family.to_s.force_encoding(Encoding::UTF_8),
               size: descriptor.Size, weight: descriptor.Weight,
               italic: descriptor.Italic, stretch: descriptor.Stretch)
    ensure
      free_font_descriptor(descriptor) if filled
    end

    def read_owned_text(pointer)
      return nil if pointer.nil? || pointer.null?

      pointer.to_s.force_encoding(Encoding::UTF_8)
    ensure
      free_text(pointer) if pointer && !pointer.null?
    end

    def read_borrowed_text(pointer)
      return nil if pointer.nil? || pointer.null?

      pointer.to_s.force_encoding(Encoding::UTF_8)
    end

    def read_outputs(format, count)
      size = format == 'd' ? Fiddle::SIZEOF_DOUBLE : Fiddle::SIZEOF_INT
      pointers = Array.new(count) { Fiddle::Pointer.malloc(size, Fiddle::RUBY_FREE) }
      yield(*pointers)
      pointers.map { |pointer| pointer[0, size].unpack1(format) }
    end
  end

  ## UI_ENUM https://github.com/libui-ng/libui-ng/blob/master/ui.h

  # ForEach
  ForEachContinue    =    0
  ForEachStop        =    1

  # WindowResizeEdge
  WindowResizeEdgeLeft        = 0
  WindowResizeEdgeTop         = 1
  WindowResizeEdgeRight       = 2
  WindowResizeEdgeBottom      = 3
  WindowResizeEdgeTopLeft     = 4
  WindowResizeEdgeTopRight    = 5
  WindowResizeEdgeBottomLeft  = 6
  WindowResizeEdgeBottomRight = 7

  # DrawBrushType
  DrawBrushTypeSolid          = 0
  DrawBrushTypeLinearGradient = 1
  DrawBrushTypeRadialGradient = 2
  DrawBrushTypeImage          = 3

  # DrawLineCap
  DrawLineCapFlat   = 0
  DrawLineCapRound  = 1
  DrawLineCapSquare = 2

  # DrawLineJoin
  DrawLineJoinMiter = 0
  DrawLineJoinRound = 1
  DrawLineJoinBevel = 2

  DrawDefaultMiterLimit = 10.0

  # DrawFillMode
  DrawFillModeWinding   = 0
  DrawFillModeAlternate = 1

  # AttributeType
  AttributeTypeFamily         = 0
  AttributeTypeSize           = 1
  AttributeTypeWeight         = 2
  AttributeTypeItalic         = 3
  AttributeTypeStretch        = 4
  AttributeTypeColor          = 5
  AttributeTypeBackground     = 6
  AttributeTypeUnderline      = 7
  AttributeTypeUnderlineColor = 8
  AttributeTypeFeatures       = 9

  # TextWeight
  TextWeightMinimum    = 0
  TextWeightThin       = 100
  TextWeightUltraLight = 200
  TextWeightLight      = 300
  TextWeightBook       = 350
  TextWeightNormal     = 400
  TextWeightMedium     = 500
  TextWeightSemiBold   = 600
  TextWeightBold       = 700
  TextWeightUltraBold  = 800
  TextWeightHeavy      = 900
  TextWeightUltraHeavy = 950
  TextWeightMaximum    = 1000

  # TextItalic
  TextItalicNormal  = 0
  TextItalicOblique = 1
  TextItalicItalic  = 2

  # TextStretch
  TextStretchUltraCondensed = 0
  TextStretchExtraCondensed = 1
  TextStretchCondensed      = 2
  TextStretchSemiCondensed  = 3
  TextStretchNormal         = 4
  TextStretchSemiExpanded   = 5
  TextStretchExpanded       = 6
  TextStretchExtraExpanded  = 7
  TextStretchUltraExpanded  = 8

  # Underline
  UnderlineNone       = 0
  UnderlineSingle     = 1
  UnderlineDouble     = 2
  UnderlineSuggestion = 3

  # UnderlineColor
  UnderlineColorCustom    = 0
  UnderlineColorSpelling  = 1
  UnderlineColorGrammar   = 2
  UnderlineColorAuxiliary = 3

  # DrawTextAlign
  DrawTextAlignLeft   = 0
  DrawTextAlignCenter = 1
  DrawTextAlignRight  = 2

  # Modifiers
  ModifierCtrl  = (1 << 0)
  ModifierAlt   = (1 << 1)
  ModifierShift = (1 << 2)
  ModifierSuper = (1 << 3)

  # ExtKey
  ExtKeyEscape    = 1
  ExtKeyInsert    = 2
  ExtKeyDelete    = 3
  ExtKeyHome      = 4
  ExtKeyEnd       = 5
  ExtKeyPageUp    = 6
  ExtKeyPageDown  = 7
  ExtKeyUp        = 8
  ExtKeyDown      = 9
  ExtKeyLeft      = 10
  ExtKeyRight     = 11
  ExtKeyF1        = 12
  ExtKeyF2        = 13
  ExtKeyF3        = 14
  ExtKeyF4        = 15
  ExtKeyF5        = 16
  ExtKeyF6        = 17
  ExtKeyF7        = 18
  ExtKeyF8        = 19
  ExtKeyF9        = 20
  ExtKeyF10       = 21
  ExtKeyF11       = 22
  ExtKeyF12       = 23
  ExtKeyN0        = 24
  ExtKeyN1        = 25
  ExtKeyN2        = 26
  ExtKeyN3        = 27
  ExtKeyN4        = 28
  ExtKeyN5        = 29
  ExtKeyN6        = 30
  ExtKeyN7        = 31
  ExtKeyN8        = 32
  ExtKeyN9        = 33
  ExtKeyNDot      = 34
  ExtKeyNEnter    = 35
  ExtKeyNAdd      = 36
  ExtKeyNSubtract = 37
  ExtKeyNMultiply = 38
  ExtKeyNDivide   = 39

  # Align
  AlignFill   = 0
  AlignStart  = 1
  AlignCenter = 2
  AlignEnd    = 3

  # At
  AtLeading  = 0
  AtTop      = 1
  AtTrailing = 2
  AtBottom   = 3

  # ToolbarDisplayMode
  ToolbarDisplayModeIconOnly              = 0
  ToolbarDisplayModeIconAndTextHorizontal = 1
  ToolbarDisplayModeIconAndTextVertical   = 2
  ToolbarDisplayModeTextOnly              = 3

  # ImageViewContentMode
  ImageViewContentCenter = 0
  ImageViewContentFit    = 1

  # TableValueType
  TableValueTypeString = 0
  TableValueTypeImage  = 1
  TableValueTypeInt    = 2
  TableValueTypeColor  = 3

  # SortIndicator
  SortIndicatorNone       = 0
  SortIndicatorAscending  = 1
  SortIndicatorDescending = 2

  # editable
  TableModelColumnNeverEditable  = -1
  TableModelColumnAlwaysEditable = -2

  # TableSelectionMode
  TableSelectionModeNone       = 0
  TableSelectionModeZeroOrOne  = 1
  TableSelectionModeOne        = 2
  TableSelectionModeZeroOrMany = 3
end
