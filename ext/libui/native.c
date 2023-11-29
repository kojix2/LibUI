#include "native.h"

static VALUE mLibUI;
static VALUE mNative;
static VALUE mFFI;
static VALUE cFFISingletonClass;

static void *convert_to_pointer(VALUE FiddlePointer)
{
    VALUE rb_address = rb_funcall(FiddlePointer, rb_intern("to_i"), 0);

    return (void *)NUM2ULL(rb_address);
}

static VALUE
mNative_uiDrawFreePath(VALUE self, VALUE DrawPathFiddlePointer)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawFreePath(ptr);

    return Qnil;
}

static VALUE
mNative_uiDrawPathNewFigure(VALUE self, VALUE DrawPathFiddlePointer, VALUE x, VALUE y)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathNewFigure(ptr, NUM2DBL(x), NUM2DBL(y));

    return Qnil;
}

static VALUE
mNative_uiDrawPathNewFigureWithArc(VALUE self, VALUE DrawPathFiddlePointer, VALUE xCenter, VALUE yCenter, VALUE radius, VALUE startAngle, VALUE sweep, VALUE negative)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathNewFigureWithArc(ptr, NUM2DBL(xCenter), NUM2DBL(yCenter), NUM2DBL(radius), NUM2DBL(startAngle), NUM2DBL(sweep), RTEST(negative));

    return Qnil;
}

static VALUE
mNative_uiDrawPathLineTo(VALUE self, VALUE DrawPathFiddlePointer, VALUE x, VALUE y)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathLineTo(ptr, NUM2DBL(x), NUM2DBL(y));

    return Qnil;
}

static VALUE
mNative_uiDrawPathArcTo(VALUE self, VALUE DrawPathFiddlePointer, VALUE xCenter, VALUE yCenter, VALUE radius, VALUE startAngle, VALUE sweep, VALUE negative)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathArcTo(ptr, NUM2DBL(xCenter), NUM2DBL(yCenter), NUM2DBL(radius), NUM2DBL(startAngle), NUM2DBL(sweep), RTEST(negative));

    return Qnil;
}

static VALUE
mNative_uiDrawPathBezierTo(VALUE self, VALUE DrawPathFiddlePointer, VALUE c1x, VALUE c1y, VALUE c2x, VALUE c2y, VALUE endX, VALUE endY)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathBezierTo(ptr, NUM2DBL(c1x), NUM2DBL(c1y), NUM2DBL(c2x), NUM2DBL(c2y), NUM2DBL(endX), NUM2DBL(endY));

    return Qnil;
}

static VALUE
mNative_uiDrawPathCloseFigure(VALUE self, VALUE DrawPathFiddlePointer)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathCloseFigure(ptr);

    return Qnil;
}

static VALUE
mNative_uiDrawPathAddRectangle(VALUE self, VALUE DrawPathFiddlePointer, VALUE x, VALUE y, VALUE width, VALUE height)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathAddRectangle(ptr, NUM2DBL(x), NUM2DBL(y), NUM2DBL(width), NUM2DBL(height));

    return Qnil;
}

static VALUE
mNative_uiDrawPathEnded(VALUE self, VALUE DrawPathFiddlePointer)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);
    int i = uiDrawPathEnded(ptr);
    return INT2NUM(i);
}

static VALUE
mNative_uiDrawPathEnd(VALUE self, VALUE DrawPathFiddlePointer)
{
    uiDrawPath *ptr = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawPathEnd(ptr);

    return Qnil;
}

static VALUE
mNative_uiDrawStroke(VALUE self, VALUE DrawContextFiddlePointer, VALUE DrawPathFiddlePointer, VALUE DrawBrushFiddlePointer, VALUE DrawStrokeParamsFiddlePointer)
{
    uiDrawContext *context = convert_to_pointer(DrawContextFiddlePointer);
    uiDrawPath *path = convert_to_pointer(DrawPathFiddlePointer);
    uiDrawBrush *brush = convert_to_pointer(DrawBrushFiddlePointer);
    uiDrawStrokeParams *params = convert_to_pointer(DrawStrokeParamsFiddlePointer);

    uiDrawStroke(context, path, brush, params);

    return Qnil;
}

