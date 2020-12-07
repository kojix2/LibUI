# frozen_string_literal: true

require 'test_helper'

class LibUITest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LibUI::VERSION
  end

  def test_it_does_something_useful
    pt = LibUI::FFI::InitOptions.malloc
    assert_kind_of Fiddle::Pointer, LibUI::FFI.uiInit(pt)
  end
end
