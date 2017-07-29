module Boelite
  abstract class GraphicsContext
    abstract def main_target : RenderTarget
    abstract def clear(color : Colorf) : Void
    abstract def present : Void
  end
end