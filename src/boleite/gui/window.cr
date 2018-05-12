class Boleite::GUI
  class Window < Container
    DEFAULT_SIZE = Vector2f.new 100.0, 30.0
    DEFAULT_HEADER_SIZE = 24.0

    @header_size = DEFAULT_HEADER_SIZE
    @header_label = Label.new

    getter header_size, header_label
    setter_state header_size

    Cute.signal header_drag(pos : Vector2f)

    def initialize
      super
      self.min_size = DEFAULT_SIZE

      @header_label.position = Vector2f.zero
      @header_label.parent = self

      state_change.on &->update_header_size
      header_drag.on &->move(Vector2f)
      @input.register_instance WindowHeaderDrag.new(self), header_drag
    end

    def header_allocation
      pos = absolute_position
      FloatRect.new pos.x, pos.y - @header_size, size.x, @header_size
    end

    def header_text=(text)
      @header_label.text = text
    end

    def header_character_size=(size)
      @header_label.character_size = size
    end

    def reset_acc_allocation
      @acc_allocation = @allocation
      @acc_allocation.merge header_allocation
    end

    def update_acc_allocation
      @acc_allocation.merge @allocation
      @acc_allocation.merge header_allocation
      @acc_allocation.expand 2.0
    end

    def set_next_to(other : Window)
      other_pos = other.absolute_position
      other_size = other.size

      if p = parent
        other_pos -= p.absolute_position
      end

      self.position = other_pos + other_size * 0.5
    end

    protected def update_header_size
      @header_label.size = Vector2f.new size.x, @header_size
    end
  end
end