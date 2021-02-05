class Boleite::Private::OpenGLShader < Boleite::Shader
  include CrystalClear
  
  @program_id = LibGL::UInt.zero
  @objects = [] of OpenGLShaderObject
  @depth_settings : ShaderDepthSettings
  @blend_settings : ShaderBlendSettings
  @value_settings : ShaderValueSettings
  @uniforms = {} of String => LibGL::Int
  @textures = {} of LibGL::Int => OpenGLTexture

  def initialize(parser : ShaderParser)
    @depth_settings = parser.depth_settings
    @blend_settings = parser.blend_settings
    @value_settings = parser.value_settings

    compile_objects parser
    link_shader
  end

  def finalize
    if @program_id > 0
      GL.safe_call { LibGL.deleteProgram @program_id }
      @program_id = LibGL::UInt.zero
    end
  end

  def activate(&block)
    activate(true, &block)
  end

  def activate(use_settings, &block)
    GL.safe_call { LibGL.useProgram @program_id }
    if use_settings
      apply_settings
      apply_textures
    end
    result = yield
    GL.safe_call{ LibGL.useProgram 0 }
    result
  end

  def set_parameter(name, value : Float32) : Void
    activate false do 
      loc = uniform_location_for name
      GL.safe_call { LibGL.uniform1f loc, value }
    end
  end

  def set_parameter(name, value : Vector2f32) : Void
    activate false do 
      loc = uniform_location_for name
      GL.safe_call { LibGL.uniform2f loc, value.x, value.y }
    end
  end

  def set_parameter(name, value : Vector3f32) : Void
    activate false do 
      loc = uniform_location_for name
      GL.safe_call { LibGL.uniform3f loc, value.x, value.y, value.z }
    end
  end

  def set_parameter(name, value : Vector4f32) : Void
    activate false do 
      loc = uniform_location_for name
      GL.safe_call { LibGL.uniform4f loc, value.x, value.y, value.z, value.w }
    end
  end

  def set_parameter(name, value : Matrix33f32 ) : Void
    activate false do
      loc = uniform_location_for name
      GL.safe_call { LibGL.uniformMatrix3fv loc, 1, LibGL::FALSE, value.elements }
    end
  end

  def set_parameter(name, value : Matrix44f32 ) : Void
    activate false do
      loc = uniform_location_for name
      GL.safe_call { LibGL.uniformMatrix4fv loc, 1, LibGL::FALSE, value.elements }
    end
  end

  def set_parameter(name, value : Texture) : Void
    activate false do
      loc = uniform_location_for name
      @textures[loc] = value.as(OpenGLTexture)
    end
  end

  def has_world_transform? : Bool
    @value_settings.world_transform.empty? == false
  end

  def has_view_transform? : Bool
    @value_settings.view_transform.empty? == false
  end

  def has_projection_transform? : Bool
    @value_settings.projection_transform.empty? == false
  end

  requires has_world_transform?
  def set_world_transform(value) : Void
    set_parameter @value_settings.world_transform, value
  end

  requires has_view_transform?
  def set_view_transform(value) : Void
    set_parameter @value_settings.view_transform, value
  end

  requires has_projection_transform?
  def set_projection_transform(value) : Void
    set_parameter @value_settings.projection_transform, value
  end

  def world_transform=(value) : Void
    set_world_transform(value)
  end

  def view_transform=(value) : Void
    set_view_transform(value)
  end

  def projection_transform=(value) : Void
    set_projection_transform(value)
  end

  private def uniform_location_for(name) : LibGL::Int
    loc = @uniforms[name]?
    if loc.nil?
      loc = GL.safe_call { LibGL.getUniformLocation @program_id, name.to_unsafe.as(Int8*) }
      @uniforms[name] = loc
    end
    loc
  end

  private def apply_settings
    GL.safe_call do
      if @depth_settings.enabled
        LibGL.enable LibGL::DEPTH_TEST
        LibGL.depthFunc self.class.translate_depth_func(@depth_settings.func)
      else
        LibGL.disable LibGL::DEPTH_TEST
      end
      if @blend_settings.enabled
        LibGL.enable LibGL::BLEND
        LibGL.blendFunc self.class.translate_blend_factor(@blend_settings.source_factor), 
                        self.class.translate_blend_factor(@blend_settings.destination_factor)
        LibGL.blendEquation self.class.translate_blend_func(@blend_settings.func)
      else
        LibGL.disable LibGL::BLEND
      end
    end
  end

  private def apply_textures
    slot = 1
    @textures.each do |loc, texture|
      GL.safe_call { LibGL.uniform1i loc, slot }
      GL.safe_call { LibGL.activeTexture LibGL::TEXTURE0 + slot }
      texture.bind
      slot += 1
    end
    GL.safe_call { LibGL.activeTexture LibGL::TEXTURE0 }
  end

  private def compile_objects(parser)
    ShaderType.each do |type|
      if type <= ShaderType::None || type >= ShaderType::Count
        next
      end

      if parser.has_shader type
        obj = OpenGLShaderObject.new parser.shader_source(type), type
        @objects << obj
      end
    end
  end

  private def link_shader
    finalize
    GL.safe_call do 
      @program_id = LibGL.createProgram
      @objects.each { |obj| LibGL.attachShader @program_id, obj.gl_identifier }
      LibGL.linkProgram @program_id

      LibGL.getProgramiv @program_id, LibGL::LINK_STATUS, out status
      if status == LibGL::FALSE
        LibGL.getProgramiv @program_id, LibGL::INFO_LOG_LENGTH, out length
        info_log = Slice(LibGL::Char).new(length + 1)
        LibGL.getProgramInfoLog @program_id, length, nil, info_log
        message = String.new(info_log.to_unsafe.as(UInt8*).to_slice(length + 1))
        raise ShaderException.new "Shader linker failure: " + message
      end
    end
  end

  def self.translate_depth_func(func : ShaderDepthSettings::Function)
    case func
    when ShaderDepthSettings::Function::Always; LibGL::ALWAYS
    when ShaderDepthSettings::Function::Never; LibGL::NEVER
    when ShaderDepthSettings::Function::Less; LibGL::LESS
    when ShaderDepthSettings::Function::Greater; LibGL::GREATER
    when ShaderDepthSettings::Function::LessEqual; LibGL::LEQUAL
    when ShaderDepthSettings::Function::GreaterEqual; LibGL::GEQUAL
    when ShaderDepthSettings::Function::Equal; LibGL::EQUAL
    when ShaderDepthSettings::Function::NotEqual; LibGL::NOTEQUAL
    else
      raise ArgumentError.new "Invalid depth function given!"
    end
  end

  def self.translate_blend_factor(factor : ShaderBlendSettings::Factor)
    case factor
    when ShaderBlendSettings::Factor::One; LibGL::ONE
    when ShaderBlendSettings::Factor::Zero; LibGL::ZERO
    when ShaderBlendSettings::Factor::Source; LibGL::SRC_COLOR
    when ShaderBlendSettings::Factor::OneMinusSource; LibGL::ONE_MINUS_SRC_COLOR
    when ShaderBlendSettings::Factor::Destination; LibGL::DST_COLOR
    when ShaderBlendSettings::Factor::OneMinusDestination; LibGL::ONE_MINUS_DST_COLOR
    when ShaderBlendSettings::Factor::SourceAlpha; LibGL::SRC_ALPHA
    when ShaderBlendSettings::Factor::OneMinusSourceAlpha; LibGL::ONE_MINUS_SRC_ALPHA
    when ShaderBlendSettings::Factor::DestinationAlpha; LibGL::DST_ALPHA
    when ShaderBlendSettings::Factor::OneMinusDestinationAlpha; LibGL::ONE_MINUS_DST_ALPHA
    when ShaderBlendSettings::Factor::Constant; LibGL::CONSTANT_COLOR
    when ShaderBlendSettings::Factor::OneMinusConstant; LibGL::ONE_MINUS_CONSTANT_COLOR
    when ShaderBlendSettings::Factor::ConstantAlpha; LibGL::CONSTANT_ALPHA
    when ShaderBlendSettings::Factor::OneMinusConstantAlpha; LibGL::ONE_MINUS_CONSTANT_ALPHA
    else
      raise ArgumentError.new "Invalid blend factor given!"
    end
  end

  def self.translate_blend_func(func : ShaderBlendSettings::Function)
    case func
    when ShaderBlendSettings::Function::Add; LibGL::FUNC_ADD
    when ShaderBlendSettings::Function::Subtract; LibGL::FUNC_SUBTRACT
    when ShaderBlendSettings::Function::ReverseSubtract; LibGL::FUNC_REVERSE_SUBTRACT
    when ShaderBlendSettings::Function::Min; LibGL::MIN
    when ShaderBlendSettings::Function::Max; LibGL::MAX
    else
      raise ArgumentError.new "Invalid blend function given!"
    end
  end
