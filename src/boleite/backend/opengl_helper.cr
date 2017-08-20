module Boleite
  module Private
    module GL
      def self.safe_call
        check_errors
        result = yield
        check_errors
        result
      end

      private def self.check_errors
        error = LibGL.getError
        if error != LibGL::NO_ERROR
          id = id_error error
          desc = desc_error error
          raise BackendException.new "OpenGL error: #{desc} (#{id})"
        end
      end

      private def self.id_error(error)
        case error
        when LibGL::INVALID_ENUM; "GL_INVALID_ENUM"
        when LibGL::INVALID_VALUE; "GL_INVALID_VALUE"
        when LibGL::INVALID_OPERATION; "GL_INVALID_OPERATION"
        when LibGL::STACK_OVERFLOW; "GL_STACK_OVERFLOW"
        when LibGL::STACK_UNDERFLOW; "GL_STACK_UNDERFLOW"
        when LibGL::OUT_OF_MEMORY; "GL_OUT_OF_MEMORY"
        when LibGL::INVALID_FRAMEBUFFER_OPERATION; "GL_INVALID_FRAMEBUFFER_OPERATION"
        when LibGL::CONTEXT_LOST; "GL_CONTEXT_LOST"
        else "<UNKNOWN ERROR>"
        end
      end

      private def self.desc_error(error)
        case error
        when LibGL::INVALID_ENUM; "An invalid enumeration parameter was given to an OpenGL function."
        when LibGL::INVALID_VALUE; "An invalid value parameter was given to an OpenGL function."
        when LibGL::INVALID_OPERATION; "An OpenGL function called with invalid state or combination of parameters."
        when LibGL::STACK_OVERFLOW; "Stack push would overflow stack size."
        when LibGL::STACK_UNDERFLOW; "Stack pop would underflow stack size."
        when LibGL::OUT_OF_MEMORY; "Out of Graphics Memory."
        when LibGL::INVALID_FRAMEBUFFER_OPERATION; "Read/Write operation on an incomplete framebuffer."
        when LibGL::CONTEXT_LOST; "Graphics Context has been lost."
        else "<UNKNOWN ERROR>"
        end
      end
    end
  end
end