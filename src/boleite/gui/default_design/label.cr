class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class LabelDesign < DesignDrawer
      def initialize(@font : Font)
        @cache = DrawableCache(Text).new do |widget|
          Text.new @font
        end
      end

      def render(widget, transform, graphics)
        label = widget.as(Label)
        text = @cache.find label
        update_text text, label
        draw_text text, transform, graphics
      end

      def update_text(text, label)
        string = insert_cursor label
        string, screen_size = crop_text string, label
        pos = calc_text_pos label, screen_size
        text.text = string
        text.size = label.character_size
        text.position = pos
      end

      def draw_text(text, transform, graphics)
        graphics.draw text, transform
      end

      def insert_cursor(label)
        string = label.text.dup
        if label.use_cursor?
          string = string.insert label.cursor_position, '|'
        end
        string
      end

      def crop_text(string, label)
        size = 0.0
        character_size = label.character_size
        string.each_char_with_index do |char, index|
          glyph = @font.get_glyph char, character_size
          size += glyph.advance
          if size > label.size.x && index > 3
            if index > 3
              string = string[0, index-3] + "..."
            else
              string = "..."
            end
            break
          end
        end
        return string, size
      end

      def calc_text_pos(label, screen_size)
        pos = label.position
        case label.orientation
        when Label::Orientation::Center
          pos = label.size / 2.0
          pos.x -= screen_size / 2.0
          pos.y -= label.character_size / 2 + 1
        when Label::Orientation::Right
          pos.x = label.size.x - screen_size
        end
        pos
      end
    end
  end
end