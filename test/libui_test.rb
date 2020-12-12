# frozen_string_literal: true

require 'test_helper'

class LibUITest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LibUI::VERSION
  end

  def test_ffi_method_call
    pt = LibUI::FFI::InitOptions.malloc
    assert_kind_of Fiddle::Pointer, LibUI::FFI.uiInit(pt)
    assert_nil LibUI::FFI.uiQuit
  end

  def test_method_call
    pt = LibUI::FFI::InitOptions.malloc
    assert_nil LibUI.init(pt)
    assert_nil LibUI.quit
  end
end
