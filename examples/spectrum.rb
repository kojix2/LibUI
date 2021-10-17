#! /usr/bin/env ruby

# Please play your favorite music or video on your computer
# when running this spectrum example.

require 'libui'
require 'ffi-portaudio'  # https://github.com/nanki/ffi-portaudio
require 'numo/pocketfft' # https://github.com/yoshoku/numo-pocketfft

# ---------------------------------------------------------------------------- #

class FFTStream < FFI::PortAudio::Stream
  def process(input, _output, frame_count, _time_info, _status_flags, _user_data)
    i = Numo::Int16.cast(input.read_array_of_int16(frame_count))
    @spec = (Numo::Pocketfft.rfft(i)[0..511].abs / 1000.0).to_a
    :paContinue
  end

  def spec
    @spec || [0] * 512
  end
end

FFI::PortAudio::API.Pa_Initialize

input = FFI::PortAudio::API::PaStreamParameters.new
input[:device] = FFI::PortAudio::API.Pa_GetDefaultInputDevice
input[:channelCount] = 1
input[:sampleFormat] = FFI::PortAudio::API::Int16
input[:suggestedLatency] = 0
input[:hostApiSpecificStreamInfo] = nil
stream = FFTStream.new
stream.open(input, nil, 44_100, 1024)
stream.start

# ---------------------------------------------------------------------------- #

UI = LibUI

UI.init

handler = UI::FFI::AreaHandler.malloc
area    = UI.new_area(handler)

brush = UI::FFI::DrawBrush.malloc.tap do |b|
  b.Type = 0
  b.R = 0.9
  b.G = 0.2
  b.B = 0.6
  b.A = 1.0
end

dashes = Fiddle::Pointer.malloc(8, Fiddle::RUBY_FREE)
stroke_params = UI::FFI::DrawStrokeParams.malloc.tap do |sp|
  sp.Cap = UI::DrawLineCapFlat
  sp.Join = UI::DrawLineJoinMiter
  sp.MiterLimit = 10
  sp.Dashes = dashes
  sp.NumDashes = 0
  sp.DashPhase = 0
  sp.Thickness = 1.0
end

handler_draw_event = Fiddle::Closure::BlockCaller.new(0, [1, 1, 1]) do |_, _, area_draw_params|
  UI.draw_new_path(UI::DrawFillModeWinding).then do |path|
    stream.spec.each.with_index do |i, j|
      UI.draw_path_new_figure(path, 10 + j, 121)
      UI.draw_path_line_to(path, 10 + j, 120 - [i, 120].min)
    end
    UI.draw_path_end(path)

    area_draw_params = UI::FFI::AreaDrawParams.new(area_draw_params)
    UI.draw_stroke(area_draw_params.Context, path, brush.to_ptr, stroke_params)
    UI.draw_free_path(path)
  end
end

handler.Draw = handler_draw_event
n = Fiddle::Closure::BlockCaller.new(0, [0]) {}
handler.MouseEvent   = n
handler.MouseCrossed = n
handler.DragBroken   = n
handler.KeyEvent     = n

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.box_append(box, area, 1)

main_window = UI.new_window('SPECTRUM', 560, 150, 1)
UI.window_set_margined(main_window, 1)
UI.window_set_child(main_window, box)

UI.window_on_closing(main_window) do
  UI.control_destroy(main_window)
  UI.quit
  stream.close
  ::FFI::PortAudio::API.Pa_Terminate
  0
end
UI.control_show(main_window)
# FIXME
redraw = Fiddle::Closure::BlockCaller.new(4, [0]) do
  UI.area_queue_redraw_all(area)
  1
end
timer = proc do
  UI.timer(100, redraw)
end
UI.queue_main(&timer)
UI.main
UI.quit
