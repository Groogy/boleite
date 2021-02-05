class Boleite::GUI
  include CrystalClear

  @graphics : Graphics
  @router = InputRouter.new
  @receiver = InputReceiver.new
  @roots = [] of Root

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

  def global_input_router
    @router
  end

  def global_input_receiver
    @receiver
  end

  requires !@roots.includes? root
  def add_root(root : Root)
    @router.register root.input
    @roots << root
    root.mark_dirty
  end

  def remove_root(root : Root)
    result = @roots.delete root
    if result
      @router.unregister result.input
      allocation = root.acc_allocation
      allocation = allocation.expand 2.0
      @graphics.clear allocation
      each_root do |r|
        r.mark_dirty if allocation.intersects? r.acc_allocation
      end
    end
  end

  requires @roots.includes? root
  def move_to_front(root : Root)
    if @roots.last != root
      @roots.delete root
      @router.unregister root.input
      @roots << root
      @router.register_at 1, root.input
      root.mark_dirty
    end
  end

  def render
    repaint_widgets = [] of Root
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

      to_front = false
      to_front = true if root.absolute_allocation.contains? pos
      if to_front
        move_to_front root
        break
      end
    end
  end
end