static VALUE
mNative_uiDrawFill(VALUE self, VALUE DrawContextFiddlePointer, VALUE DrawPathFiddlePointer, VALUE DrawBrushFiddlePointer)
{
    uiDrawContext *context = convert_to_pointer(DrawContextFiddlePointer);
    uiDrawPath *path = convert_to_pointer(DrawPathFiddlePointer);
    uiDrawBrush *brush = convert_to_pointer(DrawBrushFiddlePointer);

    uiDrawFill(context, path, brush);

    return Qnil;
}

static VALUE
mNative_uiDrawMatrixSetIdentity(VALUE self, VALUE DrawMatrixFiddlePointer)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);

    uiDrawMatrixSetIdentity(m);

    return Qnil;
}

static VALUE
mNative_uiDrawMatrixTranslate(VALUE self, VALUE DrawMatrixFiddlePointer, VALUE x, VALUE y)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);

    uiDrawMatrixTranslate(m, NUM2DBL(x), NUM2DBL(y));

    return Qnil;
}

static VALUE
mNative_uiDrawMatrixScale(VALUE self, VALUE DrawMatrixFiddlePointer, VALUE xCenter, VALUE yCenter, VALUE x, VALUE y)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);

    uiDrawMatrixScale(m, NUM2DBL(xCenter), NUM2DBL(yCenter), NUM2DBL(x), NUM2DBL(y));

    return Qnil;
}

static VALUE
mNative_uiDrawMatrixRotate(VALUE self, VALUE DrawMatrixFiddlePointer, VALUE x, VALUE y, VALUE amount)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);

    uiDrawMatrixRotate(m, NUM2DBL(x), NUM2DBL(y), NUM2DBL(amount));

    return Qnil;
}

static VALUE
mNative_uiDrawMatrixSkew(VALUE self, VALUE DrawMatrixFiddlePointer, VALUE x, VALUE y, VALUE xamount, VALUE yamount)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);

    uiDrawMatrixSkew(m, NUM2DBL(x), NUM2DBL(y), NUM2DBL(xamount), NUM2DBL(yamount));

    return Qnil;
}

static VALUE
mNative_uiDrawMatrixMultiply(VALUE self, VALUE destDrawMatrixFiddlePointer, VALUE srcDrawMatrixFiddlePointer)
{
    uiDrawMatrix *dest = convert_to_pointer(destDrawMatrixFiddlePointer);
    uiDrawMatrix *src = convert_to_pointer(srcDrawMatrixFiddlePointer);

    uiDrawMatrixMultiply(dest, src);

    return Qnil;
}

static VALUE
mNative_uiDrawMatrixInvertible(VALUE self, VALUE DrawMatrixFiddlePointer)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);
    int i = uiDrawMatrixInvertible(m);
    return INT2NUM(i);
}

static VALUE
mNative_uiDrawMatrixInvert(VALUE self, VALUE DrawMatrixFiddlePointer)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);
    int i = uiDrawMatrixInvert(m);
    return INT2NUM(i);
}

static VALUE
mNative_uiDrawMatrixTransformPoint(VALUE self, VALUE DrawMatrixFiddlePointer, VALUE x, VALUE y)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);
    double dx = NUM2DBL(x);
    double dy = NUM2DBL(y);

    uiDrawMatrixTransformPoint(m, &dx, &dy);

    VALUE result = rb_ary_new2(2);
    rb_ary_push(result, DBL2NUM(dx));
    rb_ary_push(result, DBL2NUM(dy));

    return result;
}

static VALUE
mNative_uiDrawMatrixTransformSize(VALUE self, VALUE DrawMatrixFiddlePointer, VALUE x, VALUE y)
{
    uiDrawMatrix *m = convert_to_pointer(DrawMatrixFiddlePointer);
    double dx = NUM2DBL(x);
    double dy = NUM2DBL(y);

    uiDrawMatrixTransformSize(m, &dx, &dy);

    VALUE result = rb_ary_new2(2);
    rb_ary_push(result, DBL2NUM(dx));
    rb_ary_push(result, DBL2NUM(dy));

    return result;
}

static VALUE
mNative_uiDrawTransform(VALUE self, VALUE DrawContextFiddlePointer, VALUE DrawMatrixFiddlePointer)
{
    uiDrawContext *context = convert_to_pointer(DrawContextFiddlePointer);
    uiDrawMatrix *matrix = convert_to_pointer(DrawMatrixFiddlePointer);

    uiDrawTransform(context, matrix);

    return Qnil;
}

