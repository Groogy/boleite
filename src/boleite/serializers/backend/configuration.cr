module Boleite
  class BackendConfiguration
    struct ObjSerializer
      def marshal(obj, node)
        node.marshal("gfx", obj.gfx.to_s)
        node.marshal("version", obj.version)
        node.marshal("video_mode", obj.video_mode)
        node.marshal("double_buffering", obj.double_buffering)
        node.marshal("multisamples", obj.multisamples)
      end

      def unmarshal(node)
        config = BackendConfiguration.new()
        config.gfx = GfxType.parse(node.unmarshal_string("gfx"))
        config.version = node.unmarshal("version", Version)
        config.video_mode = node.unmarshal("video_mode", VideoMode)
        config.double_buffering = node.unmarshal_bool("double_buffering")
        config.multisamples = node.unmarshal_int("multisamples").to_u8
        config
      end
    end

    extend Serializable(ObjSerializer)
  end
end