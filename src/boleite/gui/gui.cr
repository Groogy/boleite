class Boleite::GUI
  @graphics : Graphics
  @input : InputRouter
  @roots = [] of Container
  
  def initialize(gfx, @input)
    @graphics = Graphics.new gfx
  end

  def add_root(root : Container)
    @input.register root.input
    @roots << root
  end

  def remove_root(root : Container)
    root = @roots.delete root
    @input.unregister root if root
  end

  def render
    @graphics.clear
    @roots.each do |root|
      @graphics.draw root
    end
    @graphics.render
  end
end