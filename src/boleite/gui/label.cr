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
    @use_cursor = false
    @cursor_position = 0

    getter text, character_size, orientation, cursor_position
    getter? use_cursor
    setter_state text, character_size, orientation, use_cursor, cursor_position

    def initialize()
      super
    end

    def initialize(text, wanted_size)
      super()

      self.size = wanted_size
      self.text = text
    end

    def on_state_change
      @cursor_position = @text.size if @cursor_position > @text.size
      @cursor_position = 0 if @cursor_position < 0
      super
    end 
  end
end