# frozen_string_literal: true

require 'test_helper'

class LibuiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Libui::VERSION
  end

  def test_it_does_something_useful
    pt = Libui::FFI::InitOptions.malloc
    assert_kind_of Fiddle::Pointer, Libui::FFI.uiInit(pt)
  end
end
