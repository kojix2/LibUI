require 'test_helper'

class LibUIUtilsTest < Minitest::Test
  def test_convert_to_ruby_method
    rbmethod1 = LibUI::Utils.convert_to_ruby_method('uiNewMatz')
    rbmethod2 = LibUI::Utils.convert_to_ruby_method('AINewMatz')
    assert_equal 'new_matz', rbmethod1
    assert_equal 'ai_new_matz', rbmethod2
  end

  def test_underscore
    assert_equal '3v3_v_ap_f2_er7s@_f_d/d_sc', LibUI::Utils.underscore('3v3VApF2Er7s@-fD::DSc')
  end
end
