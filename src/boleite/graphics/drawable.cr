module Boleite::Drawable
  def render(renderer : Renderer, transform : Matrix44f32) : Void
    internal_render(renderer, transform)
  end
end