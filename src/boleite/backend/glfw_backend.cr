module Boleite
  module Private
    class GLFWBackend < Backend
      enum ErrorCode
        NotInitialized = LibGLFW3::NOT_INITIALIZED
        NoCurrentContext = LibGLFW3::NO_CURRENT_CONTEXT
        InvalidEnum = LibGLFW3::INVALID_ENUM
        OutOfMemory = LibGLFW3::OUT_OF_MEMORY
        APIUnavailable = LibGLFW3::API_UNAVAILABLE
        VersionUnavailable = LibGLFW3::VERSION_UNAVAILABLE
        PlatformError = LibGLFW3::PLATFORM_ERROR
        FormatUnavailable = LibGLFW3::FORMAT_UNAVAILABLE
      end

      struct ErrorData
        property :code, description

        def initialize(@code : ErrorCode, @description : String)
        end
      end

      @@errors = [] of ErrorData

      def initialize()
        @initialized = LibGLFW3.init != 0
        LibGLFW3.setErrorCallback(->GLFWBackend.on_error) if @initialized

        @primary_surface = nil
        @primary_monitor = GLFWMonitor.new(LibGLFW3.getPrimaryMonitor)
      end

      def finalize()
        if @initialized
          @initialized = false
          unless @primary_surface.nil?
            @primary_surface.as(GLFWSurface).finalize
          end
          LibGLFW3.terminate
        end
      end

      def is_initialized?
        @initialized
      end

      requires(create_main_target(config : BackendConfiguration), config.gfx == BackendConfiguration::GfxType::OpenGL)
      def create_main_target(config : BackendConfiguration)
        LibGLFW3.windowHint(LibGLFW3::OPENGL_PROFILE, LibGLFW3::OPENGL_CORE_PROFILE)
        LibGLFW3.windowHint(LibGLFW3::OPENGL_FORWARD_COMPAT, 1)
        LibGLFW3.windowHint(LibGLFW3::CONTEXT_VERSION_MAJOR, config.version.major)
        LibGLFW3.windowHint(LibGLFW3::CONTEXT_VERSION_MINOR, config.version.minor)
        resolution = config.video_mode.resolution
        surface = LibGLFW3.createWindow(resolution.x, resolution.y, "Hello Crystal!", nil, nil)

        @primary_surface = GLFWSurface.new(surface)
      end

      def default_config
        current = @primary_monitor.current_video_mode
        config = BackendConfiguration.new
        config.gfx = BackendConfiguration::GfxType::OpenGL
        config.version = Version.new(4, 5)
        config.video_mode = VideoMode.new(current.width.to_u, current.height.to_u, VideoMode::Mode::Borderless)
        config
      end

      def safe_call
        check_errors
        val = yield
        check_errors
        return val
      end

      def check_errors
        if error = @errors.pop?
          raise BackendException.new("#{error.code}: #{error.description}")
        end
      end

      protected def self.on_error(error : Int32, description : Int8*)
        @@errors << ErrorData.new(ErrorCode.new(error), String.new(description.as(UInt8*)))
      end
    end
  end
end