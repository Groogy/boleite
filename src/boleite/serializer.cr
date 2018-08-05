require "yaml"

class Boleite::Serializer(AttachedData)
  class Exception < Exception
  end

  alias Type = Bool | Int64 | Float64 | String | Hash(Type, Type) | Array(Type) | BaseNode | Nil

  abstract class BaseNode
    @value : Type
    
    def to_yaml(io : IO)
      unless @value.nil?
        conv = Translator.new().translate(@value)
        YAML.dump(conv, io)
      end
    end

    abstract def value
  end

  class Node(AttachedData) < BaseNode
    property value
    getter data, key

    @key : String | Int32 | Nil

    def initialize(@data : AttachedData, @value : Type, @key)
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
      child = Node.new @data, nil, {{key}}
      child.internal_marshal({{obj}})
      @value = {{expected_target}}.new if @value.nil?
      if target = @value.as? {{expected_target}}
        target[{{key}}] = child
      else
        raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected {{expected_target}}")
      end
    end

    def has_key?(k : String)
      if hsh = @value.as?(Hash(Type, Type))
        hsh.has_key? k
      else
        false
      end
    end

    def has_index?(i : Int)
      if ary = @value.as?(Array(Type))
        i >= 0 && i < ary.size
      else
        false
      end
    end

    def marshal(index : Int, string : String)
      marshal_primitive(index.to_i32, string, Array(Type))
    end

    def marshal(key : String, string : String)
      marshal_primitive(key, string, Hash(Type, Type))
    end

    def marshal(index : Int, int : Int)
      marshal_primitive(index.to_i32, int.to_i64, Array(Type))
    end

    def marshal(key : String, int : Int)
      marshal_primitive(key, int.to_i64, Hash(Type, Type))
    end

    def marshal(index : Int, float : Float)
      marshal_primitive(index.to_i32, float.to_f64, Array(Type))
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
      marshal_obj(index.to_i32, obj, Array(Type))
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
        child = Node.new @data, target[{{key}}], {{key}}
        child.internal_unmarshal({{type}})
      else
        raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected {{expected_target}}")
      end
    end

    def unmarshal_string(index : Int)
      unmarshal_primitive(index.to_i32, String, Array(Type))
    end

    def unmarshal_string(key : String)
      unmarshal_primitive(key, String, Hash(Type, Type))
    end

    def unmarshal_int(index : Int)
      unmarshal_primitive(index.to_i32, Int64, Array(Type))
    end

    def unmarshal_int(key : String)
      unmarshal_primitive(key, Int64, Hash(Type, Type))
    end

    def unmarshal_float(index : Int)
      unmarshal_primitive(index.to_i32, Float64, Array(Type))
    end

    def unmarshal_float(key : String)
      unmarshal_primitive(key, Float64, Hash(Type, Type))
    end

    def unmarshal_bool(index : Int)
      unmarshal_primitive(index.to_i32, Bool, Array(Type))
    end

    def unmarshal_bool(key : String)
      unmarshal_primitive(key, Bool, Hash(Type, Type))
    end

    def unmarshal(index : Int, type)
      unmarshal_obj(index.to_i32, type, Array(Type))
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

    def each_child
      hash = @value.as(Hash(Type, Type))
      hash.each do |key, value|
        child = Node.new @data, value, key.as(String)
        yield child
      end
    end

    protected def internal_marshal(list : Array(Type))
      value = Array(Type).new list.size
      list.each { |val| value << val }
      @value = value
    end

    protected def internal_marshal(list : Array(U)) forall U
      value = Array(Type).new list.size
      list.each_with_index do |val, index|
        child = Node.new @data, nil, index
        child.internal_marshal(val)
        value << child
      end
      @value = value
    end

    protected def internal_marshal(tuple : Tuple(*U)) forall U
      @value = Array(Type).new(tuple.size) { nil }
      {% for klass, index in U %}
        marshal {{ index }}, tuple[{{ index }}]
      {% end %}
    end

    protected def internal_marshal(obj)
      serializer = obj.class.serializer
      serializer.marshal(obj, self)
    end

    protected def internal_unmarshal(klass : Array(U).class) forall U
      if value = @value.as? Array(Type)
        list = klass.new
        value.each_with_index do |val, index|
          child = Node.new @data, val, index
          list << child.internal_unmarshal(U).as(U)
        end
        list
      else
        raise Exception.new "Serialization::Node value of wrong type! Have #{@value.class}, expected Array(Type)"
      end
    end

    protected def internal_unmarshal(klass : Hash(X, Y).class) : Hash(X, Y) forall X, Y
      if value = @value.as? Hash(Type, Type)
        list = klass.new
        value.each do |key, val| 
          child = Node.new @data, val, key.as(String)
          list[key.as(X)] = child.internal_unmarshal(Y).as(Y)
        end
        list
      else
        raise Exception.new "Serialization::Node value of wrong type! Have #{@value.class}, expected Hash(Type, Type)"
      end
    end

    protected def internal_unmarshal(klass : Type.class) : Type
      @value
    end

    protected def internal_unmarshal(klass)
      serializer = klass.serializer
      serializer.unmarshal(self)
    end

    protected def build_internal_data(data : YAML::Any)
      translator = Translator.new
      @value = translator.translate_yaml(data)
    end
  end

  struct Translator
    def translate_array(data : Array(Type)) : YAML::Any
      ary = data.map { |item| translate(item).as(YAML::Any) }
      YAML::Any.new ary
    end

    def translate_hash(data : Hash(Type, Type)) : YAML::Any
      hash = {} of YAML::Any => YAML::Any
      data.each { |key, value| hash[translate(key)] = translate(value) }
      YAML::Any.new hash
    end
    
    def translate(data : Type) : YAML::Any
      case data
      when Array(Type)
        translate_array(data)
      when Hash(Type, Type)
        translate_hash(data)
      when BaseNode
        translate(data.value)
      else
        YAML::Any.new data
      end
    end

    def translate_yaml_array(data : Array(YAML::Any)) : Type
      data.map { |item| translate_yaml(item).as(Type) }
    end

    def translate_yaml_hash(data : Hash(YAML::Any, YAML::Any)) : Type
      hash = {} of Type => Type
      data.each { |key, value| hash[translate_yaml(key)] = translate_yaml(value) }
      hash
    end

    def translate_yaml(data : YAML::Any) : Type
      case data.raw
      when Array(YAML::Any)
        translate_yaml_array data.as_a
      when Hash(YAML::Any, YAML::Any)
        translate_yaml_hash data.as_h
      when String
        translate_yaml_string data.as_s
      when Int64
        data.as_i64
      when Float64
        data.as_f
      when Bool
        data.raw.as(Bool)
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

  @root : BaseNode | Nil = nil
  @data : AttachedData
  
  def initialize(@data : AttachedData)
  end

  def marshal(obj)
    root = Node.new @data, nil, nil
    root.internal_marshal(obj)
    @root = root
  end

  def unmarshal(data : YAML::Any, expected_type)
    root = Node.new @data, nil, nil
    @root = root
    root.build_internal_data(data)
    root.internal_unmarshal(expected_type)
  end

  def dump(io : IO)
    YAML.dump(@root, io) unless @root.nil?
  end

  def read(io : IO)
    YAML.parse(io)
  end
end
