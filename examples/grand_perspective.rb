require 'libui'
require 'rexml/document'

UI = LibUI

UI.init

@main_window = UI.new_window('File Treemap Visualizer', 800, 620, 1)
UI.window_set_margined(@main_window, 1)

class FileTree
  attr_reader :name, :size, :children

  def initialize(name, size = 0)
    @name = name
    @size = size
    @children = []
  end

  def add_child(child)
    @children << child
    @size += child.size
  end

  def file?
    @children.empty?
  end
end

class FileTreeParser
  def self.parse(file)
    xml_content = File.read(file)
    doc = REXML::Document.new(xml_content)
    root_element = doc.elements['GrandPerspectiveScanDump/ScanInfo/Folder']
    parse_folder(root_element)
  end

  def self.parse_folder(element)
    folder = FileTree.new(element.attributes['name'])

    element.elements.each do |child|
      if child.name == 'Folder'
        folder.add_child(parse_folder(child))
      elsif child.name == 'File'
        file_size = child.attributes['size'].to_i
        folder.add_child(FileTree.new(child.attributes['name'], file_size))
      end
    end

    folder
  end
end

class TreeMap
  def initialize(file_tree)
    @file_tree = file_tree
  end

  def compute_layout(x, y, width, height, orientation = :horizontal)
    compute_treemap_layout(@file_tree, x, y, width, height, orientation)
  end

  private

  def compute_treemap_layout(node, x, y, width, height, orientation)
    layout = []

    total_size = node.children.map(&:size).sum.to_f
    return layout if total_size == 0

    offset = 0
    node.children.each do |child|
      ratio = child.size / total_size

      if orientation == :horizontal
        child_width = width * ratio
        child_height = height
        child_x = x + offset
        child_y = y
        offset += child_width
      else
        child_width = width
        child_height = height * ratio
        child_x = x
        child_y = y + offset
        offset += child_height
      end

      if child.file?
        layout << { x: child_x, y: child_y, width: child_width, height: child_height, node: child }
      end

      if !child.file?
        layout += compute_treemap_layout(child, child_x, child_y, child_width, child_height, orientation == :horizontal ? :vertical : :horizontal)
      end
    end

    layout
  end
end

xml_file = ARGV[0] || 'sample.xml'
file_tree = FileTreeParser.parse(xml_file)

tree_map = TreeMap.new(file_tree)

handler = UI::FFI::AreaHandler.malloc
handler.to_ptr.free = Fiddle::RUBY_FREE
area    = UI.new_area(handler)
brush   = UI::FFI::DrawBrush.malloc
brush.to_ptr.free = Fiddle::RUBY_FREE

handler_draw_event = Fiddle::Closure::BlockCaller.new(0, [1, 1, 1]) do |_, _, area_draw_params|
  area_draw_params = UI::FFI::AreaDrawParams.new(area_draw_params)
  context = area_draw_params.Context

  area_width = area_draw_params.AreaWidth
  area_height = area_draw_params.AreaHeight

  layout = tree_map.compute_layout(0, 0, area_width, area_height)

  layout.each do |rect|
    path = UI.draw_new_path(0)
    UI.draw_path_add_rectangle(path, rect[:x], rect[:y], rect[:width], rect[:height])
    UI.draw_path_end(path)

    brush.Type = 0
    brush.R = rand
    brush.G = rand
    brush.B = rand
    brush.A = 1.0

    UI.draw_fill(context, path, brush.to_ptr)
    UI.draw_free_path(path)
  end
end

do_nothing = Fiddle::Closure::BlockCaller.new(0, [0]) {}
key_event  = Fiddle::Closure::BlockCaller.new(1, [0]) { 0 }

handler.Draw = handler_draw_event
handler.MouseEvent   = do_nothing
handler.MouseCrossed = do_nothing
handler.DragBroken   = do_nothing
handler.KeyEvent     = key_event

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.box_append(box, area, 1)

footer = UI.new_horizontal_box
@path_label = UI.new_label("Path: #{xml_file}")
@size_label = UI.new_label("Size: #{file_tree.size} bytes")
UI.box_append(footer, @path_label, 0)
UI.box_append(footer, @size_label, 1)
UI.box_append(box, footer, 0)

@details_label = UI.new_label('No file selected')
UI.box_append(box, @details_label, 0)

UI.window_set_child(@main_window, box)

UI.window_on_closing(@main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

UI.control_show(@main_window)
UI.main
UI.uninit
