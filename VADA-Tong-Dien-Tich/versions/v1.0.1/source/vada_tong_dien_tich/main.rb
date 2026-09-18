# frozen_string_literal: true

require 'sketchup.rb'
require 'json'

module VADA
  module TongDienTich
    PLUGIN_NAME = 'VADA - Tính tổng diện tích mặt'
    VERSION = '1.0.1' unless const_defined?(:VERSION)
    ICON_DIR = File.join(__dir__, 'icons')
    HTML_FILE = File.join(__dir__, 'ui.html')

    IN2_TO_M2  = 0.00064516
    IN2_TO_CM2 = 6.4516
    IN2_TO_MM2 = 645.16

    class AreaTool
      def initialize
        @items = {}
        @dialog = nil
        @unit = 'm2'
        @hover_path = nil
      end

      def activate
        show_dialog
        Sketchup.status_text = 'VADA: Click mặt trong Group/Component để thêm/bỏ. ESC: xóa toàn bộ.'
        Sketchup.active_model.active_view.invalidate
      end

      def deactivate(view)
        @hover_path = nil
        view.invalidate if view
      end

      def onCancel(_reason, view)
        clear_all
        view.invalidate
      end

      def onMouseMove(_flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        @hover_path = first_face_pick(ph)
        view.invalidate
      rescue StandardError
        @hover_path = nil
      end

      def onLButtonDown(_flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        pick = first_face_pick(ph)

        unless pick
          UI.beep
          Sketchup.status_text = 'Không bắt được mặt. Hãy click vào vùng bên trong mặt, tránh click đúng cạnh.'
          return
        end

        path, face, tr = pick
        key = path_key(path, face)

        if @items.key?(key)
          @items.delete(key)
        else
          @items[key] = build_item(key, path, face, tr)
        end

        sync_dialog
        view.invalidate
      rescue StandardError => e
        UI.messagebox("Lỗi khi đo diện tích:\n#{e.message}")
      end

      def draw(view)
        draw_hover(view)
        draw_selected(view)
        draw_hud(view)
      rescue StandardError
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
        @unit = %w[m2 cm2 mm2].include?(unit.to_s) ? unit.to_s : 'm2'
        sync_dialog
        Sketchup.active_model.active_view.invalidate
      end

      private

      def first_face_pick(ph)
        (0...ph.count).each do |i|
          path = ph.path_at(i)
          next unless path && !path.empty?

          face = path.reverse.find { |e| e.is_a?(Sketchup::Face) }
          next unless face && face.valid?

          tr = ph.transformation_at(i)
          tr = Geom::Transformation.new unless tr.is_a?(Geom::Transformation)
          return [path, face, tr]
        end
        nil
      end

      def path_key(path, face)
        ids = path.map do |e|
          if e.respond_to?(:persistent_id)
            e.persistent_id
          else
            e.object_id
          end
        end
        ids << face.persistent_id unless ids.include?(face.persistent_id)
        ids.join('-')
      end

      def build_item(key, path, face, tr)
        area_in2 = face.area(tr).to_f.abs
        center = face.bounds.center.transform(tr)
        outer = face.outer_loop.vertices.map { |v| v.position.transform(tr) }

        {
          key: key,
          area_in2: area_in2,
          center: center,
          points: outer,
          face_pid: face.persistent_id,
          depth: path.length,
          face: face
        }
      end

      def converted_area(area_in2)
        case @unit
        when 'cm2' then area_in2 * IN2_TO_CM2
        when 'mm2' then area_in2 * IN2_TO_MM2
        else area_in2 * IN2_TO_M2
        end
      end

      def unit_label
        { 'm2' => 'm²', 'cm2' => 'cm²', 'mm2' => 'mm²' }[@unit] || 'm²'
      end

      def decimals
        case @unit
        when 'mm2' then 0
        when 'cm2' then 1
        else 3
        end
      end

      def fmt(area_in2)
        format("%.#{decimals}f", converted_area(area_in2))
      end

      def total_in2
        @items.values.sum { |it| it[:area_in2] }
      end

      def draw_selected(view)
        @items.values.each_with_index do |item, index|
          next unless item[:face]&.valid?
          pts = item[:points]
          next if pts.length < 3

          view.line_width = 4
          view.drawing_color = Sketchup::Color.new(0, 220, 255, 255)
          view.draw(GL_LINE_LOOP, pts)

          screen = view.screen_coords(item[:center])
          x = screen.x + 10
          y = screen.y - 10

          badge_text = "##{index + 1}"
          badge_options = { color: Sketchup::Color.new(255, 255, 255), size: 12, bold: true }
          badge_width = draw_text_box(
            view,
            Geom::Point3d.new(x, y, 0),
            badge_text,
            badge_options,
            Sketchup::Color.new(0, 95, 125, 235),
            5,
            3
          )

          value_text = "#{fmt(item[:area_in2])} #{unit_label}"
          value_options = { color: Sketchup::Color.new(255, 45, 45), size: 14, bold: true }
          draw_text_box(
            view,
            Geom::Point3d.new(x + badge_width + 6, y - 1, 0),
            value_text,
            value_options,
            Sketchup::Color.new(18, 18, 18, 225),
            7,
            4
          )
        end
      end

      def draw_text_box(view, position, text, text_options, background_color, padding_x, padding_y)
        bounds = view.text_bounds(position, text, text_options)
        x1, y1 = bounds.upper_left.to_a
        x2, y2 = bounds.lower_right.to_a

        points = [
          Geom::Point3d.new(x1 - padding_x, y1 - padding_y, 0),
          Geom::Point3d.new(x1 - padding_x, y2 + padding_y, 0),
          Geom::Point3d.new(x2 + padding_x, y2 + padding_y, 0),
          Geom::Point3d.new(x2 + padding_x, y1 - padding_y, 0)
        ]

        view.drawing_color = background_color
        view.draw2d(GL_QUADS, points)
        view.draw_text(position, text, text_options)

        (x2 - x1).abs + (padding_x * 2)
      rescue StandardError
        view.draw_text(position, text, text_options)
        (text.length * 8) + (padding_x * 2)
      end

      def draw_hover(view)
        return unless @hover_path
        _path, face, tr = @hover_path
        return unless face&.valid?

        pts = face.outer_loop.vertices.map { |v| v.position.transform(tr) }
        return if pts.length < 3

        view.line_width = 2
        view.drawing_color = Sketchup::Color.new(255, 190, 0, 255)
        view.draw(GL_LINE_LOOP, pts)
      end

      def draw_hud(view)
        text = "TỔNG: #{fmt(total_in2)} #{unit_label}   |   #{@items.length} mặt"
        draw_text_box(
          view,
          Geom::Point3d.new(18, 30, 0),
          text,
          { color: Sketchup::Color.new(255, 70, 70), size: 17, bold: true },
          Sketchup::Color.new(10, 10, 10, 220),
          8,
          5
        )
      end

      def show_dialog
        if @dialog && @dialog.visible?
          @dialog.bring_to_front
          sync_dialog
          return
        end

        @dialog = UI::HtmlDialog.new(
          dialog_title: "Tính tổng diện tích • v#{VERSION}",
          preferences_key: 'vada_tong_dien_tich',
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
        @dialog.add_action_callback('removeFace') { |_ctx, key| remove_item(key) }
        @dialog.add_action_callback('setUnit') { |_ctx, unit| set_unit(unit) }
        @dialog.add_action_callback('uiReady') { |_ctx| sync_dialog }
        @dialog.set_on_closed { @dialog = nil }
        @dialog.show
        sync_dialog
      end

      def sync_dialog
        return unless @dialog

        rows = @items.values.each_with_index.map do |it, index|
          {
            index: index + 1,
            key: it[:key],
            area: fmt(it[:area_in2]),
            unit: unit_label,
            depth: it[:depth]
          }
        end

        payload = {
          version: VERSION,
          unit: @unit,
          unit_label: unit_label,
          count: rows.length,
          total: fmt(total_in2),
          rows: rows
        }

        js = "window.VADA_AREA && window.VADA_AREA.update(#{JSON.generate(payload)});"
        @dialog.execute_script(js)
      rescue StandardError
      end
    end

    class << self
      def tool
        @tool ||= AreaTool.new
      end

      def activate_tool
        Sketchup.active_model.select_tool(tool)
      end

      def setup_ui
        command = UI::Command.new('Tính tổng diện tích mặt') { activate_tool }
        command.tooltip = 'Tính tổng diện tích mặt'
        command.status_bar_text = 'Click trực tiếp các mặt trong Group/Component để cộng diện tích.'
        command.small_icon = File.join(ICON_DIR, 'area_24.png')
        command.large_icon = File.join(ICON_DIR, 'area_32.png')

        toolbar = UI::Toolbar.new('VADA - Diện tích')
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
