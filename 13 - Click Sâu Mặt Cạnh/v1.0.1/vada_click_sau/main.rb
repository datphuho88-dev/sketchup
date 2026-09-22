# encoding: UTF-8
require 'sketchup.rb'

module VADA
  module ClickSau
    VERSION = '1.0.1'.freeze unless const_defined?(:VERSION)
    TOOL_NAME = 'Click Sâu Mặt/Cạnh'.freeze

    class DeepPickTool
      def initialize
        @hover_entity = nil
        @hover_path = nil
        @tooltip = nil
      end

      def activate
        Sketchup.set_status_text("#{TOOL_NAME} v#{VERSION} — Click để chọn Face/Edge sâu bên trong Group/Component. Shift: thêm/bớt chọn. Esc: thoát.")
      end

      def deactivate(view)
        @hover_entity = nil
        @hover_path = nil
        view.invalidate if view
        Sketchup.set_status_text('')
      end

      def onCancel(_reason, view)
        Sketchup.active_model.select_tool(nil)
        view.invalidate
      end

      def onMouseMove(_flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        path = deepest_pick_path(ph)
        entity = path && path.last

        if entity != @hover_entity || path != @hover_path
          @hover_entity = entity
          @hover_path = path
          @tooltip = tooltip_for(path)
          view.tooltip = @tooltip if @tooltip
          view.invalidate
        end
      end

      def onLButtonDown(flags, x, y, view)
        model = Sketchup.active_model

        # Luôn pick từ cấp ngoài cùng để có thể xuyên qua toàn bộ cây lồng nhau.
        model.active_path = nil if model.active_path

        ph = view.pick_helper
        ph.do_pick(x, y)
        path = deepest_pick_path(ph)
        entity = path && path.last
        return unless entity && entity.valid?

        instance_path = path[0...-1].select { |item|
          item.is_a?(Sketchup::Group) || item.is_a?(Sketchup::ComponentInstance)
        }

        begin
          model.active_path = instance_path unless instance_path.empty?
        rescue ArgumentError
          UI.beep
          Sketchup.set_status_text('Không thể mở đường dẫn lồng nhau tại vị trí này.')
          return
        end

        sel = model.selection
        shift = (flags & CONSTRAIN_MODIFIER_MASK) != 0 rescue false
        sel.clear unless shift

        if shift && sel.contains?(entity)
          sel.remove(entity)
        else
          sel.add(entity)
        end

        # Sau khi đã vào đúng edit-context, trả về Select Tool để chỉnh sửa ngay.
        model.select_tool(nil)
      end

      def draw(view)
        return unless @hover_entity && @hover_entity.valid? && @hover_path

        tr = path_transform(@hover_path)

        case @hover_entity
        when Sketchup::Face
          draw_face_outline(view, @hover_entity, tr)
        when Sketchup::Edge
          draw_edge(view, @hover_entity, tr)
        end
      rescue StandardError
        # Không để lỗi vẽ preview làm hỏng thao tác chọn.
      end

      private

      def deepest_pick_path(ph)
        best = nil
        count = ph.count
        (0...count).each do |i|
          path = ph.path_at(i)
          next unless path && !path.empty?
          leaf = path.last
          next unless leaf.is_a?(Sketchup::Face) || leaf.is_a?(Sketchup::Edge)
          best = path if best.nil? || path.length > best.length
        end
        best
      rescue StandardError
        nil
      end

      def path_transform(path)
        tr = Geom::Transformation.new
        path[0...-1].each do |item|
          if item.respond_to?(:transformation)
            tr = tr * item.transformation
          end
        end
        tr
      end

      def draw_face_outline(view, face, tr)
        pts = face.outer_loop.vertices.map { |v| v.position.transform(tr) }
        return if pts.length < 3

        # Preview mặt bằng lớp đỏ bán trong suốt, viền đỏ rõ nét.
        view.drawing_color = Sketchup::Color.new(255, 0, 0, 70)
        view.draw(GL_POLYGON, pts)

        view.drawing_color = Sketchup::Color.new(255, 0, 0)
        view.line_width = 3
        view.line_stipple = ''
        view.draw(GL_LINE_LOOP, pts)
      end

      def draw_edge(view, edge, tr)
        pts = [edge.start.position.transform(tr), edge.end.position.transform(tr)]
        view.drawing_color = Sketchup::Color.new(255, 0, 0)
        view.line_width = 4
        view.line_stipple = ''
        view.draw(GL_LINES, pts)
      end

      def tooltip_for(path)
        return nil unless path && !path.empty?
        leaf = path.last
        type = leaf.is_a?(Sketchup::Face) ? 'Mặt' : 'Cạnh'
        depth = [path.length - 1, 0].max
        "#{type} • sâu #{depth} lớp • #{TOOL_NAME} v#{VERSION}"
      end
    end

    def self.activate_tool
      Sketchup.active_model.select_tool(DeepPickTool.new)
    end

    def self.show_about
      UI.messagebox("VADA - Click Sâu Mặt Cạnh\nPhiên bản v#{VERSION}\n\nClick trực tiếp Face/Edge nằm sâu trong Group/Component mà không cần mở từng cấp.\nShift + Click: thêm/bớt đối tượng trong vùng chọn.\nEsc: thoát công cụ.")
    end

    unless file_loaded?(__FILE__)
      cmd = UI::Command.new("Click Sâu Mặt/Cạnh v#{VERSION}") { activate_tool }
      cmd.tooltip = "Click Sâu Mặt/Cạnh v#{VERSION}"
      cmd.status_bar_text = 'Chọn trực tiếp Face/Edge sâu trong Group/Component.'

      small_icon = File.join(__dir__, 'icon_16.png')
      large_icon = File.join(__dir__, 'icon_24.png')
      cmd.small_icon = small_icon if File.exist?(small_icon)
      cmd.large_icon = large_icon if File.exist?(large_icon)

      toolbar = UI::Toolbar.new('VADA - Click Sâu')
      toolbar.add_item(cmd)
      toolbar.show

      menu = UI.menu('Extensions').add_submenu('VADA - Click Sâu Mặt Cạnh')
      menu.add_item(cmd)
      menu.add_separator
      menu.add_item("Giới thiệu v#{VERSION}") { show_about }

      file_loaded(__FILE__)
    end
  end
end
