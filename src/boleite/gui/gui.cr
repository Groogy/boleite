class Boleite::GUI
  include CrystalClear

  @graphics : Graphics
  @router = InputRouter.new
  @receiver = InputReceiver.new
  @roots = [] of Window

  delegate target_size, to: @graphics
  
  def initialize(gfx, default_font)
    @graphics = Graphics.new gfx, default_font

    @router.register @receiver
    @receiver.register_instance RootMouseOver.new(self), ->handle_root_mouse_over(Vector2f)
  end

  def enable(parent_input)
    parent_input.register @router
  end

  def disable(parent_input)
    parent_input.unregister @router
  end

  requires !@roots.includes? root
  def add_root(root : Container)
    @router.register root.input
    @roots << root
  end

  def remove_root(root : Window)
    result = @roots.delete root
    @router.unregister result.input if result
  end

  requires @roots.includes? root
  def move_to_front(root : Window)
    if @roots.last != root
      @roots.delete root
      @router.unregister root.input
      @roots << root
      @router.register_at 0, root.input
      root.mark_dirty
    end
  end

  def render
    repaint_widgets = [] of Window
    repaint_flags = find_repaint_widgets
    repaint_flags.each_with_index do |flag, index|
      if flag
        widget = @roots[index]
        allocation = widget.acc_allocation
        widget.reset_acc_allocation
        @graphics.clear allocation
        repaint_widgets << widget
      end
    end
    repaint_widgets.each do |widget|
      @graphics.draw widget if widget.visible?
      widget.clear_repaint
    end
    @graphics.render
  end

  def find_repaint_widgets
    repaint_matrix = @roots.map &.repaint?
    retry = true
    while retry
      retry = false
      repaint_matrix.each_with_index do |flag, index|
        if flag
          widget = @roots[index]
          allocation = widget.acc_allocation
          @roots.each_with_index do |other, other_index|
            if !repaint_matrix[other_index] && other.acc_allocation.intersects? allocation
              repaint_matrix[other_index] = true
              retry = true
            end
          end
        end
      end
    end
    repaint_matrix
  end

  def each_root
    @roots.each { |root| yield root }
  end

  def pulse
    each_root &.pulse.emit
  end

  private def handle_root_mouse_over(pos : Vector2f)
    @roots.reverse.each do |root|
      next unless root.visible?

      if root.absolute_allocation.contains?(pos)|| root.header_allocation.contains?(pos)
        move_to_front root
        break
      end
    end
  end
end