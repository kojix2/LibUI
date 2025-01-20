# ============================================================================ #
# This example (grid.rb) shall demonstrate the following functionality
# (8 components), as well as their implementation-status in regards to
# this file:
#
#   :new_grid                                   # [DONE]
#   :grid_append                                # [DONE]
#   :grid_insert_at                             # Unsure how to do this.
#   :grid_padded                                # [DONE]
#   :grid_set_padded                            # [DONE]
#
# API documentation can be seen here:
#
#   https://libui.dev/structui_grid.html
#
# ============================================================================ #
require 'libui'
LibUI.init # Initialize LibUI.

main_window = LibUI.new_window('grid.rb', 800, 250, 1)

hbox = LibUI.new_horizontal_box
LibUI.box_set_padded(hbox, 1)

_ = LibUI.new_grid # Create a new grid here.
LibUI.box_append(hbox, _, 1) # Add the grid here.
LibUI.grid_set_padded(_,  0) # Here we could toggle the padded-status.
puts 'Is the grid padded? '+LibUI.grid_padded(_).to_s+
     ' (1 means yes)'

button1 = LibUI.new_button('Test-Button #1')
button2 = LibUI.new_button('Test-Button #2')
button3 = LibUI.new_button('Test-Button #3')
button4 = LibUI.new_button('Test-Button #4')

left    = 0
top     = 0
xspan   = 1
yspan   = 1
hexpand = 1
halign  = 1
vexpand = 1
valign  = 1

# ======================================================================== #
# left, top, xspan, yspan, hexpand, halign, vexpand, valign
#  0,    0,    2,     1,      0,      1,       1,      1
# ======================================================================== #
LibUI.grid_append(
  _,
  button1, # This is the widget that will be added (appended) onto the grid-widget.
  left,
  top,
  xspan,
  yspan,
  hexpand,
  halign,
  vexpand,
  valign
)


left    = 1
top     = 0
xspan   = 1
yspan   = 1
hexpand = 1
halign  = 1
vexpand = 1
valign  = 1

# ======================================================================== #
# left, top, xspan, yspan, hexpand, halign, vexpand, valign
#  0,    0,    2,     1,      0,      1,       1,      1
# ======================================================================== #
LibUI.grid_append(
  _,
  button2, # This is the widget that will be added (appended) onto the grid-widget.
  left,
  top,
  xspan,
  yspan,
  hexpand,
  halign,
  vexpand,
  valign
)

left    = 0
top     = 1
xspan   = 1
yspan   = 1
hexpand = 1
halign  = 1
vexpand = 1
valign  = 1

# ======================================================================== #
# left, top, xspan, yspan, hexpand, halign, vexpand, valign
#  0,    1,    2,     1,      0,      1,       1,      1
# ======================================================================== #
LibUI.grid_append(
  _,
  button3, # This is the widget that will be added (appended) onto the grid-widget.
  left,
  top,
  xspan,
  yspan,
  hexpand,
  halign,
  vexpand,
  valign
)

left    = 1
top     = 1
xspan   = 1
yspan   = 1
hexpand = 1
halign  = 1
vexpand = 1
valign  = 1

# ======================================================================== #
# left, top, xspan, yspan, hexpand, halign, vexpand, valign
#  1,    1,    2,     1,      0,      1,       1,      1
# ======================================================================== #
LibUI.grid_append(
  _,
  button4, # This is the widget that will be added (appended) onto the grid-widget.
  left,
  top,
  xspan,
  yspan,
  hexpand,
  halign,
  vexpand,
  valign
)

if false # The next clause does not work correctly yet.
entry1  = LibUI.new_entry
# ============================================================================ #
# See: https://libui.dev/structui_grid.html#ad282fc62adbaed067699f949d619899c
#
# Arguments to LibUI.grid_insert_at() are:
#
#   void uiGridInsertAt	(	uiGrid *	g,
#   uiControl *	c,
#   uiControl *	existing,
#   uiAt	at,
#   int	xspan,
#   int	yspan,
#   int	hexpand,
#   uiAlign	halign,
#   int	vexpand,
#   uiAlign	valign )
#
# ============================================================================ #
LibUI.grid_insert_at(
  _,
  entry1,  # The widget to insert.
  button3, # Our relative widget.
  LibUI::AtTrailing, # at: Placement specifier in relation to existing control.
  0, # xspan
  1, # yspan
  1,
  1,
  1,
  1
)
end

LibUI.window_set_child(main_window, hbox)
LibUI.control_show(main_window)

LibUI.window_on_closing(main_window) {
  LibUI.quit
  1
}

LibUI.main
LibUI.uninit
