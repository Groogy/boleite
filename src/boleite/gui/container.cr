class Boleite::GUI
  abstract class Widget
  end

  abstract class Container < Widget
    @children = [] of Widget

    def add(child)
      @children << child
    end

    def remove(child)
      @children.delete child
    end

    def find(name)
      @children.find do |child|
        child.name == name
      end
    end

    def each_child
      @children.each do |child|
        yield child
      end
    end
  end
end