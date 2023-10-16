#include "native.h"

static VALUE mLibUI;
static VALUE mNative;

void Init_native(void)
{
    mLibUI = rb_define_module("LibUI");
    mNative = rb_define_module_under(mLibUI, "Native");
}