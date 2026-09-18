# frozen_string_literal: true

require 'sketchup.rb'
require 'extensions.rb'

module VADA
  module TongDoDaiCanh
    EXTENSION_NAME = 'VADA - Tính tổng độ dài cạnh'
    VERSION = '1.0.1'

    unless file_loaded?(__FILE__)
      extension = SketchupExtension.new(EXTENSION_NAME, 'vada_tong_do_dai_canh/main')
      extension.description = 'Click trực tiếp các cạnh nằm trong Group/Component để xem chiều dài từng cạnh và tổng độ dài.'
      extension.version = VERSION
      extension.creator = 'Công ty TNHH VADA'
      extension.copyright = '© 2026 Công ty TNHH VADA'
      Sketchup.register_extension(extension, true)
      file_loaded(__FILE__)
    end
  end
end
