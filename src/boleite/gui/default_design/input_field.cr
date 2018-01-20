class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class InputFieldDesign < DesignDrawer
      struct InputFieldDrawables
        property body, border

        @body = Shape.new
        @border = Shape.new
      end

      @cache = DrawableCache(InputFieldDrawables).new do |widget|
        InputFieldDrawables.new
      end

      def render(widget, transform, graphics)
        field = widget.as(InputField)
        drawables = @cache.find widget
        update_drawables drawables, field
        draw_drawables drawables, transform, graphics

        transform = Matrix.mul transform, drawables.body.transformation
        graphics.draw field.label, transform
      end

      def update_drawables(drawables, field)
        pos = field.position
        size = field.size
        update_border drawables.border, pos, size, BORDER_SIZE
        update_body drawables.body, pos, size, SECONDARY_COLOR
      end

      def draw_drawables(drawables, transform, graphics)
        graphics.draw drawables.border, transform
        graphics.draw drawables.body, transform
      end

      def update_body(shape, pos, size, color)
        shape.position = pos
        shape.color = color
        update_vertices shape, size.to_f32
      end

      def update_border(shape, pos, size, border)
        shape.position = pos - border
        shape.color = BORDER_COLOR
        shape_size = (size + border * 2.0).to_f32
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