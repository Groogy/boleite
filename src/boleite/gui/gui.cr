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
    repaint_widgets = find_repaint_widgets
    repaint_widgets.each do |widget|
      @graphics.clear widget.acc_allocation
      widget.reset_acc_allocation
    end
    repaint_widgets.each do |widget|
      @graphics.draw widget
    end
    @graphics.render
  end

  def find_repaint_widgets
    widgets = @roots.select &.repaint?
    widgets
  end
end