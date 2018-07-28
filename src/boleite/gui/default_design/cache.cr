class Boleite::GUI
  abstract class Design
  end

  class DefaultDesign < Design
    class DrawableCache(T)
      PURGE_TARGET = 1000

      class DrawableData(T)
        @id : UInt64
        @ref : WeakRef(Widget)
        @drawable : T

        getter id, ref, drawable

        def initialize(@id, @ref, @drawable)
        end
      end

      @drawables = [] of DrawableData(T)
      @counter = 0
      
      def initialize()
        @allocator = ->(widget : Widget) { T.new }
      end

      def initialize(@allocator : Proc(Widget, T))
      end

      def initialize(&block : Widget -> T)
        @allocator = block
      end

      def find(widget)
        @counter += 1
        purge if @counter >= PURGE_TARGET
        find_ref widget
      end

      def find_ref(widget)
        id = widget.object_id
        index = @drawables.bsearch_index { |x| x.id >= id }
        if index
          data = @drawables[index]
          return data.drawable if data.id == id
          data = DrawableData(T).new id, WeakRef.new(widget.as(Widget)), @allocator.call(widget)
          @drawables.insert index, data
          return data.drawable
        else
          data = DrawableData(T).new id, WeakRef.new(widget.as(Widget)), @allocator.call(widget)
          @drawables.push data
          return data.drawable
        end
      end

      def purge
        @drawables.clear
        @counter = 0
      end
    end
  end
end