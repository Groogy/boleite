class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class LayoutDesign < ContainerDesign
      def render(widget, transform, graphics)
        pos = Vector3f.new widget.position.x, widget.position.y, 0.0
        transform = Matrix.translate transform, pos.to_f32
        render_children widget, transform, graphics
      end
    end
  end
end