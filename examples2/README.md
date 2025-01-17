This directory may eventually contain code that serves the following purposes:

- Provide standalone (working) .rb files that test individual components of
the ruby-libui suite, such as the various widgets that are part of it. For instance,
button.rb should contain all code that relates to buttons, including functionality
to test the on-clicked event. Code used for this purpose should be contained within
the .rb file only, as well as the libui-bindings (e. g. toplevel LibUI or UI).

- Provide explanations to any other methods and functions that are offered
by this project, even if it may not be directly related to a specific widget.
For instance, querying the current libui-version, if that is made available
by upstream code.

- Documentation and explanations within those individual .rb files. That way
new users of this project may learn the bindings made available by kojix2
more rapidly so.

Stay tuned for more updates in this regard in the long run.
