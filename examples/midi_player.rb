# frozen_string_literal: true

require 'libui'

music_directory = File.expand_path(ARGV[0] || '~/Music/')
midi_files      = Dir.glob(File.join(music_directory, '**/*.mid'))
                     .sort_by { |path| File.basename(path) }
VERSION = '0.0.1'

@pid = nil

UI = LibUI

init = UI.init

play_midi = proc do
  if @pid.nil? && @selected_file
    begin
      @pid = spawn "timidity #{@selected_file}"
      @th = Process.detach @pid
    rescue Errno::ENOENT => e
      warn 'Timidty++ not found. Please install Timidity++.'
      warn 'https://sourceforge.net/projects/timidity/'
    end
  end
  0
end

stop_midi = proc do
  if @pid
    if @th.alive?
      Process.kill(:SIGKILL, @pid)
      @pid = nil
    else
      @pid = nil
    end
  end
end

help_menu = UI.new_menu('Help')
version_item = UI.menu_append_item(help_menu, 'Version')

UI.new_window('Tiny Midi Player', 200, 50, 1).tap do |main_window|
  UI.menu_item_on_clicked(version_item) do
    UI.msg_box(main_window,
               'Tiny Midi Player',
               "Written in Ruby\n" \
               "https://github.com/kojix2/libui\n" \
               "Version #{VERSION}")
    0
  end

  UI.window_on_closing(main_window) do
    UI.control_destroy(main_window)
    UI.quit
    0
  end

  UI.new_horizontal_box.tap do |hbox|
    UI.new_vertical_box.tap do |vbox|
      UI.new_button('▶').tap do |button1|
        UI.button_on_clicked(button1, play_midi)
        UI.box_append(vbox, button1, 1)
      end
      UI.new_button('■').tap do |button2|
        UI.button_on_clicked(button2, stop_midi)
        at_exit(&stop_midi)
        UI.box_append(vbox, button2, 1)
      end
      UI.box_append(hbox, vbox, 0)
    end
    UI.window_set_child(main_window, hbox)

    UI.new_combobox.tap do |cbox|
      midi_files.each do |path|
        name = File.basename(path)
        UI.combobox_append(cbox, name)
      end
      UI.combobox_on_selected(cbox) do |ptr|
        @selected_file = midi_files[UI.combobox_selected(ptr)]
        if @th&.alive?
          stop_midi.call
          play_midi.call
        end
        0
      end
      UI.box_append(hbox, cbox, 1)
    end
  end
  UI.control_show(main_window)
end

UI.main
UI.quit
