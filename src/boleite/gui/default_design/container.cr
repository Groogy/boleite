class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    abstract class ContainerDesign < DesignDrawer
      def render_children(widget, transform, graphics)
        container = widget.as(Container)
        container.each_widget do |child|
          graphics.draw child, transform
        end
      end
    end
  end
end