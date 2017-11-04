class Boleite::GUI
  abstract class Design
  end

  class DefaultDesign < Design
    @window = WindowDesign.new

    def get_drawer(window : Window)
      @window
    end
  end
end