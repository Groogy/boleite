class Boleite::GUI
  abstract class DesignDrawer
  end

  abstract class Design
  end

  class DefaultDesign < Design
    class ImageDesign < DesignDrawer
      @undefined : Texture

      def initialize(gfx)
        image = Boleite::Image.new 32u32, 32u32, 32u32
        image.update 0, 0, 32, 32, (Color.pink * 255.0).to_u8
        @undefined = gfx.create_texture
        @undefined.create image.width, image.height, Texture::Format::RGBA, Texture::Type::Integer8
        @undefined.update image
        @cache = DrawableCache(Sprite).new do |widget|
          Sprite.new @undefined
        end
      end

      def render(widget, transform, graphics)
        image = widget.as(Image)
        sprite = @cache.find image
        update_sprite sprite, image
        draw_sprite sprite, transform, graphics
      end

      def update_sprite(sprite, image)
        sprite.position = image.position
        if texture = image.texture
          sprite.texture = texture
        else
          sprite.texture = @undefined
        end
        sprite.size = image.size.to_u32
      end

      def draw_sprite(sprite, transform, graphics)
        graphics.draw sprite, transform
      end
    end
  end
end