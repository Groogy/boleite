struct Boleite::VectorImp(Type, Size)
  struct ObjSerializer(Type, Size)
    def marshal(obj, node)
      tmp = Array(SerializableType).new(Size)
      obj.elements.each do |value|
        tmp << value.to_f
      end
      node.value = tmp
    end

    def unmarshal(node)
      arr = node.value.as(Array(SerializableType))
      VectorImp(Type, Size).new do |index|
        Type.new(arr[index].as(Number))
      end
    end
  end

  def self.serializer
    ObjSerializer(Type, Size).new
  end
end
