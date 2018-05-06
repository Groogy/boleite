class Boleite::GUI
  @graphics : Graphics
  @input : InputRouter
  @roots = [] of Container

  delegate target_size, to: @graphics
  
  def initialize(gfx, @input)
    @graphics = Graphics.new gfx
  end

  def add_root(root : Container)
    @input.register root.input
    @roots << root
  end

  def remove_root(root : Container)
    root = @roots.delete root
    @input.unregister root.input if root
  end

  def render
    repaint_widgets = find_repaint_widgets
    repaint_widgets.each do |widget|
      allocation = widget.acc_allocation
      widget.reset_acc_allocation
      @graphics.clear allocation
    end
    repaint_widgets.each do |widget|
      @graphics.draw widget if widget.visible?
    end
    @graphics.render
  end

  def find_repaint_widgets
    widgets = @roots.select &.repaint?
    widgets.each do |widget|
      allocation = widget.acc_allocation
      widgets += @roots.select do |other|
        !widgets.includes?(other) && other.acc_allocation.intersects? allocation
      end
    end
    widgets
  end

  def each_root
    @roots.each { |root| yield root }
  end

  def pulse
    each_root &.pulse.emit
  end
end