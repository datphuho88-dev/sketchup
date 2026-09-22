# frozen_string_literal: true

require 'sketchup.rb'
require 'json'

module VADA
  module ToMauGroup
    extend self

    PLUGIN_NAME = 'VADA - Tô Màu Group Chưa Có Vật Liệu' unless const_defined?(:PLUGIN_NAME)
    VERSION = '1.0.0' unless const_defined?(:VERSION)
    MATERIAL_PREFIX = 'VADA_Group_Auto_'
    ICON_SMALL = File.join(__dir__, 'icon_16.png')
    ICON_LARGE = File.join(__dir__, 'icon_24.png')

    def dialog
      return @dialog if @dialog && @dialog.visible?

      @dialog = UI::HtmlDialog.new(
        dialog_title: "#{PLUGIN_NAME} - v#{VERSION}",
        preferences_key: 'VADA.ToMauGroup',
        scrollable: false,
        resizable: false,
        width: 430,
        height: 340,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      @dialog.set_html(html)
      @dialog.add_action_callback('colorize') { |_ctx| colorize_unpainted_groups }
      @dialog.add_action_callback('close') { |_ctx| @dialog.close }
      @dialog.show
      @dialog
    end

    def html
      <<~HTML
        <!doctype html>
        <html lang="vi">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            * { box-sizing: border-box; }
            body { margin:0; background:#000000; color:#f2f2f2; font-family:Arial,sans-serif; }
            .wrap { padding:20px; }
            h1 { margin:0 0 6px; font-size:18px; }
            .ver { color:#8f8f8f; font-size:12px; margin-bottom:18px; }
            .box { border:1px solid #2e2e2e; border-radius:8px; padding:14px; background:#0b0b0b; line-height:1.45; font-size:13px; }
            button { width:100%; margin-top:16px; border:0; border-radius:8px; padding:13px 12px; font-size:14px; font-weight:700; cursor:pointer; }
            .primary { background:#ffffff; color:#000000; }
            .secondary { background:#1d1d1d; color:#ffffff; border:1px solid #3a3a3a; }
            #status { margin-top:14px; min-height:38px; color:#bdbdbd; font-size:13px; }
          </style>
        </head>
        <body>
          <div class="wrap">
            <h1>Tô Màu Group Chưa Có Vật Liệu</h1>
            <div class="ver">VADA • v#{VERSION}</div>
            <div class="box">
              Quét toàn bộ Group trong model, kể cả Group lồng nhau. Group đã có vật liệu sẽ được giữ nguyên. Mỗi Group chưa có vật liệu được gán một màu riêng để dễ phân biệt.
            </div>
            <button class="primary" onclick="run()">TÔ MÀU TẤT CẢ GROUP CHƯA CÓ VẬT LIỆU</button>
            <button class="secondary" onclick="sketchup.close()">ĐÓNG</button>
            <div id="status"></div>
          </div>
          <script>
            function run(){
              document.getElementById('status').innerText = 'Đang xử lý...';
              sketchup.colorize();
            }
            window.vadaResult = function(data){
              document.getElementById('status').innerText = data;
            };
          </script>
        </body>
        </html>
      HTML
    end

    def collect_groups(entities, out = [], seen_groups = {}, seen_definitions = {})
      entities.each do |entity|
        next unless entity.valid?

        if entity.is_a?(Sketchup::Group)
          key = entity.respond_to?(:persistent_id) ? entity.persistent_id : entity.object_id
          unless seen_groups[key]
            seen_groups[key] = true
            out << entity
            collect_groups(entity.entities, out, seen_groups, seen_definitions)
          end
        elsif entity.is_a?(Sketchup::ComponentInstance)
          definition = entity.definition
          def_key = definition.respond_to?(:persistent_id) ? definition.persistent_id : definition.object_id
          next if seen_definitions[def_key]

          seen_definitions[def_key] = true
          # Không tô Component Instance; chỉ quét Group nằm trong definition của component.
          collect_groups(definition.entities, out, seen_groups, seen_definitions)
        end
      end
      out
    end

    def colorize_unpainted_groups
      model = Sketchup.active_model
      groups = collect_groups(model.entities, [])
      targets = groups.select { |g| g.material.nil? }

      if targets.empty?
        push_result('Không có Group nào chưa được gán vật liệu.')
        return
      end

      model.start_operation('VADA - Tô màu Group chưa có vật liệu', true)
      begin
        used_names = {}
        targets.each_with_index do |group, index|
          material = create_material(model, index, used_names)
          group.material = material
        end
        model.commit_operation
        push_result("Đã tô màu #{targets.length} Group. Group đã có vật liệu được giữ nguyên.")
      rescue StandardError => e
        model.abort_operation
        UI.messagebox("Có lỗi khi tô màu:\n#{e.message}")
        push_result('Có lỗi khi xử lý. Đã hủy thay đổi.')
      end
    end

    def create_material(model, index, used_names)
      # Golden-angle hue distribution: màu cách nhau rõ hơn khi số lượng group lớn.
      hue = (index * 137.50776405) % 360.0
      saturation = 0.72
      lightness = 0.56
      r, g, b = hsl_to_rgb(hue / 360.0, saturation, lightness)

      base_name = format('%s%04d', MATERIAL_PREFIX, index + 1)
      name = base_name
      suffix = 1
      while model.materials[name] || used_names[name]
        suffix += 1
        name = "#{base_name}_#{suffix}"
      end
      used_names[name] = true

      material = model.materials.add(name)
      material.color = Sketchup::Color.new(r, g, b)
      material
    end

    def hsl_to_rgb(h, s, l)
      if s.zero?
        v = (l * 255).round
        return [v, v, v]
      end

      q = l < 0.5 ? l * (1.0 + s) : l + s - l * s
      p = 2.0 * l - q
      r = hue_to_rgb(p, q, h + 1.0 / 3.0)
      g = hue_to_rgb(p, q, h)
      b = hue_to_rgb(p, q, h - 1.0 / 3.0)
      [(r * 255).round, (g * 255).round, (b * 255).round]
    end

    def hue_to_rgb(p, q, t)
      t += 1.0 if t < 0.0
      t -= 1.0 if t > 1.0
      return p + (q - p) * 6.0 * t if t < 1.0 / 6.0
      return q if t < 1.0 / 2.0
      return p + (q - p) * (2.0 / 3.0 - t) * 6.0 if t < 2.0 / 3.0

      p
    end

    def push_result(message)
      return unless @dialog && @dialog.visible?
      @dialog.execute_script("window.vadaResult(#{message.to_json})")
    end

    unless file_loaded?(__FILE__)
      command = UI::Command.new('Tô Màu Group Chưa Có Vật Liệu') { dialog }
      command.tooltip = 'Tô Màu Group Chưa Có Vật Liệu'
      command.status_bar_text = 'Mỗi Group chưa có vật liệu được tô một màu khác nhau.'
      command.small_icon = ICON_SMALL if File.exist?(ICON_SMALL)
      command.large_icon = ICON_LARGE if File.exist?(ICON_LARGE)

      UI.menu('Extensions').add_item(command)
      toolbar = UI::Toolbar.new('VADA - Tô Màu Group')
      toolbar.add_item(command)
      toolbar.restore

      file_loaded(__FILE__)
    end
  end
end
