# frozen_string_literal: true
require 'sketchup.rb'
require 'json'
require 'net/http'
require 'uri'
require 'tempfile'

module VADA
  module PluginManager
    VERSION = '1.0.0' unless const_defined?(:VERSION)
    MANIFEST_URL = 'https://raw.githubusercontent.com/datphuho88-dev/sketchup/main/vada_plugin_manifest.json'
    PLUGINS_DIR = Sketchup.find_support_file('Plugins')

    class << self
      def show
        @dialog ||= build_dialog
        refresh_ui
        @dialog.show
      end

      def build_dialog
        dlg = UI::HtmlDialog.new(
          dialog_title: "VADA Plugin Manager v#{VERSION}",
          preferences_key: 'vada_plugin_manager',
          scrollable: true,
          resizable: true,
          width: 760,
          height: 600,
          style: UI::HtmlDialog::STYLE_DIALOG
        )
        dlg.set_html(html)
        dlg.add_action_callback('refresh') { |_c| refresh_ui }
        dlg.add_action_callback('checkUpdates') { |_c| check_updates }
        dlg.add_action_callback('reloadPlugin') { |_c, id| reload_plugin(id.to_s) }
        dlg.add_action_callback('updatePlugin') { |_c, id| update_plugin(id.to_s) }
        dlg.add_action_callback('reloadAll') { |_c| reload_all }
        dlg.add_action_callback('updateAll') { |_c| update_all }
        dlg
      end

      def local_plugins
        manifest = cached_manifest || fallback_manifest
        manifest.fetch('plugins', []).map do |p|
          p = p.dup
          loader = resolve_loader(p)
          p['loader'] = loader
          p['installed'] = !loader.nil?
          p['local_version'] = detect_local_version(loader, p)
          p['reloadable'] = !loader.nil? && p.fetch('hot_reload', true)
          p
        end
      end

      def resolve_loader(plugin)
        Array(plugin['loader_candidates']).each do |rel|
          path = File.join(PLUGINS_DIR, rel)
          return path if File.file?(path)
        end
        nil
      end

      def detect_local_version(loader, plugin)
        return '-' unless loader
        begin
          text = File.read(loader, encoding: 'UTF-8')
          if (m = text.match(/(?:VERSION|PLUGIN_VERSION)\s*=\s*['"]([^'"]+)['"]/))
            return m[1]
          end
        rescue StandardError
        end
        plugin['installed_version'] || 'đã cài'
      end

      def fetch_manifest
        uri = URI(MANIFEST_URL)
        req = Net::HTTP::Get.new(uri)
        req['User-Agent'] = "VADA-Plugin-Manager/#{VERSION}"
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 8) { |h| h.request(req) }
        raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
        @manifest = JSON.parse(res.body)
      end

      def cached_manifest
        @manifest
      end

      def fallback_manifest
        {'plugins'=>[
          {'id'=>'tong_dien_tich','name'=>'Tổng diện tích','latest_version'=>'1.0.0','loader_candidates'=>['vada_tong_dien_tich.rb'],'hot_reload'=>true},
          {'id'=>'tong_do_dai_canh','name'=>'Tổng độ dài cạnh','latest_version'=>'1.0.1','loader_candidates'=>['vada_tong_do_dai_canh.rb'],'hot_reload'=>true},
          {'id'=>'thong_ke_sat_hop','name'=>'Thống kê sắt hộp','latest_version'=>'1.0.0','loader_candidates'=>['vada_thong_ke_sat_hop.rb'],'hot_reload'=>true}
        ]}
      end

      def check_updates
        begin
          fetch_manifest
          toast('Đã lấy danh sách phiên bản mới từ GitHub', 'ok')
        rescue => e
          toast("Không kiểm tra được GitHub: #{escape_js(e.message)}", 'err')
        ensure
          refresh_ui
        end
      end

      def reload_plugin(id)
        p = local_plugins.find { |x| x['id'] == id }
        return toast('Không tìm thấy plugin', 'err') unless p
        return toast('Plugin chưa được cài hoặc không tìm thấy loader', 'err') unless p['loader']
        return toast('Plugin này được đánh dấu cần khởi động lại SketchUp', 'warn') unless p['reloadable']
        begin
          load p['loader']
          toast("Đã nạp lại: #{escape_js(p['name'])}", 'ok')
          refresh_ui
        rescue Exception => e
          toast("Lỗi reload #{escape_js(p['name'])}: #{escape_js(e.message)}", 'err')
        end
      end

      def reload_all
        ok = 0
        fail = 0
        local_plugins.each do |p|
          next unless p['installed'] && p['reloadable']
          begin
            load p['loader']
            ok += 1
          rescue Exception
            fail += 1
          end
        end
        toast("Reload xong: #{ok} thành công, #{fail} lỗi", fail.zero? ? 'ok' : 'warn')
        refresh_ui
      end

      def update_plugin(id)
        p = local_plugins.find { |x| x['id'] == id }
        return toast('Không tìm thấy plugin', 'err') unless p
        url = p['rbz_url'].to_s
        return toast('Plugin này chưa có gói RBZ trên GitHub', 'warn') if url.empty?
        begin
          path = download(url, "vada_update_#{id}.rbz")
          raise 'Bản SketchUp này không hỗ trợ cài archive tự động.' unless Sketchup.respond_to?(:install_from_archive)
          result = Sketchup.install_from_archive(path)
          raise 'SketchUp không cài được gói RBZ.' unless result
          toast("Đã cài bản mới: #{escape_js(p['name'])}", 'ok')
          reload_plugin(id) if p.fetch('hot_reload', true)
        rescue => e
          toast("Cập nhật lỗi: #{escape_js(e.message)}", 'err')
        ensure
          begin File.delete(path) if path && File.file?(path); rescue; end
          refresh_ui
        end
      end

      def update_all
        list = local_plugins.select { |p| !p['rbz_url'].to_s.empty? }
        return toast('Chưa có plugin nào có gói cập nhật RBZ', 'warn') if list.empty?
        success = 0
        failed = 0
        list.each do |p|
          begin
            path = download(p['rbz_url'], "vada_update_#{p['id']}.rbz")
            raise 'Không hỗ trợ install_from_archive' unless Sketchup.respond_to?(:install_from_archive)
            raise 'Cài đặt thất bại' unless Sketchup.install_from_archive(path)
            begin
              load resolve_loader(p) if p.fetch('hot_reload', true) && resolve_loader(p)
            rescue Exception
            end
            success += 1
          rescue
            failed += 1
          ensure
            begin File.delete(path) if path && File.file?(path); rescue; end
          end
        end
        toast("Cập nhật xong: #{success} thành công, #{failed} lỗi", failed.zero? ? 'ok' : 'warn')
        refresh_ui
      end

      def download(url, filename)
        uri = URI(url)
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 8, read_timeout: 30) { |h| h.request(Net::HTTP::Get.new(uri)) }
        return download(res['location'], filename) if res.is_a?(Net::HTTPRedirection)
        raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
        path = File.join(Dir.tmpdir, filename)
        File.binwrite(path, res.body)
        path
      end

      def refresh_ui
        return unless @dialog
        @dialog.execute_script("renderPlugins(#{JSON.generate(local_plugins)});")
      end

      def toast(message, type='ok')
        return unless @dialog
        @dialog.execute_script("toast('#{escape_js(message)}','#{type}')")
      end

      def escape_js(str)
        str.to_s.gsub('\\','\\\\').gsub("'", "\\'").gsub("\r",'').gsub("\n",'\\n')
      end

      def html
        <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><style>
        *{box-sizing:border-box} body{margin:0;background:#000;color:#eee;font-family:Segoe UI,Arial,sans-serif;font-size:13px}
        .top{position:sticky;top:0;background:#050505;border-bottom:1px solid #222;padding:14px 16px;z-index:2}
        h1{font-size:18px;margin:0 0 3px;color:#fff}.ver{color:#888}.actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px}
        button{background:#171717;color:#fff;border:1px solid #333;border-radius:8px;padding:8px 11px;cursor:pointer;font-weight:600}button:hover{background:#242424}.primary{border-color:#c00;color:#ff4d4d}
        .body{padding:12px 16px 70px}.card{display:grid;grid-template-columns:1fr auto;gap:10px;background:#0b0b0b;border:1px solid #222;border-radius:10px;padding:12px;margin-bottom:9px}
        .name{font-weight:700;font-size:14px}.meta{color:#999;margin-top:5px}.ok{color:#54d17a}.warn{color:#f0b84d}
        .card .btns{display:flex;gap:6px;align-items:center}.small{padding:7px 9px;font-size:12px}.disabled{opacity:.45;pointer-events:none}
        #toast{position:fixed;left:16px;right:16px;bottom:14px;background:#141414;border:1px solid #333;border-radius:9px;padding:10px 12px;display:none;z-index:5}
        #toast.ok{border-color:#265f36;color:#7ee39b}#toast.err{border-color:#6b2424;color:#ff7a7a}#toast.warn{border-color:#6d5522;color:#ffd16a}
        </style></head><body>
        <div class="top"><h1>VADA Plugin Manager</h1><div class="ver">Phiên bản #{VERSION} · Công ty TNHH VADA</div>
        <div class="actions"><button class="primary" onclick="sketchup.checkUpdates()">↻ Kiểm tra cập nhật</button><button onclick="sketchup.updateAll()">⇩ Cập nhật tất cả</button><button onclick="sketchup.reloadAll()">⟳ Reload tất cả</button><button onclick="sketchup.refresh()">Làm mới</button></div></div>
        <div class="body" id="list"></div><div id="toast"></div>
        <script>
        function esc(s){return String(s??'').replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]))}
        function renderPlugins(list){const root=document.getElementById('list');root.innerHTML='';list.forEach(p=>{let state=p.installed?'<span class="ok">● Đã cài</span>':'<span class="warn">● Chưa nhận diện</span>';let rbz=p.rbz_url?'Có gói cập nhật':'Chưa có RBZ';root.innerHTML+=`<div class="card"><div><div class="name">${esc(p.name)}</div><div class="meta">Máy: <b>${esc(p.local_version)}</b> · GitHub: <b>${esc(p.latest_version||'-')}</b> · ${state} · ${esc(rbz)}</div></div><div class="btns"><button class="small ${p.rbz_url?'':'disabled'}" onclick="sketchup.updatePlugin('${esc(p.id)}')">Cập nhật</button><button class="small ${p.reloadable?'':'disabled'}" onclick="sketchup.reloadPlugin('${esc(p.id)}')">Reload</button></div></div>`})}
        function toast(msg,type='ok'){const t=document.getElementById('toast');t.className=type;t.textContent=msg;t.style.display='block';clearTimeout(window.__tt);window.__tt=setTimeout(()=>t.style.display='none',4500)}
        </script></body></html>
        HTML
      end

      def install_ui
        cmd = UI::Command.new('VADA Plugin Manager') { show }
        icon = File.join(__dir__, 'icon.png')
        if File.file?(icon)
          cmd.small_icon = icon
          cmd.large_icon = icon
        end
        cmd.tooltip = 'VADA Plugin Manager - Cập nhật và reload plugin'
        cmd.status_bar_text = 'Quản lý và cập nhật plugin VADA'
        toolbar = UI::Toolbar.new('VADA Plugin Manager')
        toolbar.add_item(cmd)
        toolbar.restore
        UI.menu('Extensions').add_item(cmd)
      end
    end

    unless file_loaded?(__FILE__)
      install_ui
      file_loaded(__FILE__)
    end
  end
end
