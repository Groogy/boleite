require "yaml"

class Boleite::Serializer
  class Exception < Exception
  end

  alias Type = Bool | Int64 | Float64 | String | Hash(Type, Type) | Array(Type) | Node | Nil

  struct ValueWrapper
    def initialize(@value : Type = nil)
    end

    def [](key)
      @value[key]
    end

    def []=(key, value)
      @value[key] = value
    end
  end

  class Node
    property :value

    def initialize(@value : Type = nil)
    end

    private macro marshal_primitive(key, value, expected_target)
      @value = {{expected_target}}.new if @value.nil?
      if target = @value.as? {{expected_target}}
        target[{{key}}] = {{value}}
      else
        raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected {{expected_target}}")
      end
    end

    private macro marshal_obj(key, obj, expected_target)
      child = Node.new()
      child.internal_marshal({{obj}})
      @value = {{expected_target}}.new if @value.nil?
      if target = @value.as? {{expected_target}}
        target[{{key}}] = child
      else
        raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected {{expected_target}}")
      end
    end

    def marshal(index : Int, string : String)
      marshal_primitive(index.to_i64, string, Array(Type))
    end

    def marshal(key : String, string : String)
      marshal_primitive(key, string, Hash(Type, Type))
    end

    def marshal(index : Int, int : Int)
      marshal_primitive(index.to_i64, int.to_i64, Array(Type))
    end

    def marshal(key : String, int : Int)
      marshal_primitive(key, int.to_i64, Hash(Type, Type))
    end

    def marshal(index : Int, float : Float)
      marshal_primitive(index.to_i64, float.to_f64, Array(Type))
    end

    def marshal(key : String, float : Float)
      marshal_primitive(key, float.to_f64, Hash(Type, Type))
    end

    def marshal(index : Int, bool : Bool)
      marshal_primitive(index.to_i64, bool, Array(Type))
    end

    def marshal(key : String, bool : Bool)
      marshal_primitive(key, bool, Hash(Type, Type))
    end

    def marshal(index : Int, obj)
      marshal_obj(index.to_i64, obj, Array(Type))
    end

    def marshal(key : String, obj)
      marshal_obj(key, obj, Hash(Type, Type))
    end

    private macro unmarshal_primitive(key, type, expected_target)
      if target = @value.as? {{expected_target}}
        target[{{key}}].as({{type}})
      else
        raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected {{expected_target}}")
      end
    end

    private macro unmarshal_obj(key, type, expected_target)
      if target = @value.as? {{expected_target}}
        child = Node.new(target[{{key}}])
        child.internal_unmarshal({{type}})
      else
        raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected {{expected_target}}")
      end
    end

    def unmarshal_string(index : Int)
      unmarshal_primitive(index.to_i64, String, Array(Type))
    end

    def unmarshal_string(key : String)
      unmarshal_primitive(key, String, Hash(Type, Type))
    end

    def unmarshal_int(index : Int)
      unmarshal_primitive(index.to_i64, Int64, Array(Type))
    end

    def unmarshal_int(key : String)
      unmarshal_primitive(key, Int64, Hash(Type, Type))
    end

    def unmarshal_float(index : Int)
      unmarshal_primitive(index.to_i64, Float64, Array(Type))
    end

    def unmarshal_float(key : String)
      unmarshal_primitive(key, Float64, Hash(Type, Type))
    end

    def unmarshal_bool(index : Int)
      unmarshal_primitive(index.to_i64, Bool, Array(Type))
    end

    def unmarshal_bool(key : String)
      unmarshal_primitive(key, Bool, Hash(Type, Type))
    end

    def unmarshal(index : Int, type)
      unmarshal_obj(index.to_i64, type, Array(Type))
    end

    def unmarshal(key : String, type)
      unmarshal_obj(key, type, Hash(Type, Type))
    end

    def each
      hash = @value.as(Hash(Type, Type))
      hash.each do |key, value|
        yield key, value
      end
    end

    def to_yaml(io : IO)
      unless @value.nil?
        conv = Translator.new().translate(@value)
        YAML.dump(conv, io)
      end
    end

    protected def internal_marshal(obj)
      serializer = obj.class.serializer
      serializer.marshal(obj, self)
    end

    protected def internal_unmarshal(klass)
      serializer = klass.serializer
      serializer.unmarshal(self)
    end

    protected def build_internal_data(data : YAML::Type)
      translator = Translator.new
      @value = translator.translate_yaml(data)
    end
  end

  struct Translator
    def translate_array(data : Array(Type)) : YAML::Type
      data.map { |item| translate(item).as(YAML::Type) } 
    end

    def translate_hash(data : Hash(Type, Type)) : YAML::Type
      hash = {} of YAML::Type => YAML::Type
      data.each { |key, value| hash[translate(key)] = translate(value) }
      hash
    end
    
    def translate(data : Type) : YAML::Type
      case data
      when Array(Type)
        translate_array(data)
      when Hash(Type, Type)
        translate_hash(data)
      when Node
        translate(data.value)
      else
        data
      end
    end

    def translate_yaml_array(data : Array(YAML::Type)) : Type
      data.map { |item| translate_yaml(item).as(Type) }
    end

    def translate_yaml_hash(data : Hash(YAML::Type, YAML::Type)) : Type
      hash = {} of Type => Type
      data.each { |key, value| hash[translate_yaml(key)] = translate_yaml(value) }
      hash
    end

    def translate_yaml(data : YAML::Type) : Type
      case data
      when Array(YAML::Type)
        translate_yaml_array(data)
      when Hash(YAML::Type, YAML::Type)
        translate_yaml_hash(data)
      when String
        translate_yaml_string(data)
      when Int64
        data
      when Float64
        data
      when Bool
        data
      end
    end

    def translate_yaml_string(data : String) : Type
      if val = data.to_i64?
        return val
      elsif val = data.to_f?
        return val
      else
        return data
      end
    end
  end

  @root : Node | Nil = nil
  
  def initialize()
  end

  def marshal(obj)
    if root = Node.new
      root.internal_marshal(obj)
      @root = root
    end
  end

  def unmarshal(data : YAML::Type, expected_type)
    if root = Node.new
      @root = root
      root.build_internal_data(data)
      root.internal_unmarshal(expected_type)
    end
  end

  def dump(io : IO)
    YAML.dump(@root, io) unless @root.nil?
  end

  def read(io : IO)
    YAML.parse(io).raw
  end
end
