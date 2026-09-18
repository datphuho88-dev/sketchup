# frozen_string_literal: true
require 'sketchup.rb'
require 'extensions.rb'

module VADA
  module PluginManager
    EXTENSION_NAME = 'VADA Plugin Manager'
    VERSION = '1.0.0'

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new(EXTENSION_NAME, 'vada_plugin_manager/main')
      ex.description = 'Quản lý, kiểm tra cập nhật và nạp lại nhanh các plugin VADA.'
      ex.version = VERSION
      ex.creator = 'Công ty TNHH VADA'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end
  end
end
