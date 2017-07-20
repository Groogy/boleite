require "crystal-clear"
require "lib_glfw3"
require "lib_gl"
require "./boleite/*"
require "./boleite/math/*"
require "./boleite/serializers/*"
require "./boleite/serializers/backend/*"
require "./boleite/backend/*"

module Boleite
  VERSION = Version.new(0, 1, 0)
end
