require "weak_ref"

class Boleite::GUI
  abstract class Widget
    include CrystalClear

    getter name, allocation
  
    @name = ""
    @parent : WeakRef(Widget)?
    @allocation = FloatRect.new
    @visible = true
    @enabled = true
    @repaint = true

    def visible?
      visible = @visible
      if parent = @parent && visible
        visible &= parent.visible?
      end
      visible
    end

    def visible=(flag)
      @visible = flag
      @repaint = true
    end

    def enabled?
      enabled = @enabled
      if parent = @parent && enabled
        enabled &= parent.enabled?
      end
      enabled
    end

    def enabled=(flag)
      @enabled = flag
      @repaint = true
    end

    def repaint?
      @repaint
    end

    def clear_repaint
      @repaint = false
    end

    def position
      Vector2f.new @allocation.left, @allocation.top
    end

    def position=(pos)
      @allocation.left = pos.x
      @allocation.top = pos.y
      @repaint = true
    end

    def absolute_position
      pos = position
      if parent = @parent
        pos = parent.absolute_position + pos
      end
      pos
    end

    def size
      Vector2f.new @allocation.width, @allocation.height
    end

    def size=(size)
      @allocation.width = size.x
      @allocation.height = size.y
      @repaint = true
    end

    requires self.parent.nil? || parent == nil
    requires parent != self
    def parent=(parent)
      @parent = WeakRef(Widget).new parent
    end

    def parent
      if parent = @parent
        parent.value 
      else
        @parent
      end
    end
  end
end