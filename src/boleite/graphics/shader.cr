module Boleite
  abstract class Shader
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
    abstract def set_parameter(name, value : Matrix33f32 ) : Void
    abstract def set_parameter(name, value : Matrix44f32 ) : Void
  end
end