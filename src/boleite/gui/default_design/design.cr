class Boleite::GUI
  abstract class Design
  end

  class DefaultDesign < Design
    PRIMARY_COLOR = Colorf.new 0.273f32, 0.273f32, 0.195f32, 1f32
    SECONDARY_COLOR = Colorf.new 0.195f32, 0.195f32, 0.117f32, 1f32
    BORDER_COLOR = Colorf.new 0.078f32, 0.078f32, 0.078f32, 1f32
    BORDER_SIZE = 1.0

    def initialize(gfx)
      @font = Boleite::Font.new gfx, "arial.ttf"
      @window = WindowDesign.new
      @label = LabelDesign.new @font
      @button = ButtonDesign.new
      @layout = LayoutDesign.new
    end

    def get_drawer(window : Window)
      @window
    end

    def get_drawer(label : Label)
      @label
    end

    def get_drawer(button : Button)
      @button
    end

    def get_drawer(layout : Layout)
      @layout
    end
  end
end