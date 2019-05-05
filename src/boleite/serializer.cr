require "yaml"

module Boleite
  alias SerializableType = Bool | Int64 | Float64 | String | Hash(SerializableType, SerializableType) | Array(SerializableType) | SerializerBaseNode | Nil
end

abstract class Boleite::SerializerBaseNode
end

struct Boleite::SerializerTranslator
  def translate_array(data : Array(SerializableType)) : YAML::Any
    ary = data.map { |item| translate(item).as(YAML::Any) }
    YAML::Any.new ary
  end

  def translate_hash(data : Hash(SerializableType, SerializableType)) : YAML::Any
    hash = {} of YAML::Any => YAML::Any
    data.each { |key, value| hash[translate(key)] = translate(value) }
    YAML::Any.new hash
  end
  
  def translate(data : SerializableType) : YAML::Any
    case data
    when Array(SerializableType)
      translate_array(data)
    when Hash(SerializableType, SerializableType)
      translate_hash(data)
    when SerializerBaseNode
      translate(data.value)
    else
      YAML::Any.new data
    end
  end

  def translate_yaml_array(data : Array(YAML::Any)) : SerializableType
    data.map { |item| translate_yaml(item).as(SerializableType) }
  end

  def translate_yaml_hash(data : Hash(YAML::Any, YAML::Any)) : SerializableType
    hash = {} of SerializableType => SerializableType
    data.each { |key, value| hash[translate_yaml(key)] = translate_yaml(value) }
    hash
  end

  def translate_yaml(data : YAML::Any) : SerializableType
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

  def translate_yaml_string(data : String) : SerializableType
    if val = data.to_i64?
      return val
    elsif val = data.to_f?
      return val
    else
      return data
    end
  end
end

abstract class Boleite::SerializerBaseNode
  @value : SerializableType
  
  def to_yaml(io : IO)
    unless @value.nil?
      conv = SerializerTranslator.new().translate(@value)
      YAML.dump(conv, io)
    end
  end

  abstract def value
end

