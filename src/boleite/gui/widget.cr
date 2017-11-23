require "weak_ref"

class Boleite::GUI
  abstract class Widget
    include CrystalClear

    getter name, allocation, input
    getter? repaint
  
    @name = ""
    @input = InputHandler.new
    @parent = WeakRef(Widget | Nil).new nil
    @allocation = FloatRect.new
    @visible = true
    @enabled = true
    @repaint = true
    @mouse_focus = false

    Cute.signal mouse_enter
    Cute.signal mouse_leave
    Cute.signal mouse_over(pos : Vector2f)
    Cute.signal left_click(pos : Vector2f)
    Cute.signal right_click(pos : Vector2f)
    Cute.signal state_change
    Cute.signal pulse

    def initialize
      state_change.on &->on_state_change
      mouse_enter.on &->on_mouse_enter
      mouse_leave.on &->on_mouse_leave

      @input.register_instance WidgetMouseEnter.new(self), mouse_enter
      @input.register_instance WidgetMouseLeave.new(self), mouse_leave
      @input.register_instance WidgetMouseOver.new(self), mouse_over
      @input.register_instance WidgetMouseClick.new(self, Mouse::Left), left_click
      @input.register_instance WidgetMouseClick.new(self, Mouse::Right), right_click
    end

    def name=(name)
      @name = name
      state_change.emit
    end

    def visible?
      visible = @visible
      if parent = self.parent && visible
        visible &= parent.visible?
      end
      visible
    end

    def visible=(flag)
      @visible = flag
      state_change.emit
    end

    def enabled?
      enabled = @enabled
      if parent = self.parent && enabled
        enabled &= parent.enabled?
      end
      enabled
    end

    def enabled=(flag)
      @enabled = flag
      state_change.emit
    end

    def clear_repaint
      @repaint = false
    end

    def has_mouse_focus?
      @mouse_focus
    end

    def position
      Vector2f.new @allocation.left, @allocation.top
    end

    def position=(pos)
      @allocation.left = pos.x
      @allocation.top = pos.y
      state_change.emit
    end

    def move(pos)
      self.position = self.position + pos
    end

    def absolute_position
      pos = position
      if parent = self.parent
        pos = parent.absolute_position + pos
      end
      pos
    end

    def absolute_allocation
      pos = absolute_position
      allocation = @allocation.dup
      allocation.left = pos.x
      allocation.top = pos.y
      allocation
    end

    def size
      Vector2f.new @allocation.width, @allocation.height
    end

    def size=(size)
      @allocation.width = size.x
      @allocation.height = size.y
      state_change.emit
    end

    requires self.parent.nil? || parent == nil
    requires parent != self
    def parent=(parent)
      @parent = WeakRef(Widget).new parent
      state_change.emit
    end

    def parent=(val : Nil)
      @parent = nil
    end

    def parent
      if parent = @parent.try(&.value)
        parent
      else
        nil
      end
    end

    protected def on_state_change
      @repaint = true
      if parent = self.parent
        parent.state_change.emit
      end
    end

    protected def on_mouse_enter
      @mouse_focus = true
    end

    protected def on_mouse_leave
      @mouse_focus = false
    end
  end
end
