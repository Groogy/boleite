module Boleite
  abstract class RenderTarget
    abstract def width : UInt32
    abstract def height : UInt32
    abstract def size : Vector2u
  end
end