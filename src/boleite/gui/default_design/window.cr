class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class WindowDesign < DesignDrawer
      @cache = DrawableCache(Shape).new

      def render(widget, graphics)
        window = widget.as(Window)
        shape = @cache.find widget
        update_shape shape, window
        graphics.draw shape
      end

      def update_shape(shape, window)
        shape.position = window.position
        window_size = window.size.to_f32
        if should_update? shape, window_size
          shape.clear_vertices
          shape.add_vertex 0, 0
          shape.add_vertex 0, window_size.y
          shape.add_vertex window_size.x, 0
          shape.add_vertex window_size
          shape.add_vertex window_size.x, 0
          shape.add_vertex 0, window_size.y
        end
      end

      def should_update?(shape, window_size)
        shape.num_vertices < 6 || shape[3].x != window_size.x || shape[3].y != window_size.y
      end
    end
  end
end