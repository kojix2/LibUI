# frozen_string_literal: true

require 'fiddle/import'

module LibUI
  module FFI
    extend Fiddle::Importer

    begin
      dlload LibUI.ffi_lib
    rescue LoadError
      raise LoadError, 'Could not find libui'
    end

    typealias("uint32_t", "unsigned int")

    InitOptions = struct(['size_t size'])

    extern 'const char *uiInit(uiInitOptions *options)'
    extern 'void uiUninit(void)'
    extern 'void uiFreeInitError(const char *err)'

    extern 'void uiMain(void)'
    extern 'void uiMainSteps(void)'
    extern 'int uiMainStep(int wait)'
    extern 'void uiQuit(void)'
    extern 'void uiQueueMain(void (*f)(void *data), void *data)'
    extern 'void uiTimer(int milliseconds, int (*f)(void *data), void *data)'
    extern 'void uiOnShouldQuit(int (*f)(void *data), void *data)'
    extern 'void uiFreeText(char *text)'

    struct ['uint32_t Signature',
            'uint32_t OSSignature',
            'uint32_t TypeSignature',
            'void (*Destroy)(uiControl *)',
            'uintptr_t (*Handle)(uiControl *)',
            'uiControl *(*Parent)(uiControl *)',
            'void (*SetParent)(uiControl *, uiControl *)',
            'int (*Toplevel)(uiControl *)',
            'int (*Visible)(uiControl *)',
            'void (*Show)(uiControl *)',
            'void (*Hide)(uiControl *)',
            'int (*Enabled)(uiControl *)',
            'void (*Enable)(uiControl *)',
            'void (*Disable)(uiControl *)']
  end
end
