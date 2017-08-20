module Boleite::Private::GLFWInput
  def self.translate_key(key)
    return case key
    when LibGLFW3::KEY_UNKNOWN; Key::Unknown
    when LibGLFW3::KEY_SPACE; Key::Space
    when LibGLFW3::KEY_APOSTROPHE; Key::Apostrophe
    when LibGLFW3::KEY_COMMA; Key::Comma
    when LibGLFW3::KEY_MINUS; Key::Minus
    when LibGLFW3::KEY_PERIOD; Key::Period
    when LibGLFW3::KEY_SLASH; Key::Slash
    when LibGLFW3::KEY_0; Key::Num0
    when LibGLFW3::KEY_1; Key::Num1
    when LibGLFW3::KEY_2; Key::Num2
    when LibGLFW3::KEY_3; Key::Num3
    when LibGLFW3::KEY_4; Key::Num4
    when LibGLFW3::KEY_5; Key::Num5
    when LibGLFW3::KEY_6; Key::Num6
    when LibGLFW3::KEY_7; Key::Num7
    when LibGLFW3::KEY_8; Key::Num8
    when LibGLFW3::KEY_9; Key::Num9
    when LibGLFW3::KEY_SEMICOLON; Key::Semicolon
    when LibGLFW3::KEY_EQUAL; Key::Equal
    when LibGLFW3::KEY_A; Key::A
    when LibGLFW3::KEY_B; Key::B
    when LibGLFW3::KEY_C; Key::C
    when LibGLFW3::KEY_D; Key::D
    when LibGLFW3::KEY_E; Key::E
    when LibGLFW3::KEY_F; Key::F
    when LibGLFW3::KEY_G; Key::G
    when LibGLFW3::KEY_H; Key::H
    when LibGLFW3::KEY_I; Key::I
    when LibGLFW3::KEY_J; Key::J
    when LibGLFW3::KEY_K; Key::K
    when LibGLFW3::KEY_L; Key::L
    when LibGLFW3::KEY_M; Key::M
    when LibGLFW3::KEY_N; Key::N
    when LibGLFW3::KEY_O; Key::O
    when LibGLFW3::KEY_P; Key::P
    when LibGLFW3::KEY_Q; Key::Q
    when LibGLFW3::KEY_R; Key::R
    when LibGLFW3::KEY_S; Key::S
    when LibGLFW3::KEY_T; Key::T
    when LibGLFW3::KEY_U; Key::U
    when LibGLFW3::KEY_V; Key::V
    when LibGLFW3::KEY_W; Key::W
    when LibGLFW3::KEY_X; Key::X
    when LibGLFW3::KEY_Y; Key::Y
    when LibGLFW3::KEY_Z; Key::Z
    when LibGLFW3::KEY_LEFT_BRACKET; Key::LeftBracket
    when LibGLFW3::KEY_BACKSLASH; Key::Backslash
    when LibGLFW3::KEY_RIGHT_BRACKET; Key::RightBracket
    when LibGLFW3::KEY_GRAVE_ACCENT; Key::GraveAccent
    when LibGLFW3::KEY_WORLD_1; Key::World1
    when LibGLFW3::KEY_WORLD_2; Key::World2
    when LibGLFW3::KEY_ESCAPE; Key::Escape
    when LibGLFW3::KEY_ENTER; Key::Enter
    when LibGLFW3::KEY_TAB; Key::Tab
    when LibGLFW3::KEY_BACKSPACE; Key::Backspace
    when LibGLFW3::KEY_INSERT; Key::Insert
    when LibGLFW3::KEY_DELETE; Key::Delete
    when LibGLFW3::KEY_RIGHT; Key::Right
    when LibGLFW3::KEY_LEFT; Key::Left
    when LibGLFW3::KEY_DOWN; Key::Down
    when LibGLFW3::KEY_UP; Key::Up
    when LibGLFW3::KEY_PAGE_UP; Key::PageUp
    when LibGLFW3::KEY_PAGE_DOWN; Key::PageDown
    when LibGLFW3::KEY_HOME; Key::Home
    when LibGLFW3::KEY_END; Key::End
    when LibGLFW3::KEY_CAPS_LOCK; Key::CapsLock
    when LibGLFW3::KEY_SCROLL_LOCK; Key::ScrollLock
    when LibGLFW3::KEY_NUM_LOCK; Key::NumLock
    when LibGLFW3::KEY_PRINT_SCREEN; Key::PrintScreen
    when LibGLFW3::KEY_PAUSE; Key::Pause
    when LibGLFW3::KEY_F1; Key::F1
    when LibGLFW3::KEY_F2; Key::F2
    when LibGLFW3::KEY_F3; Key::F3
    when LibGLFW3::KEY_F4; Key::F4
    when LibGLFW3::KEY_F5; Key::F5
    when LibGLFW3::KEY_F6; Key::F6
    when LibGLFW3::KEY_F7; Key::F7
    when LibGLFW3::KEY_F8; Key::F8
    when LibGLFW3::KEY_F9; Key::F9
    when LibGLFW3::KEY_F10; Key::F10
    when LibGLFW3::KEY_F11; Key::F11
    when LibGLFW3::KEY_F12; Key::F12
    when LibGLFW3::KEY_F13; Key::F13
    when LibGLFW3::KEY_F14; Key::F14
    when LibGLFW3::KEY_F15; Key::F15
    when LibGLFW3::KEY_F16; Key::F16
    when LibGLFW3::KEY_F17; Key::F17
    when LibGLFW3::KEY_F18; Key::F18
    when LibGLFW3::KEY_F19; Key::F19
    when LibGLFW3::KEY_F20; Key::F20
    when LibGLFW3::KEY_F21; Key::F21
    when LibGLFW3::KEY_F22; Key::F22
    when LibGLFW3::KEY_F23; Key::F23
    when LibGLFW3::KEY_F24; Key::F24
    when LibGLFW3::KEY_F25; Key::F25
    when LibGLFW3::KEY_KP_0; Key::KeyPad0
    when LibGLFW3::KEY_KP_1; Key::KeyPad1
    when LibGLFW3::KEY_KP_2; Key::KeyPad2
    when LibGLFW3::KEY_KP_3; Key::KeyPad3
    when LibGLFW3::KEY_KP_4; Key::KeyPad4
    when LibGLFW3::KEY_KP_5; Key::KeyPad5
    when LibGLFW3::KEY_KP_6; Key::KeyPad6
    when LibGLFW3::KEY_KP_7; Key::KeyPad7
    when LibGLFW3::KEY_KP_8; Key::KeyPad8
    when LibGLFW3::KEY_KP_9; Key::KeyPad9
    when LibGLFW3::KEY_KP_DECIMAL; Key::KeyPadDecimal
    when LibGLFW3::KEY_KP_DIVIDE; Key::KeyPadDivide
    when LibGLFW3::KEY_KP_MULTIPLY; Key::KeyPadMultiply
    when LibGLFW3::KEY_KP_SUBTRACT; Key::KeyPadSubtract
    when LibGLFW3::KEY_KP_ADD; Key::KeyPadAdd
    when LibGLFW3::KEY_KP_ENTER; Key::KeyPadEnter
    when LibGLFW3::KEY_KP_EQUAL; Key::KeyPadEqual
    when LibGLFW3::KEY_LEFT_SHIFT; Key::LeftShift
    when LibGLFW3::KEY_LEFT_CONTROL; Key::LeftControl
    when LibGLFW3::KEY_LEFT_ALT; Key::LeftAlt
    when LibGLFW3::KEY_LEFT_SUPER; Key::LeftSuper
    when LibGLFW3::KEY_RIGHT_SHIFT; Key::RightShift
    when LibGLFW3::KEY_RIGHT_CONTROL; Key::RightControl
    when LibGLFW3::KEY_RIGHT_ALT; Key::RightAlt
    when LibGLFW3::KEY_RIGHT_SUPER; Key::RightSuper
    when LibGLFW3::KEY_MENU; Key::Menu
    else; Key::Unknown
    end
  end

  def self.translate_mouse_button(button)
    case button
    when LibGLFW3::MOUSE_BUTTON_1; Mouse::Button1
    when LibGLFW3::MOUSE_BUTTON_2; Mouse::Button2
    when LibGLFW3::MOUSE_BUTTON_3; Mouse::Button3
    when LibGLFW3::MOUSE_BUTTON_4; Mouse::Button4
    when LibGLFW3::MOUSE_BUTTON_5; Mouse::Button5
    when LibGLFW3::MOUSE_BUTTON_6; Mouse::Button6
    when LibGLFW3::MOUSE_BUTTON_7; Mouse::Button7
    when LibGLFW3::MOUSE_BUTTON_8; Mouse::Button8
    when LibGLFW3::MOUSE_BUTTON_LAST; Mouse::Last
    when LibGLFW3::MOUSE_BUTTON_LEFT; Mouse::Left
    when LibGLFW3::MOUSE_BUTTON_RIGHT; Mouse::Right
    when LibGLFW3::MOUSE_BUTTON_MIDDLE; Mouse::Middle
    else; Mouse::Unknown
    end
  end

  def self.translate_action(action)
    case action
    when LibGLFW3::RELEASE; InputAction::Release
    when LibGLFW3::PRESS; InputAction::Press
    when LibGLFW3::REPEAT; InputAction::Repeat
    else; InputAction::Unknown
    end
  end

  def self.translate_mods(mods)
    KeyMod.new(mods)
  end
end
