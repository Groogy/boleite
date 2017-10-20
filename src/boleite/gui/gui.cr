class Boleite::GUI
  @graphics : Graphics
  @roots = [] of Container
  
  def initialize(gfx)
    @graphics = Graphics.new gfx
  end

  def add_root(root : Container)
    @roots << root
  end

  def render
    @graphics.clear
    @roots.each do |root|
      @graphics.draw root
    end
    @graphics.render
  end
end