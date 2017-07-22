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
        setup_main_target_settings(config)
        @primary_surface = GLFWSurface.new(create_surface(config.video_mode))
      end

      def default_config
        
        config = BackendConfiguration.new
        config.gfx = BackendConfiguration::GfxType::OpenGL
        config.version = Version.new(4, 5)
        config.video_mode = default_video_mode(VideoMode::Mode::Borderless)
        config
      end

      def default_video_mode(mode)
        current = @primary_monitor.current_video_mode
        VideoMode.new(current.width.to_u, current.height.to_u, mode, current.refreshRate.to_u16)
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

      private def setup_main_target_settings(config : BackendConfiguration)
        setup_opengl_settings(config)
        setup_refresh_rate(config)
        setup_rendering_settings(config)
        setup_window_settings(config)
      end

      private def setup_opengl_settings(config : BackendConfiguration)
        LibGLFW3.windowHint(LibGLFW3::OPENGL_PROFILE, LibGLFW3::OPENGL_CORE_PROFILE)
        LibGLFW3.windowHint(LibGLFW3::OPENGL_FORWARD_COMPAT, 1)
        LibGLFW3.windowHint(LibGLFW3::CONTEXT_VERSION_MAJOR, config.version.major)
        LibGLFW3.windowHint(LibGLFW3::CONTEXT_VERSION_MINOR, config.version.minor)
        {% if flag?(:debug) %}
          LibGLFW3.windowHint(LibGLFW3::OPENGL_DEBUG_CONTEXT, 1)
        {% end %}
      end

      private def setup_refresh_rate(config : BackendConfiguration)
        if config.video_mode.any_refresh_rate?
          LibGLFW3.windowHint(LibGLFW3::REFRESH_RATE, config.video_mode.refresh_rate)
        else
          LibGLFW3.windowHint(LibGLFW3::REFRESH_RATE, LibGLFW3::DONT_CARE)
        end
      end

      private def setup_rendering_settings(config)
        if config.double_buffering
          LibGLFW3.windowHint(LibGLFW3::DOUBLEBUFFER, 1)
        else
          LibGLFW3.windowHint(LibGLFW3::DOUBLEBUFFER, 0)
        end
        LibGLFW3.windowHint(LibGLFW3::SAMPLES, config.multisamples)
      end

      private def setup_window_settings(config)
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

      private def create_surface(video_mode)
        monitor = video_mode.mode.fullscreen? ? @primary_monitor.ptr : Pointer(Void).null.as(LibGLFW3::Monitor)
        surface = LibGLFW3.createWindow(video_mode.resolution.x, video_mode.resolution.y, "Hello Crystal!", monitor, nil)
      end
    end
  end
end