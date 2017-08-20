struct Boleite::Version
  struct ObjSerializer
    def marshal(obj, node)
      node.value = [obj.major.to_i32, obj.minor.to_i32, obj.patch.to_i32] of Serializer::Type
    end
    
    def unmarshal(node)
      arr = node.value.as(Array(Serializer::Type))
      arr = arr.map { |item| item.as(Int32) }

      Version.new(arr[0].to_u8, arr[1].to_u8, arr[2].to_u8)
    end
  end

  extend Serializable(ObjSerializer)
end
