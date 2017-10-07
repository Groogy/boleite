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
  layout(location = 1) in vec2 uv;
  layout(location = 2) in vec4 color;
  uniform mat4 world;
  uniform mat4 camera;
  uniform mat4 projection;
  out VertexData {
    vec2 uv;
    vec4 color;
  } outputVertex;
  void main()
  {
    vec4 worldPos = world * vec4(position, 0, 1);
    vec4 viewPos = camera * worldPos;
    gl_Position = projection * viewPos;
    outputVertex.uv = vec2(uv.x, 1-uv.y);
    outputVertex.color = color;
  }
}

fragment
{
  layout(location = 0) out vec4 outputColor;
  uniform sampler2D fontTexture;
  in VertexData {
    vec2 uv;
    vec4 color;
  } inputVertex;
  void main()
  {
    float mask = texture(fontTexture, inputVertex.uv).r;
    outputColor = inputVertex.color * mask;
  }
}