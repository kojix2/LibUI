require 'test_helper'

class FontTest < Minitest::Test
  def test_font_is_an_immutable_ruby_value
    family = +'Georgia'
    font = LibUI::Font.new(family: family, size: 13)
    family.replace('Other')

    assert_equal 'Georgia', font.family
    assert_equal 13.0, font.size
    assert_equal [400, 0, 4], [font.weight, font.italic, font.stretch]
    assert font.frozen?
    assert font.family.frozen?
    assert_raises(ArgumentError) { LibUI::Font.new(family: "bad\0name", size: 13) }
  end

  def test_font_getters_copy_and_free_native_descriptors
    family = Fiddle::Pointer.malloc(8, Fiddle::RUBY_FREE)
    family[0, 8] = "Georgia\0"
    freed = []
    fill = proc do |descriptor|
      descriptor.Family = family
      descriptor.Size = 13.5
      descriptor.Weight = 500
      descriptor.Italic = 1
      descriptor.Stretch = 4
    end

    with_ffi_stubs(
      uiLoadControlFont: fill,
      uiFontButtonFont: proc { |_button, descriptor| fill.call(descriptor) },
      uiFreeFontDescriptor: proc { |descriptor| freed << descriptor.to_ptr.to_i }
    ) do
      font = LibUI.load_control_font
      assert_equal({ family: 'Georgia', size: 13.5, weight: 500,
                     italic: 1, stretch: 4 }, font.to_h)
      assert_equal 1, freed.size

      button_font = LibUI.font_button_font(nil)
      assert_equal font, button_font
      assert_equal 2, freed.size

      raw = LibUI::FFI::FontDescriptor.malloc
      LibUI.font_button_font(nil, raw)
      assert_equal 13.5, raw.Size
      assert_equal 2, freed.size

      LibUI.load_control_font(raw)
      assert_equal 13.5, raw.Size
      assert_equal 2, freed.size
    end
  end

  def test_draw_text_layout_accepts_font_and_native_params
    captured = []
    result = Fiddle::Pointer.new(5678)
    with_ffi_stubs(uiDrawNewTextLayout: proc do |params|
      GC.start if captured.empty?
      native_font = LibUI::FFI::FontDescriptor.new(params.DefaultFont)
      captured << [params.String.to_i, native_font.Family.to_s,
                   native_font.Size, native_font.Weight,
                   native_font.Italic, native_font.Stretch,
                   params.Width, params.Align]
      result
    end) do
      string = Fiddle::Pointer.new(1234)
      font = LibUI::Font.new(family: 'Georgia', size: 13,
                              weight: 500, italic: 1, stretch: 4)
      assert_equal result, LibUI.draw_new_text_layout(string, font: font,
                                                       width: 300, align: 2)
      assert_equal [1234, 'Georgia', 13.0, 500, 1, 4, 300.0, 2], captured.pop

      raw = LibUI::FFI::DrawTextLayoutParams.malloc
      raw.String = string
      raw_font = LibUI::FFI::FontDescriptor.malloc
      raw_family = Fiddle::Pointer.malloc(8, Fiddle::RUBY_FREE)
      raw_family[0, 8] = "Georgia\0"
      raw_font.Family = raw_family
      raw.DefaultFont = raw_font
      assert_equal result, LibUI.draw_new_text_layout(raw)
      assert_equal 1234, captured.last.first
    end
  end

  private

  def with_ffi_stubs(stubs)
    ffi = LibUI::FFI
    originals = {}
    stubs.each do |name, replacement|
      originals[name] = ffi.method(name)
      ffi.singleton_class.send(:remove_method, name)
      ffi.define_singleton_method(name, &replacement)
    end
    yield
  ensure
    originals.each do |name, original|
      ffi.singleton_class.send(:remove_method, name)
      ffi.define_singleton_method(name, original)
    end
  end
end
