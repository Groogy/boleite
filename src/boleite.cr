require "crystal-clear"
require "lib_glfw3"
require "lib_gl"
require "cute"
require "./boleite/math/*"
require "./boleite/backend/*"
require "./boleite/graphics/*"
require "./boleite/backend/graphics/*"
require "./boleite/input/*"
require "./boleite/gui/helpers.cr"
require "./boleite/gui/*"
require "./boleite/gui/input/*"
require "./boleite/*"
require "./boleite/serializers/*"
require "./boleite/serializers/backend/*"

module Boleite
  VERSION = Version.new(0, 1, 0)
end
