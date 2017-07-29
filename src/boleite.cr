require "crystal-clear"
require "lib_glfw3"
require "lib_gl"
require "./boleite/math/*"
require "./boleite/backend/*"
require "./boleite/graphics/*"
require "./boleite/input/*"
require "./boleite/*"
require "./boleite/serializers/*"
require "./boleite/serializers/backend/*"

module Boleite
  VERSION = Version.new(0, 1, 0)
end
