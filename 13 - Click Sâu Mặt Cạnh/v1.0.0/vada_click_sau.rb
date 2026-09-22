# encoding: UTF-8
require 'sketchup.rb'
require 'extensions.rb'

module VADA
  module ClickSau
    EXTENSION_NAME = 'VADA - Click Sâu Mặt Cạnh'.freeze
    VERSION = '1.0.0'.freeze
    LOADER = File.join(__dir__, 'vada_click_sau', 'main.rb')

    unless file_loaded?(__FILE__)
      extension = SketchupExtension.new(EXTENSION_NAME, LOADER)
      extension.description = 'Chọn trực tiếp Face/Edge nằm sâu trong nhiều lớp Group/Component mà không cần mở từng cấp.'
      extension.version = VERSION
      extension.creator = 'Công ty TNHH VADA'
      extension.copyright = '2026 Công ty TNHH VADA'
      Sketchup.register_extension(extension, true)
      file_loaded(__FILE__)
    end
  end
end
