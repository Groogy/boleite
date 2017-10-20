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
      @design = DefaultDesign.new
    end

    def clear
      @renderer.clear Color.transparent
    end

    def draw(drawable : Drawable)
      @renderer.draw drawable
    end

    def draw(widget)
      drawer = @design.get_drawer widget
      drawer.render(self)
    end

    def render
      @renderer.present
    end
  end
end