class Boleite::Serializer(AttachedData)
  class Exception < Exception
  end

  class Node(AttachedData) < SerializerBaseNode
    property value
    getter data, key

    @key : String | Int32 | Nil

    def initialize(@data : AttachedData, @value : SerializableType, @key)
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

    def has?(k : String)
      if hsh = @value.as?(Hash(SerializableType, SerializableType))
        hsh.has_key? k
      else
        false
      end
    end

    def has?(i : Int)
      if ary = @value.as?(Array(SerializableType))
        i >= 0 && i < ary.size
      else
        false
      end
    end

    def marshal(index : Int, string : String)
      marshal_primitive(index.to_i32, string, Array(SerializableType))
    end

    def marshal(key : String, string : String)
      marshal_primitive(key, string, Hash(SerializableType, SerializableType))
    end

    def marshal(index : Int, int : Int)
      marshal_primitive(index.to_i32, int.to_i64, Array(SerializableType))
    end

    def marshal(key : String, int : Int)
      marshal_primitive(key, int.to_i64, Hash(SerializableType, SerializableType))
    end

    def marshal(index : Int, float : Float)
      marshal_primitive(index.to_i32, float.to_f64, Array(SerializableType))
    end

    def marshal(key : String, float : Float)
      marshal_primitive(key, float.to_f64, Hash(SerializableType, SerializableType))
    end

    def marshal(index : Int, bool : Bool)
      marshal_primitive(index.to_i64, bool, Array(SerializableType))
    end

    def marshal(key : String, bool : Bool)
      marshal_primitive(key, bool, Hash(SerializableType, SerializableType))
    end

    def marshal(index : Int, obj)
      marshal_obj(index.to_i32, obj, Array(SerializableType))
    end

    def marshal(key : String, obj)
      marshal_obj(key, obj, Hash(SerializableType, SerializableType))
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
      unmarshal_primitive(index.to_i32, String, Array(SerializableType))
    end

    def unmarshal_string(key : String)
      unmarshal_primitive(key, String, Hash(SerializableType, SerializableType))
    end

    def unmarshal_string?(id, default)
      if has? id
        unmarshal_string id
      else
        default
      end
    end

    def unmarshal_int(index : Int)
      unmarshal_primitive(index.to_i32, Int64, Array(SerializableType))
    end

    def unmarshal_int(key : String)
      unmarshal_primitive(key, Int64, Hash(SerializableType, SerializableType))
    end

    def unmarshal_int?(id, default)
      if has? id
        unmarshal_int id
      else
        default
      end
    end

    def unmarshal_float(index : Int)
      unmarshal_primitive(index.to_i32, Float64, Array(SerializableType))
    end

    def unmarshal_float(key : String)
      unmarshal_primitive(key, Float64, Hash(SerializableType, SerializableType))
    end

    def unmarshal_float?(id, default)
      if has? id
        unmarshal_float id
      else
        default
      end
    end

    def unmarshal_bool(index : Int)
      unmarshal_primitive(index.to_i32, Bool, Array(SerializableType))
    end

    def unmarshal_bool(key : String)
      unmarshal_primitive(key, Bool, Hash(SerializableType, SerializableType))
    end

    def unmarshal_bool?(id, default)
      if has? id
        unmarshal_bool id
      else
        default
      end
    end

    def unmarshal(index : Int, type)
      unmarshal_obj(index.to_i32, type, Array(SerializableType))
    end

    def unmarshal(key : String, type)
      unmarshal_obj(key, type, Hash(SerializableType, SerializableType))
    end

    def unmarshal?(id, type, default)
      if has? id
        unmarshal id, type
      else
        default
      end
    end

    def get_child(key : String)
      hash = @value.as(Hash(SerializableType, SerializableType))
      Node.new @data, hash[key], key
    end

    def each
      hash = @value.as(Hash(SerializableType, SerializableType))
      hash.each do |key, value|
        yield key, value
      end
    end

    def each_child
      hash = @value.as(Hash(SerializableType, SerializableType))
      hash.each do |key, value|
        child = Node.new @data, value, key.as(String)
        yield child
      end
    end

    protected def internal_marshal(list : Array(SerializableType))
      value = Array(SerializableType).new list.size
      list.each { |val| value << val }
      @value = value
    end

    protected def internal_marshal(list : Array(U)) forall U
      value = Array(SerializableType).new list.size
      list.each_with_index do |val, index|
        child = Node.new @data, nil, index
        child.internal_marshal(val)
        value << child
      end
      @value = value
    end

    protected def internal_marshal(tuple : Tuple(*U)) forall U
      @value = Array(SerializableType).new(tuple.size) { nil }
      {% for klass, index in U %}
        marshal {{ index }}, tuple[{{ index }}]
      {% end %}
    end

    protected def internal_marshal(obj)
      serializer = obj.class.serializer
      serializer.marshal(obj, self)
    end

    protected def internal_unmarshal(klass : Array(U).class) forall U
      if value = @value.as? Array(SerializableType)
        list = klass.new
        value.each_with_index do |val, index|
          child = Node.new @data, val, index
          list << child.internal_unmarshal(U).as(U)
        end
        list
      elsif value = @value.as? Hash(SerializableType, SerializableType)
        list = klass.new
        value.each do |key, value|
          child = Node.new @data, value, key.as(String)
          list << child.internal_unmarshal(U).as(U)
        end
        list
      else
        raise Exception.new "Serialization::Node value of wrong type! Have #{@value.class}, expected Array(SerializableType)"
      end
    end

    protected def internal_unmarshal(klass : Hash(X, Y).class) : Hash(X, Y) forall X, Y
      if value = @value.as? Hash(SerializableType, SerializableType)
        list = klass.new
        value.each do |key, val| 
          child = Node.new @data, val, key.as(String)
          list[key.as(X)] = child.internal_unmarshal(Y).as(Y)
        end
        list
      else
        raise Exception.new "Serialization::Node value of wrong type! Have #{@value.class}, expected Hash(SerializableType, SerializableType)"
      end
    end

    protected def internal_unmarshal(klass : SerializableType.class) : SerializableType
      @value
    end

    protected def internal_unmarshal(klass)
      serializer = klass.serializer
      serializer.unmarshal(self)
    end

    protected def build_internal_data(data : YAML::Any)
      translator = SerializerTranslator.new
      @value = translator.translate_yaml(data)
    end
  end

  @root : Node(AttachedData)? = nil
  @data : AttachedData
  
  def initialize(@data : AttachedData)
  end

  def marshal(obj)
    root = Node.new @data, nil, nil
    root.internal_marshal(obj)
    @root = root
  end

  def unmarshal(expected_type)
    if root = @root
      root.internal_unmarshal(expected_type)
    else
      raise "Need to load data with serializer before you try to unmarshal it."
    end
  end

  def each
    if root = @root
      root.each do |k, v|
        yield k, v
      end
    end
  end

  def dump(io : IO)
    YAML.dump(@root, io) unless @root.nil?
  end

  def read(io : IO)
    data = YAML.parse(io)
    root = Node.new @data, nil, nil
    @root = root
    root.build_internal_data(data)
  end
end
