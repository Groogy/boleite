@[Link("freetype")]
lib LibFreeType
  enum Encoding : UInt32
    NONE = 0
    
    MS_SYMBOL = 1937337698
    UNICODE   = 1970170211
  end

  enum Load
    DEFAULT                      = 0
    NO_SCALE                     = 1 <<  0
    NO_HINTING                   = 1 <<  1
    RENDER                       = 1 <<  2
    NO_BITMAP                    = 1 <<  3
    VERTICAL_LAYOUT              = 1 <<  4
    FORCE_AUTOHINT               = 1 <<  5
    CROP_BITMAP                  = 1 <<  6
    PEDANTIC                     = 1 <<  7
    IGNORE_GLOBAL_ADVANCE_WIDTH  = 1 <<  9
    NO_RECURSE                   = 1 << 10
    IGNORE_TRANSFORM             = 1 << 11
    MONOCHROME                   = 1 << 12
    LINEAR_DESIGN                = 1 << 13
    NO_AUTOHINT                  = 1 << 15
  end

  enum FaceFlag
    SCALABLE          = 1 <<  0
    FIXED_SIZES       = 1 <<  1
    FIXED_WIDTH       = 1 <<  2
    SFNT              = 1 <<  3
    HORIZONTAL        = 1 <<  4
    VERTICAL          = 1 <<  5
    KERNING           = 1 <<  6
    FAST_GLYPHS       = 1 <<  7
    MULTIPLE_MASTERS  = 1 <<  8
    GLYPH_NAMES       = 1 <<  9
    EXTERNAL_STREAM   = 1 << 10
    HINTER            = 1 << 11
    CID_KEYED         = 1 << 12
    TRICKY            = 1 << 13
    COLOR             = 1 << 14
  end

  enum Render_Mode
    NORMAL = 0
    LIGHT
    MONO
    LCD
    LCD_V
  end

  alias Error   = Int32
  alias Long    = LibC::Long
  alias ULong   = LibC::ULong
  alias Int     = LibC::Int
  alias UInt    = LibC::UInt
  alias F26Dot6 = LibC::Long
  alias Pos     = LibC::Long
  alias Fixed   = LibC::Long

  type Library    = Void*
  
  struct Bitmap
    rows : LibC::UInt
    width : LibC::UInt
    pitch : LibC::Int
    buffer : LibC::UChar*
    num_grays : LibC::UShort
    pixel_mode : LibC::UChar
    palette_mode : LibC::UChar
    palette : Void*
  end

  struct Vector
    x : Pos
    y : Pos
  end

  struct Generic
    data : Void*
    finalizer : Void*
  end

  struct SizeMetrics
    x_ppem : LibC::UShort
    y_ppem : LibC::UShort

    x_scale : Fixed
    y_scale : Fixed

    ascender    : Pos
    descender   : Pos
    height      : Pos
    max_advance : Pos
  end

  struct GlyphSlotRec
    padding1 : UInt8[128] # How far to the first member I want
    advance : Vector
    padding2 : UInt8[8]  # How far to the second member I want
    bitmap : Bitmap
    bitmap_left : Int
    bitmap_top : Int
  end
  type GlyphSlot  = GlyphSlotRec*

  struct SizeRec
    face : Face
    generic : Generic
    metrics : SizeMetrics
  end
  type Size = SizeRec*

  struct FaceRec
    padding1 : UInt8[16] # How far to the first member I want
    face_flags : Long
    padding : UInt8[128] # How far to the second member I want
    glyph : GlyphSlot
    size : Size
  end
  type Face    = FaceRec*

  Err_Ok = Error.new(0)

  fun init_FreeType = FT_Init_FreeType(library : Library*) : Error 
  fun done_FreeType = FT_Done_FreeType(library : Library) : Error

  fun new_Face        = FT_New_Face(library : Library, path : LibC::Char*, face_index : Long, face : Face*) : Error
  fun done_Face       = FT_Done_Face(face : Face) : Error
  fun select_Charmap  = FT_Select_Charmap(face : Face, encoding : Encoding) : Error

  fun set_Pixel_Sizes  = FT_Set_Pixel_Sizes(face : Face, width : UInt, height : UInt ) : Error
  fun set_Char_Size   = FT_Set_Char_Size(face : Face, width : F26Dot6, height : F26Dot6, horz_resolution : UInt, vert_resolution : UInt) : Error
  fun get_Char_Index  = FT_Get_Char_Index(face : Face, code : ULong) : UInt
  fun load_Char       = FT_Load_Char(face : Face, code : ULong, flags : Int32) : Error
  
  fun load_Glyph      = FT_Load_Glyph(face : Face, index : UInt, flags : Int32) : Error
  fun render_Glyph    = FT_Render_Glyph(glyph : GlyphSlot, render : Render_Mode ) : Error

  fun get_Kerning     = FT_Get_Kerning(face : Face, left : UInt, right : UInt, kern_mode : UInt, kerning : Vector*) : Error
end