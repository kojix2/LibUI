require 'fiddle/import'
require_relative 'fiddle_patch'
require_relative 'error'

module LibUI
  class Error < StandardError; end

  module FFI
    extend Fiddle::Importer
    extend FiddlePatch

    if LibUI.ffi_lib.nil?
      raise LibraryNotFoundError, 'Could not find libui shared library. LibUI.ffi_lib is nil.'
    elsif !File.exist?(LibUI.ffi_lib)
      raise LibraryNotFoundError, "Could not find libui shared library: #{LibUI.ffi_lib}"
    else
      begin
        dlload LibUI.ffi_lib
      rescue LoadError
        raise LibraryLoadError, "Could not load libui shared library: #{LibUI.ffi_lib}"
      end
    end

    class << self
      attr_reader :func_map

      def try_extern(signature, *opts)
        extern(signature, *opts)
      rescue StandardError => e
        # Do not raise error when the function is not found
        # because some functions may not be available on older versions of libui.
        warn "#{e.class.name}: #{e.message}"
      end

      def ffi_methods
        @ffi_methods ||= func_map.each_key.to_a
      end
    end

    typealias('uint32_t', 'unsigned int')
    typealias('uint64_t', 'unsigned long long')

    InitOptions = struct [
      'size_t Size'
    ]

    # https://github.com/andlabs/libui/blob/master/ui.h
    # keep same order

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

    Control = struct [
      'uint32_t Signature',
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
      'void (*Disable)(uiControl *)'
    ]

    try_extern 'void uiControlDestroy(uiControl *c)'
    try_extern 'uintptr_t uiControlHandle(uiControl *c)'
    try_extern 'uiControl *uiControlParent(uiControl *c)'
    try_extern 'void uiControlSetParent(uiControl *c, uiControl *parent)'
    try_extern 'int uiControlToplevel(uiControl *c)'
    try_extern 'int uiControlVisible(uiControl *c)'
    try_extern 'void uiControlShow(uiControl *c)'
    try_extern 'void uiControlHide(uiControl *c)'
    try_extern 'int uiControlEnabled(uiControl *c)'
    try_extern 'void uiControlEnable(uiControl *c)'
    try_extern 'void uiControlDisable(uiControl *c)'

    try_extern 'uiControl *uiAllocControl(size_t n, uint32_t OSsig, uint32_t typesig, const char *typenamestr)'
    try_extern 'void uiFreeControl(uiControl *c)'

    try_extern 'void uiControlVerifySetParent(uiControl *c, uiControl *parent)'
    try_extern 'int uiControlEnabledToUser(uiControl *c)'

    try_extern 'void uiUserBugCannotSetParentOnToplevel(const char *type)'

    # uiWindow

    try_extern 'char *uiWindowTitle(uiWindow *w)'
    try_extern 'void uiWindowSetTitle(uiWindow *w, const char *title)'
    try_extern 'void uiWindowPosition(uiWindow *w, int *x, int *y)'
    try_extern 'void uiWindowSetPosition(uiWindow *w, int x, int y)'
    try_extern 'void uiWindowOnPositionChanged(uiWindow *w, void (*f)(uiWindow *sender, void *senderData), void *data)'
    try_extern 'void uiWindowContentSize(uiWindow *w, int *width, int *height)'
    try_extern 'void uiWindowSetContentSize(uiWindow *w, int width, int height)'
    try_extern 'int uiWindowFullscreen(uiWindow *w)'
    try_extern 'void uiWindowSetFullscreen(uiWindow *w, int fullscreen)'
    try_extern 'void uiWindowOnContentSizeChanged(uiWindow *w, void (*f)(uiWindow *sender, void *senderData), void *data)'
    try_extern 'void uiWindowOnClosing(uiWindow *w, int (*f)(uiWindow *sender, void *senderData), void *data)'
    try_extern 'void uiWindowOnFocusChanged(uiWindow *w, void (*f)(uiWindow *sender, void *senderData), void *data)'
    try_extern 'int uiWindowFocused(uiWindow *w)'
    try_extern 'int uiWindowBorderless(uiWindow *w)'
    try_extern 'void uiWindowSetBorderless(uiWindow *w, int borderless)'
    try_extern 'void uiWindowSetChild(uiWindow *w, uiControl *child)'
    try_extern 'int uiWindowMargined(uiWindow *w)'
    try_extern 'void uiWindowSetMargined(uiWindow *w, int margined)'
    try_extern 'int uiWindowResizeable(uiWindow *w)'
    try_extern 'void uiWindowSetResizeable(uiWindow *w, int resizeable)'
    try_extern 'uiWindow *uiNewWindow(const char *title, int width, int height, int hasMenubar)'

    # uiButton

    try_extern 'char *uiButtonText(uiButton *b)'
    try_extern 'void uiButtonSetText(uiButton *b, const char *text)'
    try_extern 'void uiButtonOnClicked(uiButton *b, void (*f)(uiButton *sender, void *senderData), void *data)'
    try_extern 'uiButton *uiNewButton(const char *text)'

    # uiBox

    try_extern 'void uiBoxAppend(uiBox *b, uiControl *child, int stretchy)'
    try_extern 'int uiBoxNumChildren(uiBox *b)'
    try_extern 'void uiBoxDelete(uiBox *b, int index)'
    try_extern 'int uiBoxPadded(uiBox *b)'
    try_extern 'void uiBoxSetPadded(uiBox *b, int padded)'
    try_extern 'uiBox *uiNewHorizontalBox(void)'
    try_extern 'uiBox *uiNewVerticalBox(void)'

    # uiCheckbox

    try_extern 'char *uiCheckboxText(uiCheckbox *c)'
    try_extern 'void uiCheckboxSetText(uiCheckbox *c, const char *text)'
    try_extern 'void uiCheckboxOnToggled(uiCheckbox *c, void (*f)(uiCheckbox *sender, void *senderData), void *data)'
    try_extern 'int uiCheckboxChecked(uiCheckbox *c)'
    try_extern 'void uiCheckboxSetChecked(uiCheckbox *c, int checked)'
    try_extern 'uiCheckbox *uiNewCheckbox(const char *text)'

    # uiEntry

    try_extern 'char *uiEntryText(uiEntry *e)'
    try_extern 'void uiEntrySetText(uiEntry *e, const char *text)'
    try_extern 'void uiEntryOnChanged(uiEntry *e, void (*f)(uiEntry *sender, void *senderData), void *data)'
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
    try_extern 'void uiTabInsertAt(uiTab *t, const char *name, int index, uiControl *c)'
    try_extern 'void uiTabDelete(uiTab *t, int index)'
    try_extern 'int uiTabNumPages(uiTab *t)'
    try_extern 'int uiTabMargined(uiTab *t, int index)'
    try_extern 'void uiTabSetMargined(uiTab *t, int index, int margined)'
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
    try_extern 'void uiSpinboxOnChanged(uiSpinbox *s, void (*f)(uiSpinbox *sender, void *senderData), void *data)'
    try_extern 'uiSpinbox *uiNewSpinbox(int min, int max)'

    # uiSlider

    try_extern 'int uiSliderValue(uiSlider *s)'
    try_extern 'void uiSliderSetValue(uiSlider *s, int value)'
    try_extern 'int uiSliderHasToolTip(uiSlider *s)'
    try_extern 'void uiSliderSetHasToolTip(uiSlider *s, int hasToolTip)'
    try_extern 'void uiSliderOnChanged(uiSlider *s, void (*f)(uiSlider *sender, void *senderData), void *data)'
    try_extern 'void uiSliderOnReleased(uiSlider *s, void (*f)(uiSlider *sender, void *senderData), void *data)'
    try_extern 'void uiSliderSetRange(uiSlider *s, int min, int max)'
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
    try_extern 'void uiComboboxInsertAt(uiCombobox *c, int index, const char *text)'
    try_extern 'void uiComboboxDelete(uiCombobox *c, int index)'
    try_extern 'void uiComboboxClear(uiCombobox *c)'
    try_extern 'int uiComboboxNumItems(uiCombobox *c)'
    try_extern 'int uiComboboxSelected(uiCombobox *c)'
    try_extern 'void uiComboboxSetSelected(uiCombobox *c, int index)'
    try_extern 'void uiComboboxOnSelected(uiCombobox *c, void (*f)(uiCombobox *sender, void *senderData), void *data)'
    try_extern 'uiCombobox *uiNewCombobox(void)'

    # uiEditableCombobox

    try_extern 'void uiEditableComboboxAppend(uiEditableCombobox *c, const char *text)'
    try_extern 'char *uiEditableComboboxText(uiEditableCombobox *c)'
    try_extern 'void uiEditableComboboxSetText(uiEditableCombobox *c, const char *text)'
    try_extern 'void uiEditableComboboxOnChanged(uiEditableCombobox *c, void (*f)(uiEditableCombobox *sender, void *senderData), void *data)'
    try_extern 'uiEditableCombobox *uiNewEditableCombobox(void)'

    # uiRadioButtons

    try_extern 'void uiRadioButtonsAppend(uiRadioButtons *r, const char *text)'
    try_extern 'int uiRadioButtonsSelected(uiRadioButtons *r)'
    try_extern 'void uiRadioButtonsSetSelected(uiRadioButtons *r, int index)'
    try_extern 'void uiRadioButtonsOnSelected(uiRadioButtons *r, void (*f)(uiRadioButtons *sender, void *senderData), void *data)'
    try_extern 'uiRadioButtons *uiNewRadioButtons(void)'

    # uiDateTimePicker

    # time.h
    TM = if Fiddle::WINDOWS
           struct [
             'int tm_sec',
             'int tm_min',
             'int tm_hour',
             'int tm_mday',
             'int tm_mon',
             'int tm_year',
             'int tm_wday',
             'int tm_yday',
             'int tm_isdst'
           ]
         else # The GNU C Library (glibc)
           struct [
             'int tm_sec',
             'int tm_min',
             'int tm_hour',
             'int tm_mday',
             'int tm_mon',
             'int tm_year',
             'int tm_wday',
             'int tm_yday',
             'int tm_isdst',
             'long tm_gmtoff',
             'const char *tm_zone'
           ]
         end

    try_extern 'void uiDateTimePickerTime(uiDateTimePicker *d, struct tm *time)'
    try_extern 'void uiDateTimePickerSetTime(uiDateTimePicker *d, const struct tm *time)'
    try_extern 'void uiDateTimePickerOnChanged(uiDateTimePicker *d, void (*f)(uiDateTimePicker *sender, void *senderData), void *data)'
    try_extern 'uiDateTimePicker *uiNewDateTimePicker(void)'
    try_extern 'uiDateTimePicker *uiNewDatePicker(void)'
    try_extern 'uiDateTimePicker *uiNewTimePicker(void)'

    # uiMultilineEntry

    try_extern 'char *uiMultilineEntryText(uiMultilineEntry *e)'
    try_extern 'void uiMultilineEntrySetText(uiMultilineEntry *e, const char *text)'
    try_extern 'void uiMultilineEntryAppend(uiMultilineEntry *e, const char *text)'
    try_extern 'void uiMultilineEntryOnChanged(uiMultilineEntry *e, void (*f)(uiMultilineEntry *sender, void *senderData), void *data)'
    try_extern 'int uiMultilineEntryReadOnly(uiMultilineEntry *e)'
    try_extern 'void uiMultilineEntrySetReadOnly(uiMultilineEntry *e, int readonly)'
    try_extern 'uiMultilineEntry *uiNewMultilineEntry(void)'
    try_extern 'uiMultilineEntry *uiNewNonWrappingMultilineEntry(void)'

    # uiMenuItem

    try_extern 'void uiMenuItemEnable(uiMenuItem *m)'
    try_extern 'void uiMenuItemDisable(uiMenuItem *m)'
    try_extern 'void uiMenuItemOnClicked(uiMenuItem *m, void (*f)(uiMenuItem *sender, uiWindow *window, void *senderData), void *data)'
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
    try_extern 'char *uiOpenFolder(uiWindow *parent)'
    try_extern 'char *uiSaveFile(uiWindow *parent)'
    try_extern 'void uiMsgBox(uiWindow *parent, const char *title, const char *description)'
    try_extern 'void uiMsgBoxError(uiWindow *parent, const char *title, const char *description)'

    # uiArea

    AreaHandler = struct [
      'void (*Draw)(uiAreaHandler *, uiArea *, uiAreaDrawParams *)',
      'void (*MouseEvent)(uiAreaHandler *, uiArea *, uiAreaMouseEvent *)',
      'void (*MouseCrossed)(uiAreaHandler *, uiArea *, int left)',
      'void (*DragBroken)(uiAreaHandler *, uiArea *)',
      'int (*KeyEvent)(uiAreaHandler *, uiArea *, uiAreaKeyEvent *)'
    ]

    typealias 'uiWindowResizeEdge', 'int'

    try_extern 'void uiAreaSetSize(uiArea *a, int width, int height)'
    try_extern 'void uiAreaQueueRedrawAll(uiArea *a)'
    try_extern 'void uiAreaScrollTo(uiArea *a, double x, double y, double width, double height)'
    try_extern 'void uiAreaBeginUserWindowMove(uiArea *a)'
    try_extern 'void uiAreaBeginUserWindowResize(uiArea *a, uiWindowResizeEdge edge)'
    try_extern 'uiArea *uiNewArea(uiAreaHandler *ah)'
    try_extern 'uiArea *uiNewScrollingArea(uiAreaHandler *ah, int width, int height)'

    AreaDrawParams = struct [
      'uiDrawContext *Context',
      'double AreaWidth',
      'double AreaHeight',
      'double ClipX',
      'double ClipY',
      'double ClipWidth',
      'double ClipHeight'
    ]
    typealias 'uiDrawBrushType', 'int'
    typealias 'uiDrawLineCap', 'int'
    typealias 'uiDrawLineJoin', 'int'
    typealias 'uiDrawFillMode', 'int'

    DrawMatrix = struct [
      'double M11',
      'double M12',
      'double M21',
      'double M22',
      'double M31',
      'double M32'
    ]

    DrawBrush = struct [
      'uiDrawBrushType Type',
      'double R',
      'double G',
      'double B',
      'double A',
      'double X0',
      'double Y0',
      'double X1',
      'double Y1',
      'double OuterRadius',
      'uiDrawBrushGradientStop *Stops',
      'size_t NumStops'
    ]

    DrawBrushGradientStop = struct [
      'double Pos',
      'double R',
      'double G',
      'double B',
      'double A'
    ]

    DrawStrokeParams = struct [
      'uiDrawLineCap Cap',
      'uiDrawLineJoin Join',
      'double Thickness',
      'double MiterLimit',
      'double *Dashes',
      'size_t NumDashes',
      'double DashPhase'
    ]

    # uiDrawPath
    try_extern 'uiDrawPath *uiDrawNewPath(uiDrawFillMode fillMode)'
    try_extern 'void uiDrawFreePath(uiDrawPath *p)'
    try_extern 'void uiDrawPathNewFigure(uiDrawPath *p, double x, double y)'
    try_extern 'void uiDrawPathNewFigureWithArc(uiDrawPath *p, double xCenter, double yCenter, double radius, double startAngle, double sweep, int negative)'
    try_extern 'void uiDrawPathLineTo(uiDrawPath *p, double x, double y)'
    try_extern 'void uiDrawPathArcTo(uiDrawPath *p, double xCenter, double yCenter, double radius, double startAngle, double sweep, int negative)'
    try_extern 'void uiDrawPathBezierTo(uiDrawPath *p, double c1x, double c1y, double c2x, double c2y, double endX, double endY)'
    try_extern 'void uiDrawPathCloseFigure(uiDrawPath *p)'
    try_extern 'void uiDrawPathAddRectangle(uiDrawPath *p, double x, double y, double width, double height)'
    try_extern 'int uiDrawPathEnded(uiDrawPath *p)'
    try_extern 'void uiDrawPathEnd(uiDrawPath *p)'
    try_extern 'void uiDrawStroke(uiDrawContext *c, uiDrawPath *path, uiDrawBrush *b, uiDrawStrokeParams *p)'
    try_extern 'void uiDrawFill(uiDrawContext *c, uiDrawPath *path, uiDrawBrush *b)'

    # uiDrawMatrix
    try_extern 'void uiDrawMatrixSetIdentity(uiDrawMatrix *m)'
    try_extern 'void uiDrawMatrixTranslate(uiDrawMatrix *m, double x, double y)'
    try_extern 'void uiDrawMatrixScale(uiDrawMatrix *m, double xCenter, double yCenter, double x, double y)'
    try_extern 'void uiDrawMatrixRotate(uiDrawMatrix *m, double x, double y, double amount)'
    try_extern 'void uiDrawMatrixSkew(uiDrawMatrix *m, double x, double y, double xamount, double yamount)'
    try_extern 'void uiDrawMatrixMultiply(uiDrawMatrix *dest, uiDrawMatrix *src)'
    try_extern 'int uiDrawMatrixInvertible(uiDrawMatrix *m)'
    try_extern 'int uiDrawMatrixInvert(uiDrawMatrix *m)'
    try_extern 'void uiDrawMatrixTransformPoint(uiDrawMatrix *m, double *x, double *y)'
    try_extern 'void uiDrawMatrixTransformSize(uiDrawMatrix *m, double *x, double *y)'

    try_extern 'void uiDrawTransform(uiDrawContext *c, uiDrawMatrix *m)'
    try_extern 'void uiDrawClip(uiDrawContext *c, uiDrawPath *path)'
    try_extern 'void uiDrawSave(uiDrawContext *c)'
    try_extern 'void uiDrawRestore(uiDrawContext *c)'

    # uiAttribute
    try_extern 'void uiFreeAttribute(uiAttribute *a)'

    typealias 'uiAttributeType', 'int'

    try_extern 'uiAttributeType uiAttributeGetType(const uiAttribute *a)'
    try_extern 'uiAttribute *uiNewFamilyAttribute(const char *family)'
    try_extern 'const char *uiAttributeFamily(const uiAttribute *a)'
    try_extern 'uiAttribute *uiNewSizeAttribute(double size)'
    try_extern 'double uiAttributeSize(const uiAttribute *a)'

    typealias 'uiTextWeight', 'int'

    try_extern 'uiAttribute *uiNewWeightAttribute(uiTextWeight weight)'
    try_extern 'uiTextWeight uiAttributeWeight(const uiAttribute *a)'

    typealias 'uiTextItalic', 'int'

    try_extern 'uiAttribute *uiNewItalicAttribute(uiTextItalic italic)'
    try_extern 'uiTextItalic uiAttributeItalic(const uiAttribute *a)'

    typealias 'uiTextStretch', 'int'

    try_extern 'uiAttribute *uiNewStretchAttribute(uiTextStretch stretch)'
    try_extern 'uiTextStretch uiAttributeStretch(const uiAttribute *a)'
    try_extern 'uiAttribute *uiNewColorAttribute(double r, double g, double b, double a)'
    try_extern 'void uiAttributeColor(const uiAttribute *a, double *r, double *g, double *b, double *alpha)'
    try_extern 'uiAttribute *uiNewBackgroundAttribute(double r, double g, double b, double a)'

    typealias 'uiUnderline', 'int'

    try_extern 'uiAttribute *uiNewUnderlineAttribute(uiUnderline u)'
    try_extern 'uiUnderline uiAttributeUnderline(const uiAttribute *a)'

    typealias 'uiUnderlineColor', 'int'

    try_extern 'uiAttribute *uiNewUnderlineColorAttribute(uiUnderlineColor u, double r, double g, double b, double a)'
    try_extern 'void uiAttributeUnderlineColor(const uiAttribute *a, uiUnderlineColor *u, double *r, double *g, double *b, double *alpha)'

    # uiOpenTypeFeatures

    typealias 'uiOpenTypeFeaturesForEachFunc', 'void*'

    try_extern 'uiOpenTypeFeatures *uiNewOpenTypeFeatures(void)'
    try_extern 'void uiFreeOpenTypeFeatures(uiOpenTypeFeatures *otf)'
    try_extern 'uiOpenTypeFeatures *uiOpenTypeFeaturesClone(const uiOpenTypeFeatures *otf)'
    try_extern 'void uiOpenTypeFeaturesAdd(uiOpenTypeFeatures *otf, char a, char b, char c, char d, uint32_t value)'
    try_extern 'void uiOpenTypeFeaturesRemove(uiOpenTypeFeatures *otf, char a, char b, char c, char d)'
    try_extern 'int uiOpenTypeFeaturesGet(const uiOpenTypeFeatures *otf, char a, char b, char c, char d, uint32_t *value)'
    try_extern 'void uiOpenTypeFeaturesForEach(const uiOpenTypeFeatures *otf, uiOpenTypeFeaturesForEachFunc f, void *data)'
    try_extern 'uiAttribute *uiNewFeaturesAttribute(const uiOpenTypeFeatures *otf)'
    try_extern 'const uiOpenTypeFeatures *uiAttributeFeatures(const uiAttribute *a)'

    # uiAttributedString

    typealias 'uiAttributedStringForEachAttributeFunc', 'void*'

    try_extern 'uiAttributedString *uiNewAttributedString(const char *initialString)'
    try_extern 'void uiFreeAttributedString(uiAttributedString *s)'
    try_extern 'const char *uiAttributedStringString(const uiAttributedString *s)'
    try_extern 'size_t uiAttributedStringLen(const uiAttributedString *s)'
    try_extern 'void uiAttributedStringAppendUnattributed(uiAttributedString *s, const char *str)'
    try_extern 'void uiAttributedStringInsertAtUnattributed(uiAttributedString *s, const char *str, size_t at)'
    try_extern 'void uiAttributedStringDelete(uiAttributedString *s, size_t start, size_t end)'
    try_extern 'void uiAttributedStringSetAttribute(uiAttributedString *s, uiAttribute *a, size_t start, size_t end)'
    try_extern 'void uiAttributedStringForEachAttribute(const uiAttributedString *s, uiAttributedStringForEachAttributeFunc f, void *data)'
    try_extern 'size_t uiAttributedStringNumGraphemes(uiAttributedString *s)'
    try_extern 'size_t uiAttributedStringByteIndexToGrapheme(uiAttributedString *s, size_t pos)'
    try_extern 'size_t uiAttributedStringGraphemeToByteIndex(uiAttributedString *s, size_t pos)'

    # uiFont

    FontDescriptor = struct [
      'char *Family',
      'double Size',
      'uiTextWeight Weight',
      'uiTextItalic Italic',
      'uiTextStretch Stretch'
    ]

    try_extern 'void uiLoadControlFont(uiFontDescriptor *f)'
    try_extern 'void uiFreeFontDescriptor(uiFontDescriptor *desc)'

    typealias 'uiDrawTextAlign', 'int'

    DrawTextLayoutParams = struct [
      'uiAttributedString *String',
      'uiFontDescriptor *DefaultFont',
      'double Width',
      'uiDrawTextAlign Align'
    ]

    try_extern 'uiDrawTextLayout *uiDrawNewTextLayout(uiDrawTextLayoutParams *params)'
    try_extern 'void uiDrawFreeTextLayout(uiDrawTextLayout *tl)'
    try_extern 'void uiDrawText(uiDrawContext *c, uiDrawTextLayout *tl, double x, double y)'
    try_extern 'void uiDrawTextLayoutExtents(uiDrawTextLayout *tl, double *width, double *height)'

    # uiFontButton

    try_extern 'void uiFontButtonFont(uiFontButton *b, uiFontDescriptor *desc)'
    try_extern 'void uiFontButtonOnChanged(uiFontButton *b, void (*f)(uiFontButton *sender, void *senderData), void *data)'
    try_extern 'uiFontButton *uiNewFontButton(void)'
    try_extern 'void uiFreeFontButtonFont(uiFontDescriptor *desc)'

    typealias 'uiModifiers', 'int'

    AreaMouseEvent = struct [
      'double X',
      'double Y',
      'double AreaWidth',
      'double AreaHeight',
      'int Down',
      'int Up',
      'int Count',
      'uiModifiers Modifiers',
      'uint64_t Held1To64'
    ]

    typealias 'uiExtKey', 'int'

    AreaKeyEvent = struct [
      'char Key',
      'uiExtKey ExtKey',
      'uiModifiers Modifier',
      'uiModifiers Modifiers',
      'int Up'
    ]

    # uiColorButton

    try_extern 'void uiColorButtonColor(uiColorButton *b, double *r, double *g, double *bl, double *a)'
    try_extern 'void uiColorButtonSetColor(uiColorButton *b, double r, double g, double bl, double a)'
    try_extern 'void uiColorButtonOnChanged(uiColorButton *b, void (*f)(uiColorButton *sender, void *senderData), void *data)'
    try_extern 'uiColorButton *uiNewColorButton(void)'

    # uiForm

    try_extern 'void uiFormAppend(uiForm *f, const char *label, uiControl *c, int stretchy)'
    try_extern 'int uiFormNumChildren(uiForm *f)'
    try_extern 'void uiFormDelete(uiForm *f, int index)'
    try_extern 'int uiFormPadded(uiForm *f)'
    try_extern 'void uiFormSetPadded(uiForm *f, int padded)'
    try_extern 'uiForm *uiNewForm(void)'

    typealias 'uiAlign', 'int'

    typealias 'uiAt', 'int'

    # uiGrid

    try_extern 'void uiGridAppend(uiGrid *g, uiControl *c, int left, int top, int xspan, int yspan, int hexpand, uiAlign halign, int vexpand, uiAlign valign)'
    try_extern 'void uiGridInsertAt(uiGrid *g, uiControl *c, uiControl *existing, uiAt at, int xspan, int yspan, int hexpand, uiAlign halign, int vexpand, uiAlign valign)'
    try_extern 'int uiGridPadded(uiGrid *g)'
    try_extern 'void uiGridSetPadded(uiGrid *g, int padded)'
    try_extern 'uiGrid *uiNewGrid(void)'

    # uiImage

    try_extern 'uiImage *uiNewImage(double width, double height)'
    try_extern 'void uiFreeImage(uiImage *i)'
    try_extern 'void uiImageAppend(uiImage *i, void *pixels, int pixelWidth, int pixelHeight, int byteStride)'

    # uiTable
    try_extern 'void uiFreeTableValue(uiTableValue *v)'

    typealias 'uiTableValueType', 'int'

    try_extern 'uiTableValueType uiTableValueGetType(const uiTableValue *v)'
    try_extern 'uiTableValue *uiNewTableValueString(const char *str)'
    try_extern 'const char *uiTableValueString(const uiTableValue *v)'
    try_extern 'uiTableValue *uiNewTableValueImage(uiImage *img)'
    try_extern 'uiImage *uiTableValueImage(const uiTableValue *v)'
    try_extern 'uiTableValue *uiNewTableValueInt(int i)'
    try_extern 'int uiTableValueInt(const uiTableValue *v)'
    try_extern 'uiTableValue *uiNewTableValueColor(double r, double g, double b, double a)'
    try_extern 'void uiTableValueColor(const uiTableValue *v, double *r, double *g, double *b, double *a)'

    TableModelHandler = struct [
      'int (*NumColumns)(uiTableModelHandler *, uiTableModel *)',
      'uiTableValueType (*ColumnType)(uiTableModelHandler *, uiTableModel *, int)',
      'int (*NumRows)(uiTableModelHandler *, uiTableModel *)',
      'uiTableValue *(*CellValue)(uiTableModelHandler *mh, uiTableModel *m, int row, int column)',
      'void (*SetCellValue)(uiTableModelHandler *, uiTableModel *, int, int, const uiTableValue *)'
    ]

    try_extern 'uiTableModel *uiNewTableModel(uiTableModelHandler *mh)'
    try_extern 'void uiFreeTableModel(uiTableModel *m)'
    try_extern 'void uiTableModelRowInserted(uiTableModel *m, int newIndex)'
    try_extern 'void uiTableModelRowChanged(uiTableModel *m, int index)'
    try_extern 'void uiTableModelRowDeleted(uiTableModel *m, int oldIndex)'

    TableTextColumnOptionalParams = struct [
      'int ColorModelColumn'
    ]

    TableParams = struct [
      'uiTableModel *Model',
      'int RowBackgroundColorModelColumn'
    ]

    try_extern 'void uiTableAppendTextColumn(uiTable *t, const char *name, int textModelColumn, int textEditableModelColumn, uiTableTextColumnOptionalParams *textParams)'
    try_extern 'void uiTableAppendImageColumn(uiTable *t, const char *name, int imageModelColumn)'
    try_extern 'void uiTableAppendImageTextColumn(uiTable *t, const char *name, int imageModelColumn, int textModelColumn, int textEditableModelColumn, uiTableTextColumnOptionalParams *textParams)'
    try_extern 'void uiTableAppendCheckboxColumn(uiTable *t, const char *name, int checkboxModelColumn, int checkboxEditableModelColumn)'
    try_extern 'void uiTableAppendCheckboxTextColumn(uiTable *t, const char *name, int checkboxModelColumn, int checkboxEditableModelColumn, int textModelColumn, int textEditableModelColumn, uiTableTextColumnOptionalParams *textParams)'
    try_extern 'void uiTableAppendProgressBarColumn(uiTable *t, const char *name, int progressModelColumn)'
    try_extern 'void uiTableAppendButtonColumn(uiTable *t, const char *name, int buttonModelColumn, int buttonClickableModelColumn)'
    try_extern 'int uiTableHeaderVisible(uiTable *t)'
    try_extern 'void uiTableHeaderSetVisible(uiTable *t, int visible)'
    try_extern 'uiTable *uiNewTable(uiTableParams *params)'
    try_extern 'void uiTableOnRowClicked(uiTable *t, void (*f)(uiTable *t, int row, void *data), void *data)'
    try_extern 'void uiTableOnRowDoubleClicked(uiTable *t, void (*f)(uiTable *t, int row, void *data), void *data)'

    typealias 'uiSortIndicator', 'int'

    try_extern 'void uiTableHeaderSetSortIndicator(uiTable *t, int column, uiSortIndicator indicator)'
    try_extern 'uiSortIndicator uiTableHeaderSortIndicator(uiTable *t, int column)'
    try_extern 'void uiTableHeaderOnClicked(uiTable *t, void (*f)(uiTable *sender, int column, void *senderData), void *data)'
    try_extern 'int uiTableColumnWidth(uiTable *t, int column)'
    try_extern 'void uiTableColumnSetWidth(uiTable *t, int column, int width)'

    typealias 'uiTableSelectionMode', 'int'

    try_extern 'uiTableSelectionMode uiTableGetSelectionMode(uiTable *t)'
    try_extern 'void uiTableSetSelectionMode(uiTable *t, uiTableSelectionMode mode)'
    try_extern 'void uiTableOnSelectionChanged(uiTable *t, void (*f)(uiTable *t, void *data), void *data)'
    try_extern 'uiTableSelection* uiTableGetSelection(uiTable *t)'
    try_extern 'void uiTableSetSelection(uiTable *t, uiTableSelection *sel)'
    try_extern 'void uiFreeTableSelection(uiTableSelection* s)'

    TableSelection = struct [
      'int NumRows',
      'int *Rows'
    ]
  end
end
