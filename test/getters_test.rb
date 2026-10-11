require 'test_helper'

class GettersTest < Minitest::Test
  def test_file_dialogs_copy_paths_and_free_native_text
    ffi = LibUI::FFI
    original_free = ffi.method(:uiFreeText)
    freed = []
    ffi.singleton_class.send(:remove_method, :uiFreeText)
    ffi.define_singleton_method(:uiFreeText) { |pointer| freed << pointer }

    { open_file: :uiOpenFile, open_folder: :uiOpenFolder,
      save_file: :uiSaveFile }.each do |ruby_name, c_name|
      original_dialog = ffi.method(c_name)
      pointer = Fiddle::Pointer.malloc(16, Fiddle::RUBY_FREE)
      pointer[0, 8] = "path.rb\0"
      ffi.singleton_class.send(:remove_method, c_name)
      ffi.define_singleton_method(c_name) { |_window| pointer }

      assert_equal 'path.rb', LibUI.public_send(ruby_name, nil)
      assert_equal Encoding::UTF_8, LibUI.public_send(ruby_name, nil).encoding
      assert_equal 2, freed.count(pointer)

      ffi.singleton_class.send(:remove_method, c_name)
      ffi.define_singleton_method(c_name) { |_window| Fiddle::Pointer.new(0) }
      assert_nil LibUI.public_send(ruby_name, nil)
      assert_equal 2, freed.count(pointer)
    ensure
      if original_dialog
        ffi.singleton_class.send(:remove_method, c_name)
        ffi.define_singleton_method(c_name, original_dialog)
      end
    end
  ensure
    if original_free
      ffi.singleton_class.send(:remove_method, :uiFreeText)
      ffi.define_singleton_method(:uiFreeText, original_free)
    end
  end
end
