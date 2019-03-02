# boleite

![Boleite](http://i.imgur.com/BKTwCEH.png)


Work In Progress Framework for developing Games in Crystal. You can view it in use at my other project [Ego](https://github.com/Groogy/ego).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  boleite:
    github: Groogy/boleite
```

You will also need to install libraries needed for the backend to work. As long as they are in PATH it will work just fine, if you are using a package manager you probably don't need to worry about it. Needed dependencies are:

* libfreetype-6
* libfreeimage-3
* libGL
* libglfw-3

## Usage

To get everything setup and started you need to create an Application and a state to push onto it's StateStack. The application is also responsible for finding the configuration the framework will be using or defining it's default values. The configuration needs to define the backend configuration data so the frameworks backend can be properly setup.

```crystal
require "boleite"

class MyConfiguration < Boleite::Configuration
  property :backend
  
  @backend = Boleite::BackendConfiguration.new

  struct Serializer
    def marshal(obj, node)
      node.marshal "backend", obj.backend
    end

    def unmarshal(node)
      config = MyConfiguration.new
      config.backend = node.unmarshal "backend", Boleite::BackendConfiguration
      config
    end
  end

  extend Boleite::Serializable(Serializer)
end

class MyApplication < Boleite::Application
  CONFIGURATION_FILE = "config.yml"
  
  def create_configuration : Boleite::Configuration
    if File.exists? CONFIGURATION_FILE
      File.open(CONFIGURATION_FILE, "r") do |file|
        serializer = Boleite::Serializer.new nil
        serializer.read(file)
        config = serializer.unmarshal(MyConfiguration)
        config.as(MyConfiguration)
      end
    else
      File.open(CONFIGURATION_FILE, "w") do |file|
        config = MyConfiguration.new 
        config.backend = @backend.default_config
        serializer = Boleite::Serializer.new nil
        serializer.marshal(config)
        serializer.dump(file)
        config
      end
    end
  end
end

SHADER_STR = "#version 330
vertex
{
  layout(location = 0) in vec4 pos;

  void main()
  {
    gl_Position = pos;
  }
}
fragment
{
  layout(location = 0) out vec4 outputAlbedo;

  void main()
  {
    outputAlbedo = vec4(1, 0, 0, 1);
  }
}"

class MyState < Boleite::State
  def initialize(@app : MyApplication)
    super()
    
    gfx = @app.graphics
    target = gfx.main_target
    shader = Boleite::Shader.load_string SHADER_STR, gfx
    @camera2d = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    @renderer = Boleite::ForwardRenderer.new gfx, @camera2d, shader
  end

  def enable
  end

  def disable
  end

  def update(delta)
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @renderer.present
  end
end

app = MyApplication.new
app.state_stack.push MyState.new(app)
app.run
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/Groogy/boleite/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Groogy](https://github.com/Groogy) Henrik Valter Vogelius Hansson - creator, maintainer
