class Boleite::GUI
  class GridLayout < Container
    include CrystalClear

    @padding = Vector2f.new(1.0, 1.0)
    @handling_state_change = false

    getter padding
    setter_state padding

    def initialize(@cells : Vector2i)
      super()
    end

    def max_children : Int32
      @cells.x * @cells.y
    end

    protected def on_state_change
      return if @handling_state_change
      @handling_state_change = true
      arrange_child_widgets
      @handling_state_change = false
      super
    end

    protected def arrange_child_widgets
      pos = @padding
      count = 0
      largest_y = 0.0
      each_widget do |child|
        child.position = pos
        pos.x += child.size.x + @padding.x
        largest_y = child.size.y if child.size.y > largest_y
        count += 1
        if count % @cells.x == 0
          pos.y += largest_y + @padding.y
          pos.x = @padding.x
          largest_y = 0.0
        end
      end
    end

    invariant @children.size <= max_children
  end
end