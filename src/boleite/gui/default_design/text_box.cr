class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class TextBoxDesign < DesignDrawer
      def initialize(@font : Font)
        @cache = DrawableCache(Text).new do |widget|
          Text.new @font
        end
      end

      def render(widget, transform, graphics)
        box = widget.as(TextBox)
        text = @cache.find box
        update_text text, box
        draw_text text, transform, graphics
      end

      def update_text(text, box)
        string = insert_cursor box
        string, screen_size = crop_text string, box
        text.text = string
        text.size = box.character_size
        text.position = box.position
      end

      def draw_text(text, transform, graphics)
        graphics.draw text, transform
      end

      def insert_cursor(box)
        string = box.text.dup
        if box.use_cursor?
          string = string.insert box.cursor_position, '|'
        end
        string
      end

      def crop_text(string, box)
        size = 0.0
        rows = 1
        wrapped = ""
        character_size = box.character_size
        linespacing = @font.get_linespacing character_size
        string.each_char_with_index do |char, index|
          glyph = @font.get_glyph char, character_size
          size += glyph.advance
          wrapped += char
          if size >= box.size.x
            char = '\n'
            wrapped += char
          end
          if char == '\n'
            size = 0.0
            rows += 1
          end
          if !box.use_cursor? && rows * linespacing > box.size.y
            wrapped += "..."
            break
          end
        end
        return wrapped, size
      end
    end
  end
end