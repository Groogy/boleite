class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class DesktopDesign < ContainerDesign
      def render(widget, transform, graphics)
        desktop = widget.as(Desktop)
        render_children widget, transform, graphics
      end
    end
  end
end