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

vertex
{
  layout(location = 0) in vec2 position;
  layout(location = 1) in vec2 uv;
  uniform mat4 world;
  uniform mat4 camera;
  uniform mat4 projection;
  out VertexData {
    vec2 uv;
  } outputVertex;
  void main()
  {
    vec4 worldPos = world * vec4(position, 0, 1);
    vec4 viewPos = camera * worldPos;
    gl_Position = projection * viewPos;
    outputVertex.uv = vec2(uv.x, 1-uv.y);
  }
}

fragment
{
  layout(location = 0) out vec4 outputColor;
  uniform sampler2D colorTexture;
  uniform vec4 modulateColor;
  in VertexData {
    vec2 uv;
  } inputVertex;
  void main()
  {
    vec4 color = texture(colorTexture, inputVertex.uv);
    outputColor = color * modulateColor;
  }
}