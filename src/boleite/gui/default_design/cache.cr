class Boleite::GUI
  abstract class Design
  end

  class DefaultDesign < Design
    class DrawableCache(T)
      @drawables = [] of {UInt64, T}

      def find(widget)
        id = widget.object_id
        index = @drawables.bsearch_index { |x| x[0] >= id }
        if index
          tup = @drawables[index]
          return tup[1] if tup[0] == id
          tup = {id, T.new}
          @drawables.insert index, tup
          return tup[1]
        else
          tup = {id, T.new}
          @drawables.push tup
          return tup[1]
        end
      end
    end
  end
end