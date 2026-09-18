# frozen_string_literal: true

require 'sketchup.rb'
require 'extensions.rb'

module VADA
  module TongDienTich
    EXTENSION_NAME = 'VADA - Tính tổng diện tích mặt'
    VERSION = '1.0.0'

    unless file_loaded?(__FILE__)
      extension = SketchupExtension.new(EXTENSION_NAME, 'vada_tong_dien_tich/main')
      extension.description = 'Click trực tiếp các mặt nằm trong Group/Component để xem diện tích từng mặt và tổng diện tích.'
      extension.version = VERSION
      extension.creator = 'Công ty TNHH VADA'
      extension.copyright = '© 2026 Công ty TNHH VADA'
      Sketchup.register_extension(extension, true)
      file_loaded(__FILE__)
    end
  end
end
