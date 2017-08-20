
module Boleite::Serializable(SerializerType)
  def serializer
    SerializerType.new
  end
end
