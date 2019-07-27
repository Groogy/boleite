class Boleite::MeshBuilder
  include CrystalClear

  ELEMENT_SIZE = 4u32

  @gfx : GraphicsContext

  def initialize(@gfx)
  end

  def build(data)
    vbo = @gfx.create_vertex_buffer_object
    vbo.layout = determine_layout data
    vbo.primitive = translate_primitive data.primitive_types
    fill_mesh vbo, data
    fill_indices vbo, data
    mesh = Mesh.new vbo
  end

  def determine_layout(data)
    elements = determine_elements data
    attributes = determine_attributes elements
    Boleite::VertexLayout.new attributes
  end

  def determine_elements(data)
    elements = [] of {Int32, Symbol}
    elements << {3, :float} unless data.vertices.null?
    elements << {3, :float} unless data.normals.null?
    elements << {3, :float} unless data.tangents.null?
    elements << {3, :float} unless data.bitangents.null?
    data.colors.each do |color|
      elements << {4, :float} unless color.null?
    end
    data.num_uv_components.each do |components|
      elements << {components.to_i, :float} if components > 0
    end
    elements
  end

  def determine_attributes(elements)
    size = elements.sum { |e| e[0].to_u32 * ELEMENT_SIZE }
    offset = 0u32
    attributes = elements.map do |element|
      count = element[0]
      type = element[1]
      attribute = Boleite::VertexAttribute.new 0, count.to_i, type, size, offset, 0u32
      offset += count * ELEMENT_SIZE
      attribute
    end
  end

  def translate_primitive(types) : Primitive
    case LibAssImp::PrimitiveType.new(types)
    when LibAssImp::PrimitiveType::POINT then Primitive::Points
    when LibAssImp::PrimitiveType::LINE then Primitive::Lines
    when LibAssImp::PrimitiveType::TRIANGLE then Primitive::Triangles
    when LibAssImp::PrimitiveType::POLYGON then raise "Polygon is unsupported, please triangulate mesh!"
    else
      raise "Multiple primitives in one mesh is not supported!"
    end
  end

  def fill_mesh(vbo, data)
    buffer = vbo.create_buffer
    vertices = Slice.new data.vertices, data.num_vertices unless data.vertices.null?
    normals  = Slice.new data.normals, data.num_vertices unless data.normals.null?
    tangents = Slice.new data.tangents, data.num_vertices unless data.tangents.null?
    bitangents = Slice.new data.bitangents, data.num_vertices unless data.bitangents.null?
    colors = data.colors.map { |c| Slice.new c, data.num_vertices unless c.null? }
    tex_coords = data.texture_coords.map { |c| Slice.new c, data.num_vertices unless c.null? }
    data.num_vertices.times do |i|
      construct_vertex buffer, i, vertices, normals, tangents, bitangents, colors, tex_coords
    end
  end

  def construct_vertex(buffer, i, vertices, normals, tangents, bitangents, colors, tex_coords)
    if vertices 
      vertices[i].tap { |v| buffer.add_data v.x, v.y, v.z }
    end
    if normals
      normals[i].tap { |v| buffer.add_data v.x, v.y, v.z }
    end
    if tangents
      tangents[i].tap { |v| buffer.add_data v.x, v.y, v.z }
    end
    if bitangents
      bitangents[i].tap { |v| buffer.add_data v.x, v.y, v.z }
    end
    colors.each do |channel|
      channel.try { |c| c[i].tap { |v| buffer.add_data v.r, v.g, v.b, v.a } }
    end
    tex_coords.each do |channel|
      channel.try { |c| c[i].tap { |v| buffer.add_data v.x, v.y } }
    end
  end
  
  def fill_indices(vbo, data)
    buffer = vbo.create_buffer
    vbo.set_indices 1
    faces = Slice.new data.faces, data.num_faces
    faces.each do |face|
      indices = Slice.new face.indices, face.num_indices
      indices.each { |i| buffer.add_data i }
    end
  end
end