static VALUE
mNative_uiDrawClip(VALUE self, VALUE DrawContextFiddlePointer, VALUE DrawPathFiddlePointer)
{
    uiDrawContext *context = convert_to_pointer(DrawContextFiddlePointer);
    uiDrawPath *path = convert_to_pointer(DrawPathFiddlePointer);

    uiDrawClip(context, path);

    return Qnil;
}

static VALUE
mNative_uiDrawSave(VALUE self, VALUE DrawContextFiddlePointer)
{
    uiDrawContext *context = convert_to_pointer(DrawContextFiddlePointer);

    uiDrawSave(context);

    return Qnil;
}

static VALUE
mNative_uiDrawRestore(VALUE self, VALUE DrawContextFiddlePointer)
{
    uiDrawContext *context = convert_to_pointer(DrawContextFiddlePointer);

    uiDrawRestore(context);

    return Qnil;
}

#define RB_DEFINE_METHOD(klass, name, func, argc) \
    rb_define_method(klass, name, func, argc);    \
    rb_define_singleton_method(klass, name, func, argc);

void Init_native(void)
{
    rb_require("libui");
    mLibUI = rb_define_module("LibUI");
    mNative = rb_define_module_under(mLibUI, "Native");
    mFFI = rb_define_module_under(mLibUI, "FFI");
    cFFISingletonClass = rb_singleton_class(mFFI);

    RB_DEFINE_METHOD(mNative, "uiDrawFreePath", mNative_uiDrawFreePath, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawPathNewFigure", mNative_uiDrawPathNewFigure, 3);
    RB_DEFINE_METHOD(mNative, "uiDrawPathNewFigureWithArc", mNative_uiDrawPathNewFigureWithArc, 7);
    RB_DEFINE_METHOD(mNative, "uiDrawPathLineTo", mNative_uiDrawPathLineTo, 3);
    RB_DEFINE_METHOD(mNative, "uiDrawPathArcTo", mNative_uiDrawPathArcTo, 7);
    RB_DEFINE_METHOD(mNative, "uiDrawPathBezierTo", mNative_uiDrawPathBezierTo, 7);
    RB_DEFINE_METHOD(mNative, "uiDrawPathCloseFigure", mNative_uiDrawPathCloseFigure, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawPathAddRectangle", mNative_uiDrawPathAddRectangle, 5);
    RB_DEFINE_METHOD(mNative, "uiDrawPathEnded", mNative_uiDrawPathEnded, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawPathEnd", mNative_uiDrawPathEnd, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawStroke", mNative_uiDrawStroke, 4);
    RB_DEFINE_METHOD(mNative, "uiDrawFill", mNative_uiDrawFill, 3);

    RB_DEFINE_METHOD(mNative, "uiDrawMatrixSetIdentity", mNative_uiDrawMatrixSetIdentity, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixTranslate", mNative_uiDrawMatrixTranslate, 3);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixScale", mNative_uiDrawMatrixScale, 5);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixRotate", mNative_uiDrawMatrixRotate, 4);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixSkew", mNative_uiDrawMatrixSkew, 5);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixMultiply", mNative_uiDrawMatrixMultiply, 2);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixInvertible", mNative_uiDrawMatrixInvertible, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixInvert", mNative_uiDrawMatrixInvert, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixTransformPoint", mNative_uiDrawMatrixTransformPoint, 3);
    RB_DEFINE_METHOD(mNative, "uiDrawMatrixTransformSize", mNative_uiDrawMatrixTransformSize, 3);

    RB_DEFINE_METHOD(mNative, "uiDrawTransform", mNative_uiDrawTransform, 2);
    RB_DEFINE_METHOD(mNative, "uiDrawClip", mNative_uiDrawClip, 2);
    RB_DEFINE_METHOD(mNative, "uiDrawSave", mNative_uiDrawSave, 1);
    RB_DEFINE_METHOD(mNative, "uiDrawRestore", mNative_uiDrawRestore, 1);

    rb_prepend_module(cFFISingletonClass, mNative);
}