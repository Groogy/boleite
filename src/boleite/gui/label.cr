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
    setter_state text, character_size, orientation

    def initialize()
    end

    def initialize(text, wanted_size)
      super()

      self.size = wanted_size
      self.text = text
    end
  end
end