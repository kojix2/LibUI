# frozen_string_literal: true

require 'fiddle/import'

module LibUI
  module FFI
    extend Fiddle::Importer

    begin
      dlload LibUI.ffi_lib
    rescue LoadError
      raise LoadError, 'Could not find libui shared library'
    end

    class << self
      attr_reader :ffi_methods

      # Improved extern method.
      # 1. Ignore functions that cannot be attached.
      # 2. Available function (names) are stored in @ffi_methods.
      def try_extern(signature, *opts)
        @ffi_methods ||= []
        begin
          func = extern(signature, *opts)
          @ffi_methods << func.name
          func
        rescue StandardError => e
          warn "#{e.class.name}: #{e.message}"
        end
      end
    end

    typealias('uint32_t', 'unsigned int')

    InitOptions = struct(['size_t size'])

    try_extern 'const char *uiInit(uiInitOptions *options)'
    try_extern 'void uiUninit(void)'
    try_extern 'void uiFreeInitError(const char *err)'

    try_extern 'void uiMain(void)'
    try_extern 'void uiMainSteps(void)'
    try_extern 'int uiMainStep(int wait)'
    try_extern 'void uiQuit(void)'
    try_extern 'void uiQueueMain(void (*f)(void *data), void *data)'
    try_extern 'void uiTimer(int milliseconds, int (*f)(void *data), void *data)'
    try_extern 'void uiOnShouldQuit(int (*f)(void *data), void *data)'
    try_extern 'void uiFreeText(char *text)'

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

    try_extern 'void uiControlDestroy(uiControl *)'
    try_extern 'uintptr_t uiControlHandle(uiControl *)'
    try_extern 'uiControl *uiControlParent(uiControl *)'
    try_extern 'void uiControlSetParent(uiControl *, uiControl *)'
    try_extern 'int uiControlToplevel(uiControl *)'
    try_extern 'int uiControlVisible(uiControl *)'
    try_extern 'void uiControlShow(uiControl *)'
    try_extern 'void uiControlHide(uiControl *)'
    try_extern 'int uiControlEnabled(uiControl *)'
    try_extern 'void uiControlEnable(uiControl *)'
    try_extern 'void uiControlDisable(uiControl *)'

    try_extern 'uiControl *uiAllocControl(size_t n, uint32_t OSsig, uint32_t typesig, const char *typenamestr)'
    try_extern 'void uiFreeControl(uiControl *)'

    try_extern 'void uiControlVerifySetParent(uiControl *, uiControl *)'
    try_extern 'int uiControlEnabledToUser(uiControl *)'

    try_extern 'void uiUserBugCannotSetParentOnToplevel(const char *type)'

    # uiWindow
    try_extern 'char *uiWindowTitle(uiWindow *w)'
    try_extern 'void uiWindowSetTitle(uiWindow *w, const char *title)'
    try_extern 'void uiWindowContentSize(uiWindow *w, int *width, int *height)'
    try_extern 'void uiWindowSetContentSize(uiWindow *w, int width, int height)'
    try_extern 'int uiWindowFullscreen(uiWindow *w)'
    try_extern 'void uiWindowSetFullscreen(uiWindow *w, int fullscreen)'
    try_extern 'void uiWindowOnContentSizeChanged(uiWindow *w, void (*f)(uiWindow *, void *), void *data)'
    try_extern 'void uiWindowOnClosing(uiWindow *w, int (*f)(uiWindow *w, void *data), void *data)'
    try_extern 'int uiWindowBorderless(uiWindow *w)'
    try_extern 'void uiWindowSetBorderless(uiWindow *w, int borderless)'
    try_extern 'void uiWindowSetChild(uiWindow *w, uiControl *child)'
    try_extern 'int uiWindowMargined(uiWindow *w)'
    try_extern 'void uiWindowSetMargined(uiWindow *w, int margined)'
    try_extern 'uiWindow *uiNewWindow(const char *title, int width, int height, int hasMenubar)'

    # uiButton
    try_extern 'char *uiButtonText(uiButton *b)'
    try_extern 'void uiButtonSetText(uiButton *b, const char *text)'
    try_extern 'void uiButtonOnClicked(uiButton *b, void (*f)(uiButton *b, void *data), void *data)'
    try_extern 'uiButton *uiNewButton(const char *text)'

    # uiBox
    try_extern 'void uiBoxAppend(uiBox *b, uiControl *child, int stretchy)'
    try_extern 'void uiBoxDelete(uiBox *b, int index)'
    try_extern 'int uiBoxPadded(uiBox *b)'
    try_extern 'void uiBoxSetPadded(uiBox *b, int padded)'
    try_extern 'uiBox *uiNewHorizontalBox(void)'
    try_extern 'uiBox *uiNewVerticalBox(void)'

    # uiCheckbox
    try_extern 'char *uiCheckboxText(uiCheckbox *c)'
    try_extern 'void uiCheckboxSetText(uiCheckbox *c, const char *text)'
    try_extern 'void uiCheckboxOnToggled(uiCheckbox *c, void (*f)(uiCheckbox *c, void *data), void *data)'
    try_extern 'int uiCheckboxChecked(uiCheckbox *c)'
    try_extern 'void uiCheckboxSetChecked(uiCheckbox *c, int checked)'
    try_extern 'uiCheckbox *uiNewCheckbox(const char *text)'

    # uiEntry
    try_extern 'char *uiEntryText(uiEntry *e)'
    try_extern 'void uiEntrySetText(uiEntry *e, const char *text)'
    try_extern 'void uiEntryOnChanged(uiEntry *e, void (*f)(uiEntry *e, void *data), void *data)'
    try_extern 'int uiEntryReadOnly(uiEntry *e)'
    try_extern 'void uiEntrySetReadOnly(uiEntry *e, int readonly)'
    try_extern 'uiEntry *uiNewEntry(void)'
    try_extern 'uiEntry *uiNewPasswordEntry(void)'
    try_extern 'uiEntry *uiNewSearchEntry(void)'

    # uiLabel
    try_extern 'char *uiLabelText(uiLabel *l)'
    try_extern 'void uiLabelSetText(uiLabel *l, const char *text)'
    try_extern 'uiLabel *uiNewLabel(const char *text)'

    # uiTab
    try_extern 'void uiTabAppend(uiTab *t, const char *name, uiControl *c)'
    try_extern 'void uiTabInsertAt(uiTab *t, const char *name, int before, uiControl *c)'
    try_extern 'void uiTabDelete(uiTab *t, int index)'
    try_extern 'int uiTabNumPages(uiTab *t)'
    try_extern 'int uiTabMargined(uiTab *t, int page)'
    try_extern 'void uiTabSetMargined(uiTab *t, int page, int margined)'
    try_extern 'uiTab *uiNewTab(void)'

    # uiGroup
    try_extern 'char *uiGroupTitle(uiGroup *g)'
    try_extern 'void uiGroupSetTitle(uiGroup *g, const char *title)'
    try_extern 'void uiGroupSetChild(uiGroup *g, uiControl *c)'
    try_extern 'int uiGroupMargined(uiGroup *g)'
    try_extern 'void uiGroupSetMargined(uiGroup *g, int margined)'
    try_extern 'uiGroup *uiNewGroup(const char *title)'

    # uiSpinbox
    try_extern 'int uiSpinboxValue(uiSpinbox *s)'
    try_extern 'void uiSpinboxSetValue(uiSpinbox *s, int value)'
    try_extern 'void uiSpinboxOnChanged(uiSpinbox *s, void (*f)(uiSpinbox *s, void *data), void *data)'
    try_extern 'uiSpinbox *uiNewSpinbox(int min, int max)'

    # uiSlider
    try_extern 'int uiSliderValue(uiSlider *s)'
    try_extern 'void uiSliderSetValue(uiSlider *s, int value)'
    try_extern 'void uiSliderOnChanged(uiSlider *s, void (*f)(uiSlider *s, void *data), void *data)'
    try_extern 'uiSlider *uiNewSlider(int min, int max)'

    # uiProgressBar
    try_extern 'int uiProgressBarValue(uiProgressBar *p)'
    try_extern 'void uiProgressBarSetValue(uiProgressBar *p, int n)'
    try_extern 'uiProgressBar *uiNewProgressBar(void)'

    # uiSeparator
    try_extern 'uiSeparator *uiNewHorizontalSeparator(void)'
    try_extern 'uiSeparator *uiNewVerticalSeparator(void)'

    # uiCombobox
    try_extern 'void uiComboboxAppend(uiCombobox *c, const char *text)'
    try_extern 'int uiComboboxSelected(uiCombobox *c)'
    try_extern 'void uiComboboxSetSelected(uiCombobox *c, int n)'
    try_extern 'void uiComboboxOnSelected(uiCombobox *c, void (*f)(uiCombobox *c, void *data), void *data)'
    try_extern 'uiCombobox *uiNewCombobox(void)'

    # uiEditableCombobox
    try_extern 'void uiEditableComboboxAppend(uiEditableCombobox *c, const char *text)'
    try_extern 'char *uiEditableComboboxText(uiEditableCombobox *c)'
    try_extern 'void uiEditableComboboxSetText(uiEditableCombobox *c, const char *text)'
    try_extern 'void uiEditableComboboxOnChanged(uiEditableCombobox *c, void (*f)(uiEditableCombobox *c, void *data), void *data)'
    try_extern 'uiEditableCombobox *uiNewEditableCombobox(void)'

    # uiRadioButtons
    try_extern 'void uiRadioButtonsAppend(uiRadioButtons *r, const char *text)'
    try_extern 'int uiRadioButtonsSelected(uiRadioButtons *r)'
    try_extern 'void uiRadioButtonsSetSelected(uiRadioButtons *r, int n)'
    try_extern 'void uiRadioButtonsOnSelected(uiRadioButtons *r, void (*f)(uiRadioButtons *, void *), void *data)'
    try_extern 'uiRadioButtons *uiNewRadioButtons(void)'

    # uiDataTimePicker
    try_extern 'void uiDateTimePickerTime(uiDateTimePicker *d, struct tm *time)'
    try_extern 'void uiDateTimePickerSetTime(uiDateTimePicker *d, const struct tm *time)'
    try_extern 'void uiDateTimePickerOnChanged(uiDateTimePicker *d, void (*f)(uiDateTimePicker *, void *), void *data)'
    try_extern 'uiDateTimePicker *uiNewDateTimePicker(void)'
    try_extern 'uiDateTimePicker *uiNewDatePicker(void)'
    try_extern 'uiDateTimePicker *uiNewTimePicker(void)'

    # uiMultilineEntry
    try_extern 'char *uiMultilineEntryText(uiMultilineEntry *e)'
    try_extern 'void uiMultilineEntrySetText(uiMultilineEntry *e, const char *text)'
    try_extern 'void uiMultilineEntryAppend(uiMultilineEntry *e, const char *text)'
    try_extern 'void uiMultilineEntryOnChanged(uiMultilineEntry *e, void (*f)(uiMultilineEntry *e, void *data), void *data)'
    try_extern 'int uiMultilineEntryReadOnly(uiMultilineEntry *e)'
    try_extern 'void uiMultilineEntrySetReadOnly(uiMultilineEntry *e, int readonly)'
    try_extern 'uiMultilineEntry *uiNewMultilineEntry(void)'
    try_extern 'uiMultilineEntry *uiNewNonWrappingMultilineEntry(void)'

    # uiMenuItem
    try_extern 'void uiMenuItemEnable(uiMenuItem *m)'
    try_extern 'void uiMenuItemDisable(uiMenuItem *m)'
    try_extern 'void uiMenuItemOnClicked(uiMenuItem *m, void (*f)(uiMenuItem *sender, uiWindow *window, void *data), void *data)'
    try_extern 'int uiMenuItemChecked(uiMenuItem *m)'
    try_extern 'void uiMenuItemSetChecked(uiMenuItem *m, int checked)'

    # uiMenu
    try_extern 'uiMenuItem *uiMenuAppendItem(uiMenu *m, const char *name)'
    try_extern 'uiMenuItem *uiMenuAppendCheckItem(uiMenu *m, const char *name)'
    try_extern 'uiMenuItem *uiMenuAppendQuitItem(uiMenu *m)'
    try_extern 'uiMenuItem *uiMenuAppendPreferencesItem(uiMenu *m)'
    try_extern 'uiMenuItem *uiMenuAppendAboutItem(uiMenu *m)'
    try_extern 'void uiMenuAppendSeparator(uiMenu *m)'
    try_extern 'uiMenu *uiNewMenu(const char *name)'

    try_extern 'char *uiOpenFile(uiWindow *parent)'
    try_extern 'char *uiSaveFile(uiWindow *parent)'
    try_extern 'void uiMsgBox(uiWindow *parent, const char *title, const char *description)'
    try_extern 'void uiMsgBoxError(uiWindow *parent, const char *title, const char *description)'

    # uiArea
    try_extern 'void uiAreaSetSize(uiArea *a, int width, int height)'
    try_extern 'void uiAreaQueueRedrawAll(uiArea *a)'
    try_extern 'void uiAreaScrollTo(uiArea *a, double x, double y, double width, double height)'
    try_extern 'void uiAreaBeginUserWindowMove(uiArea *a)'
    typealias 'uiWindowResizeEdge', 'char' # FIXME: uint8
    try_extern 'void uiAreaBeginUserWindowResize(uiArea *a, uiWindowResizeEdge edge)'
    try_extern 'uiArea *uiNewArea(uiAreaHandler *ah)'
    try_extern 'uiArea *uiNewScrollingArea(uiAreaHandler *ah, int width, int height)'

    # uiFontButton
    try_extern 'void uiFontButtonFont(uiFontButton *b, uiFontDescriptor *desc)'
    try_extern 'void uiFontButtonOnChanged(uiFontButton *b, void (*f)(uiFontButton *, void *), void *data)'
    try_extern 'uiFontButton *uiNewFontButton(void)'
    try_extern 'void uiFreeFontButtonFont(uiFontDescriptor *desc)'

    # uiColorButton
    try_extern 'void uiColorButtonColor(uiColorButton *b, double *r, double *g, double *bl, double *a)'
    try_extern 'void uiColorButtonSetColor(uiColorButton *b, double r, double g, double bl, double a)'
    try_extern 'void uiColorButtonOnChanged(uiColorButton *b, void (*f)(uiColorButton *, void *), void *data)'
    try_extern 'uiColorButton *uiNewColorButton(void)'
  end
end
