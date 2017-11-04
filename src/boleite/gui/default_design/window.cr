class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class WindowDesign < DesignDrawer
      @cache = DrawableCache(Tuple(Shape, Shape)).new do |widget|
        Tuple(Shape, Shape).new Shape.new, Shape.new
      end

      def render(widget, graphics)
        window = widget.as(Window)
        body, border = @cache.find widget
        update_body body, window
        update_border border, window
        graphics.draw border
        graphics.draw body
      end

      def update_body(shape, window)
        shape.position = window.position
        shape.color = PRIMARY_COLOR
        size = window.size.to_f32
        update_vertices shape, size
      end

      def update_border(shape, window)
        border_size = window.border_size
        shape.position = window.position - border_size
        shape.color = BORDER_COLOR
        shape_size = (window.size + border_size * 2.0).to_f32
        update_vertices shape, shape_size
      end

      def should_update_vertices?(shape, size)
        shape.num_vertices < 6 || shape[3].x != size.x || shape[3].y != size.y
      end

      def update_vertices(shape, size)
        if should_update_vertices? shape, size
          shape.clear_vertices
          shape.add_vertex 0, 0
          shape.add_vertex 0, size.y
          shape.add_vertex size.x, 0
          shape.add_vertex size
          shape.add_vertex size.x, 0
          shape.add_vertex 0, size.y
        end
      end
    end
  end
end