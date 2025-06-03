This directory (examples2/) contains code that refers to widgets and functions made available via the official libui-ng (see https://github.com/libui-ng/libui-ng) bindings (and perhaps eventually libui-dev as well).

The rationale (and objective) for this directory here serves at the least the following purposes:

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

So far (this update) almost 82 "components" are verified by examples in the subdirectory examples2/ here. I think we are close to 50% in total now or almost at 50%.

Widgets that have been added to this subdirectory include, as standalone files:

    button.rb
    checkbox.rb
    color_button.rb
    combobox.rb
    date_picker.rb
    editable_combobox.rb
    entry.rb
    grid.rb
    password_entry.rb
    search_entry.rb
    slider.rb
    window.rb

Note that this subdirectory here (examples2/) is different to examples/. The examples/ subdirectory has been created by kojix2 to test various parts of ruby-libui, including more complex use cases (see the histogram example for dynamic elements).

Available new-entries in regards to LibUI include:

- new_area
- new_attributed_string
- new_background_attribute
- new_button
- new_checkbox
- new_color_attribute
- new_color_button
- new_combobox
- new_date_picker
- new_date_time_picker
- new_editable_combobox
- new_entry
- new_family_attribute
- new_features_attribute
- new_font_button
- new_form
- new_grid
- new_group
- new_horizontal_box
- new_horizontal_separator
- new_image
- new_italic_attribute
- new_label
- new_menu
- new_multiline_entry
- new_non_wrapping_multiline_entry
- new_open_type_features
- new_password_entry
- new_progress_bar
- new_radio_buttons
- new_scrolling_area
- new_search_entry
- new_size_attribute
- new_slider
- new_spinbox
- new_stretch_attribute
- new_tab
- new_table
- new_table_model
- new_table_value_color
- new_table_value_image
- new_table_value_int
- new_table_value_string
- new_time_picker
- new_underline_attribute
- new_underline_color_attribute
- new_vertical_box
- new_vertical_separator
- new_weight_attribute
- new_window
