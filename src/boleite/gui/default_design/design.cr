class Boleite::GUI
  abstract class Design
  end

  class DefaultDesign < Design
    PRIMARY_COLOR = Colorf.new 0.273f32, 0.273f32, 0.195f32, 1f32
    SECONDARY_COLOR = Colorf.new 0.195f32, 0.195f32, 0.117f32, 1f32
    BORDER_COLOR = Colorf.new 0.078f32, 0.078f32, 0.078f32, 1f32

    @window = WindowDesign.new

    def get_drawer(window : Window)
      @window
    end
  end
end