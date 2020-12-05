require 'fiddle/import'

module Libui
  module FFI
    extend Fiddle::Importer

    begin
      dlload Libui.ffi_lib
    rescue LoadError
      raise LoadError, 'Could not find libui'
    end

    InitOptions = struct(['size_t size'])

    extern 'const char *uiInit(uiInitOptions *options)'
  end
end
