#!/usr/bin/env ruby

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

brush = UI::Brush.new(color: [0.9, 0.2, 0.6, 1.0])
stroke_params = UI::StrokeParams.new

handler = UI::AreaHandler.new(draw: ->(event) do
  UI::Path.open do |path|
    stream.spec.each.with_index do |i, j|
      path.new_figure(10 + j, 121).line_to(10 + j, 120 - [i, 120].min)
    end
    path.end_path
    event.context.stroke(path, brush, stroke_params)
  end
end)
area = UI.new_area(handler)

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.box_append(box, area, 1)

main_window = UI.new_window('SPECTRUM', 560, 150, 1)
UI.window_set_margined(main_window, 1)
UI.window_set_child(main_window, box)

UI.window_on_closing(main_window) do
  UI.quit
  stream.close
  ::FFI::PortAudio::API.Pa_Terminate
  1
end
UI.control_show(main_window)

UI.queue_main do
  UI.timer(100) do
    UI.area_queue_redraw_all(area)
    1
  end
end
UI.main
UI.uninit
