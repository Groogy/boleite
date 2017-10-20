#version 450
values
{
  worldTransform = world;
  viewTransform = camera;
  projectionTransform = projection;
}

depth
{
  enabled = false;
  function = Always;
}

blend
{
  enabled = true;
  function = Add;
  sourceFactor = SourceAlpha;
  destinationFactor = OneMinusSourceAlpha;
}

vertex
{
  layout(location = 0) in vec2 position;
  uniform mat4 world;
  uniform mat4 camera;
  uniform mat4 projection;
  void main()
  {
    vec4 worldPos = world * vec4(position, 0, 1);
    vec4 viewPos = camera * worldPos;
    gl_Position = projection * viewPos;
    //gl_Position = viewPos;
  }
}

fragment
{
  layout(location = 0) out vec4 outputColor;
  uniform vec4 color;
  void main()
  {
    outputColor = color;
  }
}
