class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class DesktopDesign < ContainerDesign
      def render(widget, transform, graphics)
        desktop = widget.as(Desktop)
        pos2d = desktop.position.to_f32
        pos3d = Boleite::Vector3f32.new pos2d.x, pos2d.y, 0f32
        transform = Matrix.translate transform, pos3d
        render_children widget, transform, graphics
      end
    end
  end
end