abstract class Boleite::Shader
  def self.load_file(path, graphics)
    source = File.read(path)
    load_string(source, graphics)
  end

  def self.load_string(source, graphics)
    parser = ShaderParser.new
    parser.parse(source)

    graphics.create_shader(parser)
  end

  abstract def initialize(parser : ShaderParser)
  abstract def activate(&block)

  abstract def set_parameter(name, value : Float32) : Void
  abstract def set_parameter(name, value : Vector2f32) : Void
  abstract def set_parameter(name, value : Vector3f32) : Void
  abstract def set_parameter(name, value : Vector4f32) : Void
  abstract def set_parameter(name, value : Matrix33f32) : Void
  abstract def set_parameter(name, value : Matrix44f32) : Void
  abstract def set_parameter(name, value : Texture) : Void

  abstract def world_transform=(value : Matrix44f32) : Void
  abstract def view_transform=(value : Matrix44f32) : Void
  abstract def projection_transform=(value : Matrix44f32) : Void

  abstract def has_world_transform?() : Bool
  abstract def has_view_transform?() : Bool
  abstract def has_projection_transform?() : Bool
end
