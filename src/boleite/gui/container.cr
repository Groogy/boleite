class Boleite::GUI
  abstract class Widget
  end

  abstract class Container < Widget
    include CrystalClear

    @children = [] of Widget
    @min_size = Vector2f.new 0.0, 0.0
    @acc_allocation = FloatRect.new

    delegate :"[]", to: @children
    getter min_size, acc_allocation

    def initialize
      super

      pulse.on { @children.each &.pulse.emit }

      @input.register_instance ContainerInputPass.new(self), ->pass_input_to_children(InputEvent)
    end

    requires child.parent.nil?
    ensures @children.count child == 1
    def add(child)
      @children << child
      child.parent = self
    end

    requires child.parent == self
    ensures @children.includes?(child) == false
    ensures child.parent != self
    def remove(child)
      child = @children.delete child
      child.parent = nil if child
      child
    end

    def find(name)
      @children.find do |child|
        child.name == name
      end
    end

    def num_widgets
      @children.size
    end

    def clear
      @children.each do |child|
        child.parent = nil
      end
      @children.clear
    end

    def each_widget
      @children.each do |child|
        yield child
      end
    end

    def min_size=(@min_size)
      self.size = @min_size if @min_size.x >= size.x || @min_size.y >= size.y
    end

    abstract def reset_acc_allocation
    abstract def update_acc_allocation

    protected def update_body_allocation
      alloc = self.allocation
      self.each_widget { |child| alloc = alloc.merge_relative child.allocation }
      @allocation = alloc
    end

    protected def on_state_change
      update_acc_allocation
      update_body_allocation
      super
    end

    protected def pass_input_to_children(event : InputEvent)
      each_widget do |child|
        child.input.process event unless event.claimed?
      end
    end
  end
end