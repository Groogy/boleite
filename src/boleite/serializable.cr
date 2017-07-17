module Boleite
  module Serializable(SerializerType)
    def serializer
      SerializerType.new
    end
  end
end