# frozen_string_literal: true

require_relative 'libui/version'
require_relative 'libui/utils'

module LibUI
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  lib_name = "libui.#{RbConfig::CONFIG['SOEXT']}"

  self.ffi_lib = if ENV['LIBUIDIR'] && !ENV['LIBUIDIR'].empty?
                   File.expand_path(lib_name, ENV['LIBUIDIR'])
                 else
                   File.expand_path("../vendor/#{lib_name}", __dir__)
                 end

  require_relative 'libui/ffi'
  require_relative 'libui/libui_base'

  extend LibUIBase

  class << self
    def init(opt = FFI::InitOptions.malloc)
      i = super(opt)
      return if i.size.zero?

      warn 'error'
      warn UI.free_init_error(init)
    end
  end
end
