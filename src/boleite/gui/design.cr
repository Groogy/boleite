class Boleite::GUI
  abstract class DesignDrawer
    abstract def render(graphics)
  end

  abstract class Design
    def get_drawer(widget)
      raise Exception.new "Unkown widget type given '#{widget}' for design."
    end
  end
end