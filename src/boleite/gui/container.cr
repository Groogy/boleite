class Boleite::GUI
  abstract class Widget
  end

  abstract class Container < Widget
    include CrystalClear

    @children = [] of Widget
    @min_size = Vector2f.new 0.0, 0.0

    delegate :"[]", to: @children
    getter min_size

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
  end
end