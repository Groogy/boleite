class Boleite::GUI
  abstract class Design
  end

  class DefaultDesign < Design
    PRIMARY_COLOR = Colorf.new 0.273f32, 0.273f32, 0.195f32, 1f32
    SECONDARY_COLOR = Colorf.new 0.195f32, 0.195f32, 0.117f32, 1f32
    BORDER_COLOR = Colorf.new 0.078f32, 0.078f32, 0.078f32, 1f32
    BORDER_SIZE = 1.0

    @font : Font

    def initialize(gfx, @font)
      @window = WindowDesign.new
      @label = LabelDesign.new @font
      @text_box = TextBoxDesign.new @font
      @button = ButtonDesign.new
      @layout = LayoutDesign.new
      @input_field = InputFieldDesign.new
    end

    def get_drawer(window : Window)
      @window
    end

    def get_drawer(label : Label)
      @label
    end

    def get_drawer(box : TextBox)
      @text_box
    end

    def get_drawer(button : Button)
      @button
    end

    def get_drawer(layout : Layout)
      @layout
    end

    def get_drawer(field : InputField)
      @input_field
    end
  end
end