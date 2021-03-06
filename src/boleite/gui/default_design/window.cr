class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class WindowDesign < ContainerDesign
      struct WindowDrawables
        property body, body_border, header, header_border

        @body = Shape.new
        @body_border = Shape.new
        @header = Shape.new
        @header_border = Shape.new
      end

      @cache = DrawableCache(WindowDrawables).new do |widget|
        WindowDrawables.new
      end

      def render(widget, transform, graphics)
        window = widget.as(Window)
        drawables = @cache.find widget
        update_drawables drawables, window
        draw_drawables drawables, transform, graphics

        header_transform = Matrix.mul transform, drawables.header.transformation
        graphics.draw window.header_label, header_transform

        transform = Matrix.mul transform, drawables.body.transformation
        if button = window.close_button
          graphics.draw button, transform
        end
        render_children widget, transform, graphics
      end

      def update_drawables(drawables, window)
        update_drawables_header drawables, window
        update_drawables_body drawables, window
      end

      def draw_drawables(drawables, transform, graphics)
        graphics.draw drawables.body_border, transform
        graphics.draw drawables.body, transform
        graphics.draw drawables.header_border, transform
        graphics.draw drawables.header, transform
      end

      def update_drawables_header(drawables, window)
        offset = Vector2f.zero
        header_size = Vector2f.new window.size.x, window.header_size
        pos = window.position
        update_border drawables.header_border, pos, header_size, BORDER_SIZE, offset
        update_body drawables.header, pos, header_size, PRIMARY_COLOR, offset
      end

      def update_drawables_body(drawables, window)
        offset = Vector2f.zero
        pos = window.position
        size = window.size
        update_border drawables.body_border, pos, size, BORDER_SIZE, offset
        update_body drawables.body, pos, size, SECONDARY_COLOR, offset
      end

      def update_body(shape, pos, size, color, offset)
        shape.position = pos + offset
        shape.color = color
        update_vertices shape, size.to_f32
      end

      def update_border(shape, pos, size, border, offset)
        shape.position = pos - border + offset
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