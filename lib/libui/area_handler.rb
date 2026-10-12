module LibUI
  class DrawContext
    def initialize(pointer)
      @pointer = Fiddle::Pointer.new(pointer.to_i)
      @active = true
    end

    def to_ptr
      raise RuntimeError, 'draw context is only valid during on_draw' unless @active

      @pointer
    end

    def fill(path, brush)
      LibUI.draw_fill(to_ptr, path, brush)
    end

    def stroke(path, brush, stroke_params)
      LibUI.draw_stroke(to_ptr, path, brush, stroke_params)
    end

    def draw_text(layout, x, y)
      LibUI.draw_text(to_ptr, layout, x, y)
    end

    def draw_image(image, x, y, width, height)
      LibUI.draw_image(to_ptr, image, x, y, width, height)
    end

    def transform(matrix)
      LibUI.draw_transform(to_ptr, matrix)
    end

    def clip(path)
      LibUI.draw_clip(to_ptr, path)
    end

    def save
      LibUI.draw_save(to_ptr)
    end

    def restore
      LibUI.draw_restore(to_ptr)
    end

    def invalidate
      @active = false
    end
  end

  class AreaHandler
    DrawEvent = Struct.new(:context, :area_width, :area_height, :clip_x, :clip_y,
                           :clip_width, :clip_height, keyword_init: true)
    MouseEvent = Struct.new(:x, :y, :area_width, :area_height, :down, :up,
                            :count, :modifiers, :held_1_to_64, keyword_init: true)
    KeyEvent = Struct.new(:key, :ext_key, :modifier, :modifiers, :up,
                          keyword_init: true)

    def initialize(draw: nil, mouse_event: nil, mouse_crossed: nil,
                   drag_broken: nil, key_event: nil)
      @handlers = { draw: draw, mouse_event: mouse_event,
                    mouse_crossed: mouse_crossed, drag_broken: drag_broken,
                    key_event: key_event }
      @native = FFI::AreaHandler.malloc
      @native.to_ptr.free = Fiddle::RUBY_FREE
      @closures = {}
      install_callbacks
    end

    def to_ptr
      @native.to_ptr
    end

    def on_draw(&block)
      @handlers[:draw] = block
      self
    end

    def on_mouse_event(&block)
      @handlers[:mouse_event] = block
      self
    end

    def on_mouse_crossed(&block)
      @handlers[:mouse_crossed] = block
      self
    end

    def on_drag_broken(&block)
      @handlers[:drag_broken] = block
      self
    end

    def on_key_event(&block)
      @handlers[:key_event] = block
      self
    end

    private

    def install_callbacks
      pointer = Fiddle::TYPE_VOIDP
      integer = Fiddle::TYPE_INT
      @closures[:draw] = callback(Fiddle::TYPE_VOID, [pointer, pointer, pointer]) do |_handler, _area, params_ptr|
        params = FFI::AreaDrawParams.new(params_ptr)
        context = DrawContext.new(params.Context)
        event = DrawEvent.new(context: context, area_width: params.AreaWidth,
                              area_height: params.AreaHeight, clip_x: params.ClipX,
                              clip_y: params.ClipY, clip_width: params.ClipWidth,
                              clip_height: params.ClipHeight)
        begin
          @handlers[:draw]&.call(event)
        ensure
          context.invalidate
        end
      end
      @closures[:mouse_event] = callback(Fiddle::TYPE_VOID, [pointer, pointer, pointer]) do |_handler, _area, event_ptr|
        native = FFI::AreaMouseEvent.new(event_ptr)
        @handlers[:mouse_event]&.call(MouseEvent.new(x: native.X, y: native.Y,
          area_width: native.AreaWidth, area_height: native.AreaHeight,
          down: native.Down, up: native.Up, count: native.Count,
          modifiers: native.Modifiers, held_1_to_64: native.Held1To64))
      end
      @closures[:mouse_crossed] = callback(Fiddle::TYPE_VOID, [pointer, pointer, integer]) do |_handler, _area, left|
        @handlers[:mouse_crossed]&.call(left != 0)
      end
      @closures[:drag_broken] = callback(Fiddle::TYPE_VOID, [pointer, pointer]) do |_handler, _area|
        @handlers[:drag_broken]&.call
      end
      @closures[:key_event] = callback(integer, [pointer, pointer, pointer]) do |_handler, _area, event_ptr|
        native = FFI::AreaKeyEvent.new(event_ptr)
        event = KeyEvent.new(key: native.Key, ext_key: native.ExtKey,
                             modifier: native.Modifier, modifiers: native.Modifiers,
                             up: native.Up != 0)
        @handlers[:key_event]&.call(event) ? 1 : 0
      end
      @native.Draw = @closures[:draw]
      @native.MouseEvent = @closures[:mouse_event]
      @native.MouseCrossed = @closures[:mouse_crossed]
      @native.DragBroken = @closures[:drag_broken]
      @native.KeyEvent = @closures[:key_event]
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
end
