class Boleite::Model
  include Drawable

  class Node
    include Drawable

    @name = ""
    @transformation = Matrix44f32.identity
    @meshes = [] of Mesh
    @children = [] of Node

    def initialize(@name, @transformation, @meshes, @children)
    end
    
    def initialize()
    end

    def internal_render(renderer, transform)
      transform = Matrix.mul @transformation, transform
      @meshes.each do |mesh|
        drawcall = DrawCallContext.new mesh.vertex_buffer, transform
        renderer.draw drawcall
      end
      @children.each do |child|
        renderer.draw child, transform
      end
    end
  end

  @meshes = [] of Mesh
  @root : Node

  def initialize(@meshes, @root)
  end

  def internal_render(renderer, transform)
    renderer.draw @root, transform
  end
end