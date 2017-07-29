module Boleite
  module Private
    class GLFW < Backend
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
        LibGLFW3.setErrorCallback(->GLFW.on_error) if @initialized

        @primary_surface = nil
        @primary_monitor = GLFWMonitor.new safe_call { LibGLFW3.getPrimaryMonitor }
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
        setup_main_target_settings(config)
        native = create_surface(config.video_mode)
        GLFWInput.bind_callbacks(native)
        @primary_surface = GLFWSurface.new(native)
      end

      def default_config
        config = BackendConfiguration.new
        config.gfx = BackendConfiguration::GfxType::OpenGL
        config.version = Version.new(4, 5)
        config.video_mode = default_video_mode(VideoMode::Mode::Borderless)
        config
      end

      def poll_event : InputEvent | Nil
        GLFWInput.poll
      end

      def default_video_mode(mode)
        current = @primary_monitor.current_video_mode
        VideoMode.new(current.width.to_u, current.height.to_u, mode, current.refreshRate.to_u16)
      end

      private def safe_call
        GLFW.safe_call { yield }
      end

      def self.safe_call
        check_errors
        val = yield
        check_errors
        return val
      end

      def self.check_errors
        if error = @@errors.pop?
          raise BackendException.new("#{error.code}: #{error.description}")
        end
      end

      protected def self.on_error(error : Int32, description : Int8*)
        @@errors << ErrorData.new(ErrorCode.new(error), String.new(description.as(UInt8*)))
      end

      private def setup_main_target_settings(config : BackendConfiguration)
        setup_opengl_settings(config)
        setup_refresh_rate(config)
        setup_rendering_settings(config)
        setup_window_settings(config)
      end

      private def setup_opengl_settings(config : BackendConfiguration)
        safe_call do
          LibGLFW3.windowHint(LibGLFW3::OPENGL_PROFILE, LibGLFW3::OPENGL_CORE_PROFILE)
          LibGLFW3.windowHint(LibGLFW3::OPENGL_FORWARD_COMPAT, 1)
          LibGLFW3.windowHint(LibGLFW3::CONTEXT_VERSION_MAJOR, config.version.major)
          LibGLFW3.windowHint(LibGLFW3::CONTEXT_VERSION_MINOR, config.version.minor)
          {% if flag?(:debug) %}
            LibGLFW3.windowHint(LibGLFW3::OPENGL_DEBUG_CONTEXT, 1)
          {% end %}
        end
      end

      private def setup_refresh_rate(config : BackendConfiguration)
        safe_call do
          if config.video_mode.any_refresh_rate?
            LibGLFW3.windowHint(LibGLFW3::REFRESH_RATE, config.video_mode.refresh_rate)
          else
            LibGLFW3.windowHint(LibGLFW3::REFRESH_RATE, LibGLFW3::DONT_CARE)
          end
        end
      end

      private def setup_rendering_settings(config)
        safe_call do
          if config.double_buffering
            LibGLFW3.windowHint(LibGLFW3::DOUBLEBUFFER, 1)
          else
            LibGLFW3.windowHint(LibGLFW3::DOUBLEBUFFER, 0)
          end
          LibGLFW3.windowHint(LibGLFW3::SAMPLES, config.multisamples)
        end
      end

      private def setup_window_settings(config)
        safe_call do
          LibGLFW3.windowHint(LibGLFW3::RESIZABLE, 0)
          case config.video_mode.mode
          when VideoMode::Mode::Windowed
            LibGLFW3.windowHint(LibGLFW3::DECORATED, 1)
          when VideoMode::Mode::Fullscreen
          when VideoMode::Mode::Borderless
            LibGLFW3.windowHint(LibGLFW3::DECORATED, 0)
            config.video_mode = default_video_mode(VideoMode::Mode::Borderless)
          end
        end
      end

      private def create_surface(video_mode)
        safe_call do
          monitor = video_mode.mode.fullscreen? ? @primary_monitor.ptr : Pointer(Void).null.as(LibGLFW3::Monitor)
          surface = LibGLFW3.createWindow(video_mode.resolution.x, video_mode.resolution.y, "Hello Crystal!", monitor, nil)
        end
      end
    end
  end
end