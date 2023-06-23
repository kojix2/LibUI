#!/usr/bin/env ruby
# frozen_string_literal: true

require 'libui'
require 'onnxruntime'
require 'blingfire'
require 'numo/narray'

# GPT-2 model
# Transformer-based language model for text generation.
# https://github.com/onnx/models/tree/main/text/machine_comprehension/gpt-2

Dir.chdir(__dir__) do
  %w[
    https://github.com/microsoft/BlingFire/raw/master/dist-pypi/blingfire/gpt2.bin
    https://github.com/microsoft/BlingFire/raw/master/dist-pypi/blingfire/gpt2.i2w
    https://github.com/onnx/models/raw/main/text/machine_comprehension/gpt-2/model/gpt2-lm-head-10.onnx
  ].each do |url|
    fname = File.basename(url)
    next if File.exist?(fname)

    print "Downloading #{fname}..."
    require 'open-uri'
    File.binwrite(fname, URI.open(url).read)
    puts 'done'
  end
  @encoder = BlingFire.load_model('gpt2.bin')
  @decoder = BlingFire.load_model('gpt2.i2w')
  @model = OnnxRuntime::Model.new('gpt2-lm-head-10.onnx')
end

def softmax(y)
  Numo::NMath.exp(y) / Numo::NMath.exp(y).sum(1, keepdims: true)
end

def predict(a, prob: true)
  outputs = @model.predict({ input1: [[a]] })
  logits = Numo::DFloat.cast(outputs['output1'][0])
  logits = logits[true, -1, true]
  return logits.argmax unless prob

  log_probs = softmax(logits)
  cum_probs = log_probs.cumsum(1)
  r = rand(0..cum_probs[-1]) # 0..1
  (cum_probs < r).count
end

def predict_text(s, max = 30)
  a = @encoder.text_to_ids(s)
  max.times do
    id = predict(a)
    a << id
    break if id == 13 # .
  end
  @decoder.ids_to_text(a)
end

# GUI
UI = LibUI

UI.init

main_window = UI.new_window('GPT-2 Notepad', 500, 300, 1)
UI.window_on_closing(main_window) do
  puts 'Bye Bye'
  UI.quit
  1
end

hbox = UI.new_vertical_box
UI.box_set_padded(hbox, 1)
UI.window_set_child(main_window, hbox)

bbox = UI.new_horizontal_box
UI.box_append(hbox, bbox, 0)
clear_button = UI.new_button('Clear')
write_button = UI.new_button('Continue the sentence(s)')
UI.box_append(bbox, clear_button, 1)
UI.box_append(bbox, write_button, 1)

entry = UI.new_multiline_entry
UI.box_append(hbox, entry, 1)

UI.button_on_clicked(clear_button) do
  UI.multiline_entry_set_text(entry, '')
end

UI.button_on_clicked(write_button) do
  s = UI.multiline_entry_text(entry).to_s
  if s.empty?
    UI.msg_box(main_window, 'Empty!', 'Please enter some text first.')
  else
    s2 = predict_text(s)
    UI.multiline_entry_set_text(entry, s2)
  end
end

UI.control_show(main_window)
UI.main
UI.uninit