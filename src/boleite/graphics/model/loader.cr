class Boleite::ModelLoader
  include CrystalClear

  alias Flags = LibAssImp::Process

  @gfx : GraphicsContext
  @flags : Flags = Flags::CalcTangentSpace | Flags::Triangulate | Flags::JoinIdenticalVertices | Flags::SortByPType | Flags::FlipWindingOrder | Flags::MakeLeftHanded

  property flags

  def initialize(@gfx)
  end

  def initialize(@gfx, @flags)
  end

  requires File.exists? path
  def load(path : String)
    scene = load_scene path
    meshes = build_meshes Slice.new(scene.meshes, scene.num_meshes, read_only: true)
    if scene.root_node.null?
      root = Model::Node.new
    else
      root = process_node scene.root_node.value, meshes
    end
    model = Model.new meshes, root
  end

  def get_error : String
    String.new LibAssImp.get_error_string, 1
  end

  private def load_scene(path : String)
    scene = LibAssImp.import_file path, @flags
    if scene.null? || (scene.value.flags & LibAssImp::SceneFlags::Incomplete.value) != 0
      raise "Failed to load scene of #{path} with error '#{get_error}'"
    end
    scene.value
  end

  private def build_meshes(meshes)
    builder = MeshBuilder.new @gfx
    meshes.to_a.map do |mesh|
      builder.build mesh.value
    end
  end

  private def process_node(node, meshes) : Model::Node
    mesh_indices = Slice.new node.meshes, node.num_meshes
    raw_children = Slice.new node.children, node.num_children
    node_meshes = mesh_indices.map { |index| meshes[index] }
    node_children = raw_children.map { |c| process_node(c.value, meshes).as(Model::Node) }
    node_name = String.new node.name.char.to_unsafe, node.name.length
    transformation = convert_matrix node.transformation
    Model::Node.new node_name, transformation, node_meshes.to_a, node_children.to_a
  end

  private def convert_matrix(matrix : LibAssImp::Matrix4x4)
    Matrix44f32.new(
      matrix.a[0], matrix.a[1], matrix.a[2], matrix.a[3],
      matrix.b[0], matrix.b[1], matrix.b[2], matrix.b[3],
      matrix.c[0], matrix.c[1], matrix.c[2], matrix.c[3],
      matrix.d[0], matrix.d[1], matrix.d[2], matrix.d[3]
    )
  end
end