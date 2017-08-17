module Boleite
  enum ShaderType : UInt8
    None,
    Vertex,
    Geometry,
    Fragment,
    Count
  end
  ShaderTypeCount = 4

  class ShaderException < Exception
    def initialize(type, message)
      super type.to_s + " Shader object compilation failed: " + message
    end

    def initialize(message)
      super message
    end
  end

  struct ShaderDepthSettings
    enum Function
      Always,
      Never,
      Less,
      Greater,
      LessEqual,
      GreaterEqual,
      Equal,
      NotEqual
    end

    property enabled, func
    
    @enabled = false
    @func = Function::Always
  end

  struct ShaderBlendSettings
    enum Factor
      One,
      Zero,
      Source,
      OneMinusSource,
      Destination,
      OneMinusDestination,
      SourceAlpha,
      OneMinusSourceAlpha,
      DestinationAlpha,
      OneMinusDestinationAlpha,
      Constant,
      OneMinusConstant,
      ConstantAlpha,
      OneMinusConstantAlpha
    end

    enum Function
      Add,
      Subtract,
      ReverseSubtract,
      Min,
      Max
    end

    property enabled, source_factor, destination_factor, func

    @enabled = false
    @source_factor = Factor::One
    @destination_factor = Factor::One
    @func = Function::Add
  end

  struct ShaderValueSettings
    property world_transform, view_transform, projection_transform

    @world_transform = ""
    @view_transform = ""
    @projection_transform = ""
  end

  class ShaderParser
    struct PreParseCommand
      property tag, function

      def initialize(@tag : String, @function : Proc(String, ShaderParser, String))
      end
    end

    @preparse_commands = [] of PreParseCommand
    @custom_defines = {} of String => String
    @shader_sources = StaticArray(String, ShaderTypeCount).new("")
    @depth_settings = ShaderDepthSettings.new
    @blend_settings = ShaderBlendSettings.new
    @value_settings = ShaderValueSettings.new
    @source = ""
    @file_path = ""

    getter depth_settings, blend_settings, value_settings

    def initialize
      @preparse_commands << PreParseCommand.new(
        "#include", ->on_include(String, ShaderParser)
      )
      @preparse_commands << PreParseCommand.new(
        "#define", ->on_define(String, ShaderParser)
      )
    end

    def parse_file(path)
      @file_path = path
      source = read_file(path)
      parse(source)
    end

    def parse(source)
      @source = pre_process(source)
      shader_names = ["vertex", "geometry", "fragment", "depth", "blend", "values"]

      start_index = 0
      end_index = 0
      while end_index
        end_index = @source.index('\n', start_index)
        if end_index && start_index != end_index
          line = @source[start_index .. (end_index - 1)]
          stripped_line = line.gsub(/\s/, "")
          type = ShaderType::None
          shader_names.each_index do |type_index|
            if stripped_line == shader_names[type_index] 
              if type_index <= 2
                type = ShaderType.new type_index.to_u8 + 1u8
                end_index = append_source_to type, end_index + 1
              elsif type_index == 3
                end_index = parse_depth_settings end_index + 1
                type = ShaderType::Count
              elsif type_index == 4
                end_index = parse_blend_settings end_index + 1
                type = ShaderType::Count
              elsif type_index == 5
                end_index = parse_values_settings end_index + 1
                type = ShaderType::Count
              end
              break
            end
          end

          if type == ShaderType::None
            @shader_sources[ShaderType::None.to_i] += line + "\n"
          end
        end
        start_index = end_index + 1 unless end_index.nil?
      end
    end

    def set_define(define, value)
      @custom_defines[define] = value
    end

    def get_define(define)
      @custom_defines[define]
    end

    def has_define(define)
      @custom_defines[define]?.nil? == false
    end

    def define_source
      source = ""
      @custom_defines.each do |define, value|
        source += "#define " + define + " " + value + "\n"
      end
      source
    end

    def has_shader(type : ShaderType)
      @shader_sources[type.to_i].empty? == false
    end

    def full_shader_source
      @source
    end

    def shader_source(type : ShaderType)
      define_source + @shader_sources[ShaderType::None.to_i] + @shader_sources[type.to_i]
    end

    def file_path
      @file_path
    end

    def working_directory
      index = @file_path.rindex "/"
      if index.nil?
        return ""
      else
        return @file_path[0 .. index]
      end
    end

    protected def read_file(path)
      File.read(path)
    end

    protected def pre_process(source)
      @preparse_commands.each do |command|
        end_index = 0
        start_index = 1
        while start_index
          start_index = source.index command.tag, end_index
          if start_index
            argument_start = start_index + command.tag.size + 1
            end_index = source.index '\n', start_index
            end_index = source.size if end_index.nil?
            argument = source[argument_start .. end_index]
            result = command.function.call(argument, self)
            source = source.sub start_index .. end_index, result
          end
        end
      end
      source
    end

    protected def parse_source_from(start_index) : Tuple(Int32, String)
      scope_count = 0
      has_started_scope = false
      end_index = start_index
      result = ""
      while end_index
        end_index = @source.index '\n', start_index
        if end_index
          line = @source[start_index .. end_index]

          scope_count -= 1 if line.index '}'
          if has_started_scope && scope_count <= 0
            end_index += 1
            break
          elsif has_started_scope
            line = line[1 .. line.size] if line.index '\t'
            line = line[4 .. line.size] if line.index "    "
            result += line + "\n"
          end

          if line.index '{'
            has_started_scope = true
            scope_count += 1
          end
          start_index = end_index + 1
        end
      end
      end_index = @source.size if end_index.nil?
      return end_index, result
    end

    protected def append_source_to(type : ShaderType, start_index) : Int32
      end_index, result = parse_source_from start_index
      @shader_sources[type.to_i] = result
      end_index
    end

    protected def parse_depth_settings(start_index) : Int32
      end_index, result = parse_source_from start_index
      result = result.gsub(/\s/, "")
      @depth_settings.enabled = compile_bool_parameter result, "enabled"
      @depth_settings.func = compile_depth_func_parameter result, "function"
      end_index
    end

    protected def parse_blend_settings(start_index) : Int32
      end_index, result = parse_source_from start_index
      result = result.gsub(/\s/, "")
      @blend_settings.enabled = compile_bool_parameter result, "enabled"
      @blend_settings.source_factor = compile_blend_factor_parameter result, "sourceFactor"
      @blend_settings.destination_factor = compile_blend_factor_parameter result, "destinationFactor"
      @blend_settings.func = compile_blend_func_parameter result, "function"
      end_index
    end

    protected def parse_values_settings(start_index) : Int32
      end_index, result = parse_source_from start_index
      result = result.gsub(/\s/, "")
      @value_settings.world_transform = compile_string_parameter result, "worldTransform"
      @value_settings.view_transform = compile_string_parameter result, "viewTransform"
      @value_settings.projection_transform = compile_string_parameter result, "projectionTransform"
      end_index
    end

    protected def on_include(arg : String, parser : ShaderParser) : String
      path = arg
      if !File.exists? path
        path = parser.working_directory + "/" + arg
      end

      return read_file(path)
    end

    protected def on_define(arg : String, parser : ShaderParser) : String
      define = arg
      value = ""
      define_end = arg.index " "
      unless define_end.nil?
        define = arg[0 .. define_end]
        value = arg[(define_end + 1) .. arg.size]
      end
      parser.set_define(define, value)
      return "#define " + arg
    end

    private def value_for_settings_parameter(source, symbol) : String
      full_symbol = symbol + "="
      index = source.index full_symbol
      if index
        index += full_symbol.size
        end_index = source.index ';', index
        return source[index ... end_index] unless end_index.nil?
      end
      return ""
    end

    private def compile_bool_parameter(source, symbol) : Bool
      value = value_for_settings_parameter source, symbol
      if value == "true"
        true
      elsif value == "false"
        false
      else
        raise ShaderException.new "Failed to compile boolean value('" + value + "') for setting '" + symbol + "'"
      end
    end

    private def compile_string_parameter(source, symbol) : String
      value_for_settings_parameter source, symbol
    end

    private def compile_depth_func_parameter(source, symbol) : ShaderDepthSettings::Function
      value = value_for_settings_parameter source, symbol
      if value == "Always"
        ShaderDepthSettings::Function::Always
      elsif value == "Never"
        ShaderDepthSettings::Function::Never
      elsif value == "Less"
        ShaderDepthSettings::Function::Less
      elsif value == "Greater"
        ShaderDepthSettings::Function::Greater
      elsif value == "LessEqual"
        ShaderDepthSettings::Function::LessEqual
      elsif value == "GreaterEqual"
        ShaderDepthSettings::Function::GreaterEqual
      elsif value == "Equal"
        ShaderDepthSettings::Function::Equal
      elsif value == "NotEqual"
        ShaderDepthSettings::Function::NotEqual
      else
        raise ShaderException.new "Failed to compile depth function value('" + value + "') for setting '" + symbol + "'"
      end
    end

    private def compile_blend_factor_parameter(source, symbol) : ShaderBlendSettings::Factor
      value = value_for_settings_parameter source, symbol
      if value == "One"
        ShaderBlendSettings::Factor::One
      elsif value == "Zero"
        ShaderBlendSettings::Factor::Zero
      elsif value == "Source"
        ShaderBlendSettings::Factor::Source
      elsif value == "OneMinusSource"
        ShaderBlendSettings::Factor::OneMinusSource
      elsif value == "Destination"
        ShaderBlendSettings::Factor::Destination
      elsif value == "OneMinusDestination"
        ShaderBlendSettings::Factor::OneMinusDestination
      elsif value == "SourceAlpha"
        ShaderBlendSettings::Factor::SourceAlpha
      elsif value == "OneMinusSourceAlpha"
        ShaderBlendSettings::Factor::OneMinusSourceAlpha
      elsif value == "DestinationAlpha"
        ShaderBlendSettings::Factor::DestinationAlpha
      elsif value == "OneMinusDestinationAlpha"
        ShaderBlendSettings::Factor::OneMinusDestinationAlpha
      elsif value == "Constant"
        ShaderBlendSettings::Factor::Constant
      elsif value == "OneMinusConstant"
        ShaderBlendSettings::Factor::OneMinusConstant
      elsif value == "ConstantAlpha"
        ShaderBlendSettings::Factor::ConstantAlpha
      elsif value == "OneMinusConstantAlpha"
        ShaderBlendSettings::Factor::OneMinusConstantAlpha
      else
        raise ShaderException.new "Failed to compile blend factor value('" + value + "') for setting '" + symbol + "'"
      end
    end

    private def compile_blend_func_parameter(source, symbol) : ShaderBlendSettings::Function
      value = value_for_settings_parameter source, symbol
      if value == "Add"
        ShaderBlendSettings::Function::Add
      elsif value == "Subtract"
        ShaderBlendSettings::Function::Subtract
      elsif value == "ReverseSubtract"
        ShaderBlendSettings::Function::ReverseSubtract
      elsif value == "Min"
        ShaderBlendSettings::Function::Min
      elsif value == "Max"
        ShaderBlendSettings::Function::Max
      else
        raise ShaderException.new "Failed to compile blend function value('" + value + "') for setting '" + symbol + "'"
      end
    end
  end
end