class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class WindowDesign < DesignDrawer
      def initialize(window)
        @shape = Shape.new
        @shape.add_vertex 0, 0
        @shape.add_vertex 0, 100
        @shape.add_vertex 100, 0
      end

      def render(graphics)
        graphics.draw @shape
      end
    end

    def initialize
      @window_cache = Hash(Window, WindowDesign).new do |hsh, window|
        WindowDesign.new window
      end
    end

    def get_drawer(window : Window)
      drawer = @window_cache[window]
      @window_cache[window] = drawer
    end
  end
end