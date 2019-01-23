class Boleite::GUI
  class Window < Root

    DEFAULT_SIZE = Vector2f.new 100.0, 30.0
    DEFAULT_HEADER_SIZE = 24.0

    @header_size = DEFAULT_HEADER_SIZE
    @header_label = Label.new
    @close_button : Button?

    getter header_size, header_label, close_button
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
      @input.register_instance WindowClaimLeftovers.new(self), ->{}
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
      @acc_allocation = @allocation.merge header_allocation
    end

    def update_acc_allocation
      @acc_allocation = @acc_allocation.merge @allocation
      @acc_allocation = @acc_allocation.merge header_allocation
      @acc_allocation = @acc_allocation.expand 2.0
    end

    def set_next_to(other : Window)
      other_pos = other.absolute_position
      other_size = other.size

      if p = parent
        other_pos -= p.absolute_position
      end

      self.position = other_pos + other_size * 0.5
    end

    def add_close_button(&block)
      button = Button.new "X", Vector2f.new(20.0, @header_size)
      button.click.on { |pos| block.call }
      button.parent = self
      @close_button = button
      state_change.emit
    end

    def remove_close_button
      @close_button = nil
      state_change.emit
    end

    protected def update_header_size
      @header_label.size = Vector2f.new size.x, @header_size
      if button = @close_button
        button.position = Vector2f.new size.x - 20.0, -@header_size
        button.size = Vector2f.new 20.0, @header_size
      end
    end

    protected def pass_input_to_children(event : InputEvent)
      if button = @close_button
        button.input.process event
      end
      super event unless event.claimed?
    end
  end
end