end

class Boleite::Private::OpenGLShaderObject
  @object_id : LibGL::UInt
  @type : ShaderType

  def initialize(source : String, type : ShaderType)
    @object_id = GL.safe_call { LibGL.createShader self.class.translate_shader_type(type) }
    @type = type

    GL.safe_call do
      conv_source = [source.to_unsafe.as(LibGL::Char*)].to_unsafe.as(LibGL::Char*)
      LibGL.shaderSource @object_id, 1, conv_source, nil
      LibGL.compileShader @object_id

      LibGL.getShaderiv @object_id, LibGL::COMPILE_STATUS, out status
      if status == LibGL::FALSE
        LibGL.getShaderiv @object_id, LibGL::INFO_LOG_LENGTH, out length
        info_log = Slice(LibGL::Char).new(length + 1)
        LibGL.getShaderInfoLog @object_id, length, nil, info_log
        message = String.new(info_log.to_unsafe.as(UInt8*).to_slice(length + 1))
        raise ShaderException.new @type, message
      end
    end
  end

  def finalize
    if @object_id > 0
      GL.safe_call { LibGL.deleteShader @object_id }
      @object_id = LibGL::UInt.zero
    end
  end

  def gl_identifier
    @object_id
  end

  def self.translate_shader_type(type : ShaderType)
    case type
    when ShaderType::Vertex; LibGL::VERTEX_SHADER
    when ShaderType::Geometry; LibGL::GEOMETRY_SHADER
    when ShaderType::Fragment; LibGL::FRAGMENT_SHADER
    else
      raise ArgumentError.new "Invalid shader type given!(#{type})"
    end
  end
end