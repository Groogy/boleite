class Boleite::GUI
  class Label < Widget

    enum Orientation
      Left
      Center
      Right
    end

    @text = ""
    @character_size = 20u32
    @orientation = Orientation::Left

    getter text, character_size, orientation

    def initialize()
    end

    def initialize(text, wanted_size)
      super

      self.size = wanted_size
      self.text = text
    end

    def text=(@text)
      state_change.emit
    end

    def character_size=(@character_size)
      state_change.emit
    end

    def orientation(@orientation)
      state_change.emit
    end
  end
end