require "yaml"

module Boleite
  class Serializer
    class Exception < Exception
    end

    alias Type = Bool | Int32 | Float64 | String | Hash(Type, Type) | Array(Type) | Node | Nil

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

      def marshal(index : Int32, obj)
        child = Node.new()
        child.internal_marshal(obj)
        @value = [] of Type if @value.nil?
        if arr = @value.as? Array(Type)
          arr[index] = child
        else
          raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected #{Array(Type)}")
        end
      end

      def marshal(key : String, obj)
        child = Node.new()
        child.internal_marshal(obj)
        @value = {} of Type => Type if @value.nil?
        if hash = @value.as? Hash(Type, Type)
          hash[key] = child
        else
          raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected #{Hash(Type, Type)}")
        end
      end

      def unmarshal(index : Int32, type)
        if arr = @value.as? Array(Type)
          child = Node.new(arr[key])
          child.internal_unmarshal(type)
        else
          raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected #{Array(Type)}")
        end
      end

      def unmarshal(key : String, type)
        if hash = @value.as? Hash(Type, Type)
          child = Node.new(hash[key])
          child.internal_unmarshal(type)
        else
          raise Exception.new("Serialization::Node value of wrong type! Have #{@value.class}, expected #{Hash(Type, Type)}")
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
          data.to_s
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
        end
      end

      def translate_yaml_string(data : String) : Type
        if val = data.to_i?
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
end