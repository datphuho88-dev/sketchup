# frozen_string_literal: true

require 'sketchup.rb'
require 'json'

module VADA
  module TongDoDaiCanh
    PLUGIN_NAME = 'VADA - Tính tổng độ dài cạnh'
    VERSION = '1.0.0' unless const_defined?(:VERSION)
    ICON_DIR = File.join(__dir__, 'icons')
    HTML_FILE = File.join(__dir__, 'ui.html')

    IN_TO_M  = 0.0254
    IN_TO_CM = 2.54
    IN_TO_MM = 25.4

    class EdgeLengthTool
      def initialize
        @items = {}
        @dialog = nil
        @unit = 'm'
        @hover_pick = nil
      end

      def activate
        show_dialog
        Sketchup.status_text = 'VADA: Click cạnh trong Group/Component để thêm/bỏ. ESC: xóa toàn bộ.'
        Sketchup.active_model.active_view.invalidate
      end

      def deactivate(view)
        @hover_pick = nil
        view.invalidate if view
      end

      def onCancel(_reason, view)
        clear_all
        view.invalidate
      end

      def onMouseMove(_flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        @hover_pick = first_edge_pick(ph)
        view.invalidate
      rescue StandardError
        @hover_pick = nil
      end

      def onLButtonDown(_flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        pick = first_edge_pick(ph)

        unless pick
          UI.beep
          Sketchup.status_text = 'Không bắt được cạnh. Hãy click gần đúng đường cạnh cần đo.'
          return
        end

        path, edge, tr = pick
        key = path_key(path, edge)

        if @items.key?(key)
          @items.delete(key)
        else
          @items[key] = build_item(key, path, edge, tr)
        end

        sync_dialog
        view.invalidate
      rescue StandardError => e
        UI.messagebox("Lỗi khi đo độ dài cạnh:\n#{e.message}")
      end

      def draw(view)
        draw_hover(view)
        draw_selected(view)
        draw_hud(view)
      rescue StandardError
        # Không để lỗi hiển thị làm gián đoạn thao tác click.
      end

      def clear_all
        @items.clear
        sync_dialog
        Sketchup.active_model.active_view.invalidate
      end

      def remove_item(key)
        @items.delete(key.to_s)
        sync_dialog
        Sketchup.active_model.active_view.invalidate
      end

      def set_unit(unit)
        @unit = %w[m cm mm].include?(unit.to_s) ? unit.to_s : 'm'
        sync_dialog
        Sketchup.active_model.active_view.invalidate
      end

      private

      def first_edge_pick(ph)
        (0...ph.count).each do |i|
          path = ph.path_at(i)
          next unless path && !path.empty?

          edge = path.reverse.find { |e| e.is_a?(Sketchup::Edge) }
          next unless edge && edge.valid?

          tr = ph.transformation_at(i)
          tr = Geom::Transformation.new unless tr.is_a?(Geom::Transformation)
          return [path, edge, tr]
        end
        nil
      end

      def path_key(path, edge)
        ids = path.map do |e|
          if e.respond_to?(:persistent_id)
            e.persistent_id
          else
            e.object_id
          end
        end
        ids << edge.persistent_id unless ids.include?(edge.persistent_id)
        ids.join('-')
      end

      def build_item(key, path, edge, tr)
        p1 = edge.start.position.transform(tr)
        p2 = edge.end.position.transform(tr)
        length_in = p1.distance(p2).to_f.abs
        midpoint = Geom.linear_combination(0.5, p1, 0.5, p2)

        {
          key: key,
          length_in: length_in,
          midpoint: midpoint,
          points: [p1, p2],
          edge_pid: edge.persistent_id,
          depth: path.length,
          edge: edge
        }
      end

      def converted_length(length_in)
        case @unit
        when 'cm' then length_in * IN_TO_CM
        when 'mm' then length_in * IN_TO_MM
        else length_in * IN_TO_M
        end
      end

      def unit_label
        { 'm' => 'm', 'cm' => 'cm', 'mm' => 'mm' }[@unit] || 'm'
      end

      def decimals
        case @unit
        when 'mm' then 0
        when 'cm' then 1
        else 3
        end
      end

      def fmt(length_in)
        format("%.#{decimals}f", converted_length(length_in))
      end

      def total_in
        @items.values.sum { |it| it[:length_in] }
      end

      def draw_selected(view)
        @items.values.each_with_index do |item, index|
          next unless item[:edge]&.valid?
          pts = item[:points]

          view.line_width = 5
          view.drawing_color = Sketchup::Color.new(0, 220, 255, 255)
          view.draw(GL_LINES, pts)

          screen = view.screen_coords(item[:midpoint])
          text = "#{index + 1}. #{fmt(item[:length_in])} #{unit_label}"
          view.draw_text(screen, text, color: Sketchup::Color.new(255, 255, 255), size: 14, bold: true)
        end
      end

      def draw_hover(view)
        return unless @hover_pick
        _path, edge, tr = @hover_pick
        return unless edge&.valid?

        p1 = edge.start.position.transform(tr)
        p2 = edge.end.position.transform(tr)
        view.line_width = 3
        view.drawing_color = Sketchup::Color.new(255, 190, 0, 255)
        view.draw(GL_LINES, [p1, p2])
      end

      def draw_hud(view)
        text = "TỔNG: #{fmt(total_in)} #{unit_label}   |   #{@items.length} cạnh"
        view.draw_text([18, 30], text, color: Sketchup::Color.new(255, 255, 255), size: 17, bold: true)
      end

      def show_dialog
        if @dialog && @dialog.visible?
          @dialog.bring_to_front
          sync_dialog
          return
        end

        @dialog = UI::HtmlDialog.new(
          dialog_title: "Tính tổng độ dài cạnh • v#{VERSION}",
          preferences_key: 'vada_tong_do_dai_canh',
          scrollable: true,
          resizable: true,
          width: 430,
          height: 560,
          min_width: 340,
          min_height: 360,
          style: UI::HtmlDialog::STYLE_DIALOG
        )

        @dialog.set_file(HTML_FILE)
        @dialog.add_action_callback('clearAll') { |_ctx| clear_all }
        @dialog.add_action_callback('removeEdge') { |_ctx, key| remove_item(key) }
        @dialog.add_action_callback('setUnit') { |_ctx, unit| set_unit(unit) }
        @dialog.add_action_callback('uiReady') { |_ctx| sync_dialog }
        @dialog.set_on_closed { @dialog = nil }
        @dialog.show
      end

      def sync_dialog
        return unless @dialog

        rows = @items.values.each_with_index.map do |it, index|
          {
            index: index + 1,
            key: it[:key],
            length: fmt(it[:length_in]),
            unit: unit_label,
            depth: it[:depth]
          }
        end

        payload = {
          version: VERSION,
          unit: @unit,
          unit_label: unit_label,
          count: rows.length,
          total: fmt(total_in),
          rows: rows
        }

        js = "window.VADA_EDGE && window.VADA_EDGE.update(#{JSON.generate(payload)});"
        @dialog.execute_script(js)
      rescue StandardError
        # Dialog có thể chưa nạp xong; HTML sẽ gọi uiReady sau khi khởi tạo.
      end
    end

    class << self
      def tool
        @tool ||= EdgeLengthTool.new
      end

      def activate_tool
        Sketchup.active_model.select_tool(tool)
      end

      def setup_ui
        command = UI::Command.new('Tính tổng độ dài cạnh') { activate_tool }
        command.tooltip = 'Tính tổng độ dài cạnh'
        command.status_bar_text = 'Click trực tiếp các cạnh trong Group/Component để cộng tổng độ dài.'
        command.small_icon = File.join(ICON_DIR, 'edge_24.png')
        command.large_icon = File.join(ICON_DIR, 'edge_32.png')

        toolbar = UI::Toolbar.new('VADA - Độ dài cạnh')
        toolbar.add_item(command)
        toolbar.restore

        menu = UI.menu('Extensions').add_submenu('VADA')
        menu.add_item(command)
      end
    end

    unless file_loaded?(__FILE__)
      setup_ui
      file_loaded(__FILE__)
    end
  end
end
