@[Link("assimp")]
lib LibAssImp
  MAXLEN = 1024
  MAX_NUMBER_OF_COLOR_SETS = 0x8
  MAX_NUMBER_OF_TEXTURECOORDS = 0x8
  HINTMAXTEXTURELEN = 9

  type Real = Float32
  type Int = Int32
  type UInt = UInt32

  struct String
    length : LibC::ULong
    char : LibC::Char[MAXLEN]
  end

  enum MetadataType
    BOOL = 0
    INT32 = 1
    UINT64 = 2
    FLOAT = 3
    DOUBLE = 4
    AISTRING = 5
    AIVECTOR3D = 6
    META_MAX = 7
  end

  enum PrimitiveType
    POINT = 0x1
    LINE = 0x2
    TRIANGLE = 0x4
    POLYGON = 0x8
  end

  enum MorphingMethod
    VERTEX_BLEND = 0x1
    MORPH_NORMALIZED = 0x2
    MORPH_RELATIVE = 0x3
  end

  enum TextureOp
    Multiply = 0x0
    Add = 0x1
    Subtract = 0x2
    Divide = 0x3
    SmoothAdd = 0x4
    SignedAdd = 0x5
  end

  enum TextureMapMode
    Wrap = 0x0
    Clamp = 0x1
    Decal = 0x3
    Mirror = 0x2
  end

  enum TextureMapping
    UV = 0x0
    SPHERE = 0x1
    CYLINDER = 0x2
    BOX = 0x3
    PLANE = 0x4
    OTHER = 0x5
  end

  enum TextureType
    NONE = 0x0
    DIFFUSE = 0x1
    SPECULAR = 0x2
    AMBIENT = 0x3
    EMISSIVE = 0x4
    HEIGHT = 0x5
    NORMALS = 0x6
    SHININESS = 0x7
    OPACITY = 0x8
    DISPLACEMENT = 0x9
    LIGHTMAP = 0xA
    REFLECTION = 0xB
    UNKNOWN = 0xC
  end

  enum ShadingMode
    Flat = 0x1
    Gouraud = 0x2
    Phong = 0x3
    Blinn = 0x4
    Toon = 0x5
    OrenNayar = 0x6
    Minnaert = 0x7
    Cooktorrance = 0x8
    NoShading = 0x9
    Fresnel = 0xA
  end

  enum TextureFlags
    Invert = 0x1
    UseAlpha = 0x2
    IgnoreAlpha = 0x4
  end

  enum BlendMode
    Default = 0x0
    Additive = 0x1
  end

  enum PropertyTypeInfo
    Float = 0x1
    Double = 0x2
    String = 0x3
    Integer = 0x4
    Buffer = 0x5
  end

  enum AnimBehaviour
    DEFAULT = 0x0
    CONSTANT = 0x1
    LINEAR = 0x2
    REPEAT = 0x3
  end

  enum LightSourceType
    UNDEFINED = 0x0
    DIRECTIONAL = 0x1
    POINT = 0x2
    SPOT = 0x3
    AMBIENT = 0x4
    AREA = 0x5
  end

  struct MetadataEntry
    type : MetadataType
    data : Void*
  end

  struct Metadata
    num_properties : LibC::UInt
    keys : String*
    values : MetadataEntry*
  end

  struct Matrix4x4
    a : Real[4]
    b : Real[4]
    c : Real[4]
    d : Real[4]
  end

  struct Quaternion
    w : Real
    x : Real
    y : Real
    z : Real
  end

  struct Vector2D
    x : Real
    y : Real
  end

  struct Vector3D
    x : Real
    y : Real
    z : Real
  end

  struct Color3D
    r : Real
    g : Real
    b : Real
  end

  struct Color4D
    r : Real
    g : Real
    b : Real
    a : Real
  end

  struct Texel
    b : LibC::UChar
    g : LibC::UChar
    r : LibC::UChar
    a : LibC::UChar
  end

  struct Texture
    width : LibC::UInt
    height : LibC::UInt
    format_hint : LibC::Char[HINTMAXTEXTURELEN]
    data : Texel*
    filename : String
  end

  struct Light
    name : String
    type : LightSourceType
    position : Vector3D
    direction : Vector3D
    up : Vector3D
    attenuation_constant : LibC::Float
    attenuation_linear : LibC::Float
    attenuation_quadratic : LibC::Float
    color_diffuse : Color3D
    color_specular : Color3D
    color_ambient : Color3D
    angle_inner_cone : LibC::Float
    angle_outer_cone : LibC::Float
    size : Vector2D
  end

  struct Camera
    name : String
    position : Vector3D
    up : Vector3D
    look_at : Vector3D
    horizontal_fov : LibC::Float
    clip_plane_near : LibC::Float
    clip_plane_far : LibC::Float
    aspect : LibC::Float
  end

  struct UVTransform
    translation : Vector2D
    scaling : Vector2D
    rotation : Real
  end

  struct MaterialProperty
    key : String
    semantic : LibC::UInt
    index : LibC::UInt
    data_length : LibC::UInt
    type : PropertyTypeInfo
    data : LibC::Char
  end

  struct Material
    properties : MaterialProperty**
    num_properties : LibC::UInt
    num_allocated : LibC::UInt
  end

  struct VectorKey
    time : LibC::Double
    value : Vector3D
  end

  struct QuatKey
    time : LibC::Double
    value : Quaternion
  end

  struct MeshKey
    time : LibC::Double
    value : LibC::UInt
  end

  struct MeshMorphKey
    time : LibC::Double
    values : LibC::UInt*
    weights : LibC::Double*
    num_values_and_weights : LibC::UInt
  end

  struct NodeAnim
    node_name : String
    num_position_keys : LibC::UInt
    position_keys : VectorKey*
    num_rotation_keys : LibC::UInt
    rotation_keys : QuatKey*
    num_scaling_keys : LibC::UInt
    scaling_keys : VectorKey*
    pre_state : AnimBehaviour
    post_state : AnimBehaviour
  end

  struct MeshAnim
    name : String
    num_keys : LibC::UInt
    keys : MeshKey*
  end

  struct MeshMorphAnim
    name : String
    num_keys : LibC::UInt
    keys : MeshMorphKey*
  end

  struct Animation
    name : String
    duration : LibC::Double
    ticks_per_second : LibC::Double
    num_channels : LibC::UInt
    channels : NodeAnim**
    num_mesh_channels : LibC::UInt
    mesh_channels : MeshAnim**
    num_morph_mesh_channels : LibC::UInt
    morph_mesh_channels : MeshMorphAnim**
  end

  struct Face
    num_indices : LibC::UInt
    indices : LibC::UInt*
  end

  struct VertexWeight
    vertex_id : LibC::UInt
    weight : LibC::Float
  end

  struct Bone
    name : String
    num_weights : LibC::UInt
    weights : VertexWeight*
    offset_matrix : Matrix4x4
  end

  struct AnimMesh
    name : String
    vertices : Vector3D*
    normals : Vector3D*
    tangents : Vector3D*
    bitangents : Vector3D*
    colors : Color4D*[MAX_NUMBER_OF_COLOR_SETS]
    texture_coords : Vector3D*[MAX_NUMBER_OF_TEXTURECOORDS]
    num_vertices : LibC::UInt
    weight : LibC::Float
  end

  struct Mesh
    primitive_types : LibC::UInt
    num_vertices : LibC::UInt
    num_faces : LibC::UInt
    vertices : Vector3D*
    normals : Vector3D*
    tangents : Vector3D*
    bitangents : Vector3D*
    colors : Color4D*[MAX_NUMBER_OF_COLOR_SETS]
    texture_coords : Vector3D*[MAX_NUMBER_OF_TEXTURECOORDS]
    num_uv_components : LibC::UInt[MAX_NUMBER_OF_TEXTURECOORDS]
    faces : Face*
    num_bones : LibC::UInt
    bones : Bone**
    material_index : LibC::UInt
    name : String
    num_anim_meshes : LibC::UInt
    anim_meshes : AnimMesh**
    method : LibC::UInt
  end

  struct Node
    name : String
    transformation : Matrix4x4
    parent : Node*
    num_children : LibC::UInt
    children : Node**
    num_meshes : LibC::UInt
    meshes : LibC::UInt*
    metadata : Metadata*
  end

  struct Scene
    flags : LibC::UInt
    root_node : Node*
    num_meshes : LibC::UInt
    meshes : Mesh**
    num_materials : LibC::UInt
    materials : Material**
    num_animations : LibC::UInt
    animations : Animation**
    num_textures : LibC::UInt
    textures : Texture**
    num_lights : LibC::UInt
    lights : Light**
    num_cameras : LibC::UInt
    cameras : Camera**
    metadata : Metadata*
  end

  @[Flags]
  enum Process : UInt32
    CalcTangentSpace
    JoinIdenticalVertices
    MakeLeftHanded 
    Triangulate
    RemoveComponent
    GenNormals
    GenSmoothNormals
    SplitLargeMeshes
    PreTransformVertices
    LimitBoneWeights
    ValidateDataStructure
    ImproveCacheLocality
    RemoveRedundantMaterials
    FixInfacingNormals
    SortByPType
    FindDegenerates
    FindInvalidData
    GenUVCoords
    TransformUVCoords
    FindInstances
    OptimizeMeshes
    OptimizeGraph
    FlipUVs
    FlipWindingOrder
    SplitByBoneCount
    Debone
  end

  fun import_file = aiImportFile(file : LibC::Char*, flags : UInt32) : Scene*
  fun release_import = aiReleaseImport( scene : Scene* ) : Void

  fun get_error_string = aiGetErrorString() : LibC::Char*
end