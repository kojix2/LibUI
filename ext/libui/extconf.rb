require 'mkmf'

find_header('ui.h', File.expand_path('../include', __dir__))
find_library('ui', nil, File.expand_path('../../vendor', __dir__))

create_makefile('libui/native')
