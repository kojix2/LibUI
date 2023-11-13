require_relative 'libui/version'
require_relative 'libui/utils'
require 'rbconfig'

module LibUI
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  host_cpu = RbConfig::CONFIG['host_cpu'].gsub(/i[36]86/, 'x86')
  lib_name = [
    # For libui-ng shared libraries compiled with (rake vendor:build)
    "libui.#{RbConfig::CONFIG['host_cpu']}.#{RbConfig::CONFIG['SOEXT']}",
    # For libui-ng shared library downloaded from RubyGems.org
    "libui.#{host_cpu}.#{RbConfig::CONFIG['SOEXT']}",
    # For backward compatibility or manual compilation of libui-ng
    "libui.#{RbConfig::CONFIG['SOEXT']}"
  ]

  self.ffi_lib = \
    if ENV['LIBUIDIR'] && !ENV['LIBUIDIR'].empty?
      lib_name.lazy
              .map { |name| File.expand_path(name, ENV['LIBUIDIR']) }
              .find { |path| File.exist?(path) }
    else
      lib_name.lazy
              .map { |name| File.expand_path("../vendor/#{name}", __dir__) }
              .find { |path| File.exist?(path) }
    end

  require_relative 'libui/ffi'
  require_relative 'libui/libui_base'

  extend LibUIBase

  class << self
    def init(opt = nil)
      unless opt
        opt = FFI::InitOptions.malloc
        opt.to_ptr.free = Fiddle::RUBY_FREE
      end
      i = super(opt)
      return if i.size.zero?

      warn 'error'
      warn UI.free_init_error(init)
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

    def open_type_features_get(otf, a, b, c, d, value)
      a, b, c, d = [a, b, c, d].map { |s| s.is_a?(String) ? s.ord : s }
      super(otf, a, b, c, d, value)
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
