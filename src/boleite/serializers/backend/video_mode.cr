module Boleite
  struct VideoMode
    struct ObjSerializer
      def marshal(obj, node)
        node.marshal("resolution", obj.resolution)
        node.marshal("mode", obj.mode.to_s)
        node.marshal("refresh_rate", obj.refresh_rate)
      end

      def unmarshal(node)
        video_mode = VideoMode.new
        video_mode.resolution = node.unmarshal("resolution", Vector2u)
        video_mode.mode = Mode.parse(node.unmarshal_string("mode"))
        video_mode.refresh_rate = node.unmarshal_int("refresh_rate").to_u16
        video_mode
      end
    end

    extend Serializable(ObjSerializer)
  end
end