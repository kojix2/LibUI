require 'test_helper'

class GettersTest < Minitest::Test
  def test_date_time_picker_time_returns_a_ruby_time
    with_ffi_stub(:uiDateTimePickerTime, proc do |_picker, tm|
      tm.tm_year = 124
      tm.tm_mon = 1
      tm.tm_mday = 29
      tm.tm_hour = 12
      tm.tm_min = 34
      tm.tm_sec = 56
      tm.tm_isdst = -1
    end) do
      actual = LibUI.date_time_picker_time(nil)
      assert_instance_of Time, actual
      assert_equal [2024, 2, 29, 12, 34, 56],
                   [actual.year, actual.month, actual.day,
                    actual.hour, actual.min, actual.sec]
    end
  end

  def test_date_time_picker_set_time_accepts_ruby_date_values
    captured = nil
    with_ffi_stub(:uiDateTimePickerSetTime, proc do |_picker, tm|
      captured = [tm.tm_year, tm.tm_mon, tm.tm_mday,
                  tm.tm_hour, tm.tm_min, tm.tm_sec,
                  tm.tm_wday, tm.tm_yday, tm.tm_isdst]
    end) do
      value = Time.utc(2024, 5, 6, 7, 8, 9)
      LibUI.date_time_picker_set_time(nil, value)
      local = value.getlocal
      assert_equal [local.year - 1900, local.month - 1, local.day,
                    local.hour, local.min, local.sec,
                    local.wday, local.yday - 1,
                    Fiddle::WINDOWS ? -1 : (local.dst? ? 1 : 0)], captured

      LibUI.date_time_picker_set_time(nil, Date.new(2024, 2, 29))
      assert_equal [124, 1, 29, 0, 0, 0], captured.first(6)

      date_time = DateTime.iso8601('2025-01-03T10:11:12+09:00')
      LibUI.date_time_picker_set_time(nil, date_time)
      local = date_time.to_time.getlocal
      assert_equal [local.year - 1900, local.month - 1, local.day,
                    local.hour, local.min, local.sec], captured.first(6)

      assert_raises(TypeError) { LibUI.date_time_picker_set_time(nil, '2024-02-29') }
    end
  end

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

  private

  def with_ffi_stub(name, replacement)
    ffi = LibUI::FFI
    original = ffi.method(name)
    ffi.singleton_class.send(:remove_method, name)
    ffi.define_singleton_method(name, &replacement)
    yield
  ensure
    if original
      ffi.singleton_class.send(:remove_method, name)
      ffi.define_singleton_method(name, original)
    end
  end
end
