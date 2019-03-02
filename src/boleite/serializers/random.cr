class Boleite::NoiseRandom
  struct ObjSerializer
    def marshal(obj, node)
      seed = obj.seed.to_i64
      index = obj.index.to_i64
      node.value = [seed.as(SerializableType), index.as(SerializableType)]
    end

    def unmarshal(node)
      arr = node.value.as(Array(SerializableType))
      seed = arr[0].as(Int64)
      index = arr[1].as(Int64)
      NoiseRandom.new seed.to_u32, index.to_u32
    end
  end

  extend Serializable(ObjSerializer)
end
