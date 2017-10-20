#version 450

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
  out VertexData {
    vec2 uv;
  } outputVertex;
  void main()
  {
    vec4 pos = vec4(position, 0, 1);
    gl_Position = pos;
    outputVertex.uv = uv;
  }
}

fragment
{
  layout(location = 0) out vec4 outputColor;
  uniform sampler2D colorTexture;
  in VertexData {
    vec2 uv;
  } inputVertex;
  void main()
  {
    vec4 color = texture(colorTexture, inputVertex.uv);
    outputColor = color;
  }
}