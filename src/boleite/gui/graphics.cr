require "./default_design/*"

class Boleite::GUI
  class Graphics
    @gfx : GraphicsContext
    @renderer : Renderer
    @camera : Camera
    @design : Design

    property design
    
    def initialize(@gfx)
      target = @gfx.main_target
      @camera = Camera2D.new target.width.to_f32, target.height.to_f32, 0f32, 1f32
      @renderer = Renderer.new @gfx, @camera
      @design = DefaultDesign.new @gfx
    end

    def clear(rect : FloatRect)
      @renderer.clear rect.to_i, Color.transparent
    end

    def draw(drawable : Drawable, transform = Matrix44f32.identity)
      @renderer.draw drawable, transform 
    end

    def draw(widget, transform = Matrix44f32.identity)
      drawer = @design.get_drawer widget
      drawer.render(widget, transform, self)
      widget.clear_repaint
    end

    def render
      @renderer.present
    end
  end
end