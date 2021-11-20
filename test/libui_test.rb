require 'test_helper'

class LibUITest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LibUI::VERSION
  end

  def test_ffi_method_call
    pt = LibUI::FFI::InitOptions.malloc
    pt.to_ptr.free = Fiddle::RUBY_FREE
    assert_kind_of Fiddle::Pointer, LibUI::FFI.uiInit(pt)
    assert_nil LibUI::FFI.uiQuit
  end

  def test_method_call
    assert_nil LibUI.init
    assert_nil LibUI.quit
  end

  def test_basic_window
    assert_nil LibUI.init
    assert_kind_of Fiddle::Pointer, (
      main_window = LibUI.new_window('hello world', 300, 200, 1)
    )
    assert_nil LibUI.control_show(main_window)
    assert_nil(
      LibUI.window_on_closing(main_window) do
        LibUI.control_destroy(main_window)
        LibUI.quit
        0
      end
    )
    # LibUI.main
    assert_nil LibUI.quit
  end
end
