module LibUI
  class Path
    def self.open(fill_mode = DrawFillModeWinding)
      path = new(fill_mode)
      begin
        yield path
      ensure
        path.close
      end
    end

    def initialize(fill_mode = DrawFillModeWinding)
      @pointer = LibUI.draw_new_path(fill_mode)
    end

    def to_ptr
      raise RuntimeError, 'draw path is closed' unless @pointer

      @pointer
    end

    def new_figure(x, y)
      LibUI.draw_path_new_figure(to_ptr, x, y)
      self
    end

    def new_figure_with_arc(x, y, radius, start_angle, sweep, negative = false)
      LibUI.draw_path_new_figure_with_arc(to_ptr, x, y, radius, start_angle, sweep, negative ? 1 : 0)
      self
    end

    def line_to(x, y)
      LibUI.draw_path_line_to(to_ptr, x, y)
      self
    end

    def arc_to(x, y, radius, start_angle, sweep, negative = false)
      LibUI.draw_path_arc_to(to_ptr, x, y, radius, start_angle, sweep, negative ? 1 : 0)
      self
    end

    def bezier_to(c1x, c1y, c2x, c2y, end_x, end_y)
      LibUI.draw_path_bezier_to(to_ptr, c1x, c1y, c2x, c2y, end_x, end_y)
      self
    end

    def close_figure
      LibUI.draw_path_close_figure(to_ptr)
      self
    end

    def add_rectangle(x, y, width, height)
      LibUI.draw_path_add_rectangle(to_ptr, x, y, width, height)
      self
    end

    def end_path
      LibUI.draw_path_end(to_ptr)
      self
    end

    def close
      return if @pointer.nil?

      LibUI.draw_free_path(@pointer)
      @pointer = nil
      nil
    end
  end
end
