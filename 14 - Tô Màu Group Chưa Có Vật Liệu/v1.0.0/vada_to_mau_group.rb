# frozen_string_literal: true

require 'sketchup.rb'
require 'extensions.rb'

module VADA
  module ToMauGroup
    PLUGIN_NAME = 'VADA - Tô Màu Group Chưa Có Vật Liệu'
    VERSION = '1.0.0'
    ROOT_FILE = File.basename(__FILE__)
    LOADER_PATH = File.join(__dir__, 'vada_to_mau_group', 'main')

    unless file_loaded?(__FILE__)
      extension = SketchupExtension.new(PLUGIN_NAME, LOADER_PATH)
      extension.description = 'Tự động tô mỗi Group chưa được gán vật liệu bằng một màu khác nhau.'
      extension.version = VERSION
      extension.creator = 'VADA'
      extension.copyright = 'VADA'
      Sketchup.register_extension(extension, true)
      file_loaded(__FILE__)
    end
  end
end
