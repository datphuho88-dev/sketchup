# frozen_string_literal: true

require 'sketchup.rb'
require 'extensions.rb'

module VADA
  module QuickToolFinder
    EXTENSION = SketchupExtension.new('Tìm Công Cụ Nhanh', 'quick_tool_finder/main') unless const_defined?(:EXTENSION, false)
    EXTENSION.description = 'Tìm, chạy, đặt tên gợi nhớ, gán phím tắt, ghim, gỡ ghim, phân nhóm và ẩn/hiện từng nhóm công cụ SketchUp.'
    EXTENSION.version = '0.4.6'
    EXTENSION.creator = 'VADA / datphuho88-dev'
    EXTENSION.copyright = '2026 VADA'

    Sketchup.register_extension(EXTENSION, true)
  end
end
