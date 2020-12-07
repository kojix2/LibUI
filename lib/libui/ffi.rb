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
    
    extern 'void uiControlDestroy(uiControl *)'
    extern 'uintptr_t uiControlHandle(uiControl *)'
    extern 'uiControl *uiControlParent(uiControl *)'
    extern 'void uiControlSetParent(uiControl *, uiControl *)'
    extern 'int uiControlToplevel(uiControl *)'
    extern 'int uiControlVisible(uiControl *)'
    extern 'void uiControlShow(uiControl *)'
    extern 'void uiControlHide(uiControl *)'
    extern 'int uiControlEnabled(uiControl *)'
    extern 'void uiControlEnable(uiControl *)'
    extern 'void uiControlDisable(uiControl *)'
    
    extern 'uiControl *uiAllocControl(size_t n, uint32_t OSsig, uint32_t typesig, const char *typenamestr)'
    extern 'void uiFreeControl(uiControl *)'
    
    extern 'void uiControlVerifySetParent(uiControl *, uiControl *)'
    extern 'int uiControlEnabledToUser(uiControl *)'
    
    extern 'void uiUserBugCannotSetParentOnToplevel(const char *type)' 

    # uiWindow
    extern 'char *uiWindowTitle(uiWindow *w)'
    extern 'void uiWindowSetTitle(uiWindow *w, const char *title)'
    extern 'void uiWindowContentSize(uiWindow *w, int *width, int *height)'
    extern 'void uiWindowSetContentSize(uiWindow *w, int width, int height)'
    extern 'int uiWindowFullscreen(uiWindow *w)'
    extern 'void uiWindowSetFullscreen(uiWindow *w, int fullscreen)'
    extern 'void uiWindowOnContentSizeChanged(uiWindow *w, void (*f)(uiWindow *, void *), void *data)'
    extern 'void uiWindowOnClosing(uiWindow *w, int (*f)(uiWindow *w, void *data), void *data)'
    extern 'int uiWindowBorderless(uiWindow *w)'
    extern 'void uiWindowSetBorderless(uiWindow *w, int borderless)'
    extern 'void uiWindowSetChild(uiWindow *w, uiControl *child)'
    extern 'int uiWindowMargined(uiWindow *w)'
    extern 'void uiWindowSetMargined(uiWindow *w, int margined)'
    extern 'uiWindow *uiNewWindow(const char *title, int width, int height, int hasMenubar)'
    
    # uiButton
    extern 'char *uiButtonText(uiButton *b)'
    extern 'void uiButtonSetText(uiButton *b, const char *text)'
    extern 'void uiButtonOnClicked(uiButton *b, void (*f)(uiButton *b, void *data), void *data)'
    extern 'uiButton *uiNewButton(const char *text)'
    
    # uiBox
    extern 'void uiBoxAppend(uiBox *b, uiControl *child, int stretchy)'
    extern 'void uiBoxDelete(uiBox *b, int index)'
    extern 'int uiBoxPadded(uiBox *b)'
    extern 'void uiBoxSetPadded(uiBox *b, int padded)'
    extern 'uiBox *uiNewHorizontalBox(void)'
    extern 'uiBox *uiNewVerticalBox(void)'
    
    # uiCheckbox
    extern 'char *uiCheckboxText(uiCheckbox *c)'
    extern 'void uiCheckboxSetText(uiCheckbox *c, const char *text)'
    extern 'void uiCheckboxOnToggled(uiCheckbox *c, void (*f)(uiCheckbox *c, void *data), void *data)'
    extern 'int uiCheckboxChecked(uiCheckbox *c)'
    extern 'void uiCheckboxSetChecked(uiCheckbox *c, int checked)'
    extern 'uiCheckbox *uiNewCheckbox(const char *text)'
    
    # uiEntry
    extern 'char *uiEntryText(uiEntry *e)'
    extern 'void uiEntrySetText(uiEntry *e, const char *text)'
    extern 'void uiEntryOnChanged(uiEntry *e, void (*f)(uiEntry *e, void *data), void *data)'
    extern 'int uiEntryReadOnly(uiEntry *e)'
    extern 'void uiEntrySetReadOnly(uiEntry *e, int readonly)'
    extern 'uiEntry *uiNewEntry(void)'
    extern 'uiEntry *uiNewPasswordEntry(void)'
    extern 'uiEntry *uiNewSearchEntry(void)'
    
    # uiLabel
    extern 'char *uiLabelText(uiLabel *l)'
    extern 'void uiLabelSetText(uiLabel *l, const char *text)'
    extern 'uiLabel *uiNewLabel(const char *text)'
    
    # uiTab
    extern 'void uiTabAppend(uiTab *t, const char *name, uiControl *c)'
    extern 'void uiTabInsertAt(uiTab *t, const char *name, int before, uiControl *c)'
    extern 'void uiTabDelete(uiTab *t, int index)'
    extern 'int uiTabNumPages(uiTab *t)'
    extern 'int uiTabMargined(uiTab *t, int page)'
    extern 'void uiTabSetMargined(uiTab *t, int page, int margined)'
    extern 'uiTab *uiNewTab(void)'
    
    # uiGroup
    extern 'char *uiGroupTitle(uiGroup *g)'
    extern 'void uiGroupSetTitle(uiGroup *g, const char *title)'
    extern 'void uiGroupSetChild(uiGroup *g, uiControl *c)'
    extern 'int uiGroupMargined(uiGroup *g)'
    extern 'void uiGroupSetMargined(uiGroup *g, int margined)'
    extern 'uiGroup *uiNewGroup(const char *title)'
    
    # uiSpinbox
    extern 'int uiSpinboxValue(uiSpinbox *s)'
    extern 'void uiSpinboxSetValue(uiSpinbox *s, int value)'
    extern 'void uiSpinboxOnChanged(uiSpinbox *s, void (*f)(uiSpinbox *s, void *data), void *data)'
    extern 'uiSpinbox *uiNewSpinbox(int min, int max)'
    
    # uiSlider
    extern 'int uiSliderValue(uiSlider *s)'
    extern 'void uiSliderSetValue(uiSlider *s, int value)'
    extern 'void uiSliderOnChanged(uiSlider *s, void (*f)(uiSlider *s, void *data), void *data)'
    extern 'uiSlider *uiNewSlider(int min, int max)'
    
    # uiProgressBar
    extern 'int uiProgressBarValue(uiProgressBar *p)'
    extern 'void uiProgressBarSetValue(uiProgressBar *p, int n)'
    extern 'uiProgressBar *uiNewProgressBar(void)'
    
    # uiSeparator
    extern 'uiSeparator *uiNewHorizontalSeparator(void)'
    extern 'uiSeparator *uiNewVerticalSeparator(void)'
    
    # uiCombobox
    extern 'void uiComboboxAppend(uiCombobox *c, const char *text)'
    extern 'int uiComboboxSelected(uiCombobox *c)'
    extern 'void uiComboboxSetSelected(uiCombobox *c, int n)'
    extern 'void uiComboboxOnSelected(uiCombobox *c, void (*f)(uiCombobox *c, void *data), void *data)'
    extern 'uiCombobox *uiNewCombobox(void)'
    
    # uiEditableCombobox
    extern 'void uiEditableComboboxAppend(uiEditableCombobox *c, const char *text)'
    extern 'char *uiEditableComboboxText(uiEditableCombobox *c)'
    extern 'void uiEditableComboboxSetText(uiEditableCombobox *c, const char *text)'
    extern 'void uiEditableComboboxOnChanged(uiEditableCombobox *c, void (*f)(uiEditableCombobox *c, void *data), void *data)'
    extern 'uiEditableCombobox *uiNewEditableCombobox(void)'
    
    # uiRadioButtons
    extern 'void uiRadioButtonsAppend(uiRadioButtons *r, const char *text)'
    extern 'int uiRadioButtonsSelected(uiRadioButtons *r)'
    extern 'void uiRadioButtonsSetSelected(uiRadioButtons *r, int n)'
    extern 'void uiRadioButtonsOnSelected(uiRadioButtons *r, void (*f)(uiRadioButtons *, void *), void *data)'
    extern 'uiRadioButtons *uiNewRadioButtons(void)'
  end
end
