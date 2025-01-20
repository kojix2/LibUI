This directory contains code that refers to widgets and functions made available via the official libui-ng (see https://github.com/libui-ng/libui-ng) bindings (and perhaps eventually libui-dev as well). The rationale (and objective of) for this directory here serves at the least the following purposes:

- Provide standalone (working) .rb files that test individual components of
the ruby-libui suite, such as the various widgets that are part of (and supported by)
libui. For instance, button.rb should contain all code that relates to buttons,
including functionality to test the on-clicked event. Same for combobox.rb, which
should include all code specific to the combobox-widget, and so forth. Code used
for this purpose should be contained within a single .rb file only, as well as the
libui-bindings necessary to demonstrate its functionality (e. g. toplevel LibUI or
UI, the main window, usually a box to contain the widget at hand, and so forth).

- Provide explanations to any other methods and functions that are offered
by this project, even if it may not be directly related to a specific widget.
For instance, querying the current libui-version, if that is made available
by upstream code.

- Documentation and explanations within those individual .rb files. That way
new users of this project may learn the bindings made available by kojix2
more rapidly so.

Stay tuned for more updates in this regard in the long run. Right now nine 
widgets have been added; expect more code in this regard over the next days and weeks. \o/

I also invite others to contribute changes, including documentation. Let's improve the
default experience of ruby + libui for new users, as well as provide working reference
implementations for all functionality made available in ruby-libui.

So far (this update) almost 76 components are verified by examples in the subdirectory examples2/ here. I think we are close to 50% in total now or almost at 50%.
