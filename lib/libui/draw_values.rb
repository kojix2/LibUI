module LibUI
  class Brush
    GradientStop = Struct.new(:position, :red, :green, :blue, :alpha,
                              keyword_init: true)

    def initialize(type: DrawBrushTypeSolid, color: [0.0, 0.0, 0.0, 1.0],
                   x0: 0.0, y0: 0.0, x1: 0.0, y1: 0.0, outer_radius: 0.0,
                   stops: [])
      @native = FFI::DrawBrush.malloc
      @native.to_ptr.free = Fiddle::RUBY_FREE
      @native.to_ptr[0, FFI::DrawBrush.size] = "\0" * FFI::DrawBrush.size
      @native.Type = type
      self.color = color
      @native.X0 = x0
      @native.Y0 = y0
      @native.X1 = x1
      @native.Y1 = y1
      @native.OuterRadius = outer_radius
      self.stops = stops
    end

    def to_ptr
      @native.to_ptr
    end

    def color=(rgba)
      unless rgba.is_a?(Array) && rgba.length == 4 && rgba.all? { |component| component.is_a?(Numeric) }
        raise TypeError, 'color must be an RGBA array'
      end
      @native.R, @native.G, @native.B, @native.A = rgba
    end

    def stops=(stops)
      raise TypeError, 'stops must be an Array' unless stops.is_a?(Array)

      size = FFI::DrawBrushGradientStop.size
      pointer = stops.empty? ? Fiddle::Pointer.new(0) : Fiddle::Pointer.malloc(size * stops.length, Fiddle::RUBY_FREE)
      stops.each_with_index do |entry, index|
        stop = entry.is_a?(GradientStop) ? entry.to_a : entry
        unless stop.is_a?(Array) && stop.length == 5 && stop.all? { |value| value.is_a?(Numeric) }
          raise TypeError, 'each stop must have position, red, green, blue, alpha'
        end
        native = FFI::DrawBrushGradientStop.new(pointer + index * size)
        native.Pos, native.R, native.G, native.B, native.A = stop
      end
      @stops_pointer = pointer
      @native.Stops = pointer
      @native.NumStops = stops.length
    end
  end

  class StrokeParams
    def initialize(cap: DrawLineCapFlat, join: DrawLineJoinMiter,
                   thickness: 1.0, miter_limit: DrawDefaultMiterLimit,
                   dashes: [], dash_phase: 0.0)
      @native = FFI::DrawStrokeParams.malloc
      @native.to_ptr.free = Fiddle::RUBY_FREE
      @native.to_ptr[0, FFI::DrawStrokeParams.size] = "\0" * FFI::DrawStrokeParams.size
      @native.Cap = cap
      @native.Join = join
      @native.Thickness = thickness
      @native.MiterLimit = miter_limit
      @native.DashPhase = dash_phase
      self.dashes = dashes
    end

    def to_ptr
      @native.to_ptr
    end

    def dashes=(values)
      unless values.is_a?(Array) && values.all? { |value| value.is_a?(Numeric) && value.positive? }
        raise TypeError, 'dashes must be an array of positive numbers'
      end
      bytes = values.pack('d*')
      pointer = if values.empty?
                  Fiddle::Pointer.new(0)
                else
                  allocated = Fiddle::Pointer.malloc(bytes.bytesize, Fiddle::RUBY_FREE)
                  allocated[0, bytes.bytesize] = bytes
                  allocated
                end
      @dashes_pointer = pointer
      @native.Dashes = pointer
      @native.NumDashes = values.length
    end
  end

  class Matrix
    def initialize
      @native = FFI::DrawMatrix.malloc
      @native.to_ptr.free = Fiddle::RUBY_FREE
      LibUI.draw_matrix_set_identity(@native)
    end

    def to_ptr
      @native.to_ptr
    end

    def translate(x, y)
      LibUI.draw_matrix_translate(@native, x, y)
      self
    end

    def scale(center_x, center_y, x, y)
      LibUI.draw_matrix_scale(@native, center_x, center_y, x, y)
      self
    end

    def rotate(x, y, angle)
      LibUI.draw_matrix_rotate(@native, x, y, angle)
      self
    end

    def skew(x, y, x_amount, y_amount)
      LibUI.draw_matrix_skew(@native, x, y, x_amount, y_amount)
      self
    end

    def multiply(other)
      raise TypeError, 'expected LibUI::Matrix' unless other.is_a?(Matrix)

      LibUI.draw_matrix_multiply(@native, other.to_ptr)
      self
    end

    def invertible?
      LibUI.draw_matrix_invertible(@native) != 0
    end

    def invert
      LibUI.draw_matrix_invert(@native) != 0
    end

    def transform_point(x, y)
      LibUI.draw_matrix_transform_point(@native, x, y)
    end

    def transform_size(x, y)
      LibUI.draw_matrix_transform_size(@native, x, y)
    end
  end
end
