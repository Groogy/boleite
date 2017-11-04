class Boleite::GUI
  abstract class Design
  end

  class DefaultDesign < Design
    class DrawableCache(T)
      @drawables = [] of {UInt64, T}
      
      def initialize()
        @allocator = ->(widget : Widget) { T.new }
      end

      def initialize(@allocator : Proc(Widget, T))
      end

      def initialize(&block : Widget -> T)
        @allocator = block
      end

      def find(widget)
        id = widget.object_id
        index = @drawables.bsearch_index { |x| x[0] >= id }
        if index
          tup = @drawables[index]
          return tup[1] if tup[0] == id
          tup = {id, @allocator.call(widget)}
          @drawables.insert index, tup
          return tup[1]
        else
          tup = {id, @allocator.call(widget)}
          @drawables.push tup
          return tup[1]
        end
      end
    end
  end
end