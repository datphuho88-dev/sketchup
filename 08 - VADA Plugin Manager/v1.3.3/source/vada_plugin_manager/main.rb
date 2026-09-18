# frozen_string_literal: true
require 'sketchup.rb'
require 'json'
require 'net/http'
require 'uri'
require 'tmpdir'

module VADA
  module PluginManager
    VERSION = '1.3.3' unless const_defined?(:VERSION)
    OWNER = 'datphuho88-dev'
    REPO = 'sketchup'
    BRANCH = 'main'
    MANIFEST_URL = "https://raw.githubusercontent.com/#{OWNER}/#{REPO}/#{BRANCH}/vada_plugin_manifest.json"
    TREE_URL = "https://api.github.com/repos/#{OWNER}/#{REPO}/git/trees/#{BRANCH}?recursive=1"
    PLUGINS_DIR = Sketchup.find_support_file('Plugins')

    class << self
      def show
        @dialog = build_dialog if @dialog.nil?
        @dialog.show
      rescue StandardError => e
        UI.messagebox("VADA Plugin Manager không mở được:\n#{e.message}")
        @dialog = nil
      end

      def build_dialog
        dlg = UI::HtmlDialog.new(
          dialog_title: "VADA Plugin Manager v#{VERSION}",
          preferences_key: 'vada_plugin_manager',
          scrollable: true,
          resizable: true,
          width: 820,
          height: 650,
          style: UI::HtmlDialog::STYLE_DIALOG
        )
        dlg.set_html(html)
        dlg.add_action_callback('ready') { |_c| dialog_ready }
        dlg.add_action_callback('refresh') { |_c| refresh_ui }
        dlg.add_action_callback('checkUpdates') { |_c| check_updates }
        dlg.add_action_callback('reloadPlugin') { |_c, id| reload_plugin(id.to_s) }
        dlg.add_action_callback('updatePlugin') { |_c, id| update_plugin(id.to_s) }
        dlg.add_action_callback('reloadAll') { |_c| reload_all }
        dlg.add_action_callback('updateAll') { |_c| update_all }
        dlg.set_on_closed do
          @dialog_ready = false
          @dialog = nil
        end
        dlg
      end

      def dialog_ready
        @dialog_ready = true
        refresh_ui
        return if @auto_check_running
        @auto_check_running = true
        UI.start_timer(0.15, false) do
          begin
            check_updates(auto: true)
          ensure
            @auto_check_running = false
          end
        end
      end

      def normalize_text(value)
        value.to_s.downcase.unicode_normalize(:nfkd)
             .encode('ASCII', replace: '', undef: :replace, invalid: :replace)
             .gsub(/[^a-z0-9]+/, ' ').strip
      rescue StandardError
        value.to_s.downcase
      end

      def compare_versions(a, b)
        aa = a.to_s.scan(/\d+/).map(&:to_i)
        bb = b.to_s.scan(/\d+/).map(&:to_i)
        len = [aa.length, bb.length, 3].max
        (aa + [0] * (len - aa.length)) <=> (bb + [0] * (len - bb.length))
      end

      def safe_call(object, method)
        object.respond_to?(method) ? object.public_send(method) : nil
      rescue StandardError
        nil
      end

      def extension_snapshot
        Sketchup.extensions.map do |ext|
          path = nil
          [:extension_path, :path].each do |method|
            value = safe_call(ext, method)
            if value && !value.to_s.empty?
              path = value.to_s
              break
            end
          end
          { name: safe_call(ext, :name).to_s, version: safe_call(ext, :version).to_s, path: path }
        end
      rescue StandardError
        []
      end

      def fallback_manifest
        {
          'plugins' => [
            { 'id'=>'ghi_kich_thuoc_tu_dong','name'=>'Ghi kích thước tự động','latest_version'=>'1.1.0','repo_path'=>'01 - Ghi kích thước tự động','loader_candidates'=>['vada_auto_dim.rb','vada_ghi_kich_thuoc_tu_dong.rb','vada_auto_dim_ban_tron.rb','auto_dim_ban_tron.rb'],'extension_names'=>['VADA Auto Dim','VADA Auto Dim Bàn Tròn','Auto Dim Bàn Tròn','Ghi kích thước tự động'],'detect_tokens'=>['Auto Dim','Bàn Tròn','Ghi kích thước'],'hot_reload'=>false },
            { 'id'=>'don_plugin_rac','name'=>'Dọn plugin rác','latest_version'=>'1.3.0','repo_path'=>'02 - Dọn plugin rác','loader_candidates'=>['vada_extension_cleaner.rb','vada_don_plugin_rac.rb'],'hot_reload'=>false },
            { 'id'=>'tim_cong_cu_nhanh','name'=>'Tìm công cụ nhanh','latest_version'=>'0.4.1','repo_path'=>'03 - Tìm công cụ nhanh','loader_candidates'=>['quick_tool_finder.rb','tim_cong_cu_nhanh.rb','vada_quick_tool_finder.rb','vada_tim_cong_cu_nhanh.rb'],'extension_names'=>['Tìm Công Cụ Nhanh','VADA Tìm Công Cụ Nhanh','Quick Tool Finder'],'detect_tokens'=>['Tìm Công Cụ Nhanh','Quick Tool Finder'],'hot_reload'=>false },
            { 'id'=>'mat_cat_goc_nhin','name'=>'Tạo mặt cắt và góc nhìn','latest_version'=>'1.6.0','repo_path'=>'04 - Tạo mặt cắt và góc nhìn','loader_candidates'=>['vada_mat_cat_view.rb'],'reload_candidates'=>['vada_mat_cat_view/main.rb'],'reload_loader'=>false,'extension_names'=>['VADA - Tạo mặt cắt View','VADA Tạo Mặt Cắt & View','VADA Tạo mặt cắt và góc nhìn','Tạo mặt cắt và góc nhìn'],'detect_tokens'=>['Tạo Mặt Cắt','Mặt Cắt','Mat Cat','Section View'],'hot_reload'=>true },
            { 'id'=>'tong_do_dai_canh','name'=>'Tính tổng độ dài cạnh','latest_version'=>'1.0.1','repo_path'=>'05 - Tính tổng độ dài cạnh','loader_candidates'=>['vada_tong_do_dai_canh.rb','VADA_Tong_Do_Dai_Canh.rb'],'hot_reload'=>true },
            { 'id'=>'thong_ke_sat_hop','name'=>'Thống kê sắt hộp','latest_version'=>'1.1.1','repo_path'=>'06 - Thống kê sắt hộp','loader_candidates'=>['vada_thong_ke_sat_hop.rb','VADA_Thong_Ke_Sat_Hop.rb','thong_ke_sat_hop.rb','vada_steel_stats.rb'],'extension_names'=>['VADA Thống Kê Sắt Hộp','Thống Kê Sắt Hộp','VADA Steel Box Statistics'],'detect_tokens'=>['Thống Kê Sắt Hộp','Steel Box'],'hot_reload'=>true },
            { 'id'=>'tong_dien_tich','name'=>'Tính tổng diện tích','latest_version'=>'1.0.1','repo_path'=>'07 - Tính tổng diện tích','loader_candidates'=>['vada_tong_dien_tich.rb'],'hot_reload'=>true },
            { 'id'=>'plugin_manager','name'=>'VADA Plugin Manager','latest_version'=>VERSION,'repo_path'=>'08 - VADA Plugin Manager','loader_candidates'=>['vada_plugin_manager.rb'],'extension_names'=>['VADA Plugin Manager'],'hot_reload'=>false },
            { 'id'=>'tao_phong_nhanh','name'=>'Tạo phòng nhanh','latest_version'=>'1.0.0','repo_path'=>'09 - Tạo phòng nhanh','loader_candidates'=>['vada_quick_room.rb'],'extension_names'=>['VADA Tạo Phòng Nhanh','Tạo phòng nhanh'],'detect_tokens'=>['Tạo Phòng Nhanh','QuickRoom'],'hot_reload'=>true },
            { 'id'=>'workspace_manager','name'=>'VADA Workspace Manager','latest_version'=>'1.0.0','repo_path'=>'10 - VADA Workspace Manager','loader_candidates'=>['vada_workspace_manager.rb'],'extension_names'=>['VADA Workspace Manager'],'detect_tokens'=>['Workspace Manager','VADA Workspace'],'hot_reload'=>false }
          ]
        }
      end

      def resolve_loader(plugin)
        Array(plugin['loader_candidates']).each do |rel|
          path = File.join(PLUGINS_DIR, rel.to_s)
          return path if File.file?(path)
        end
        nil
      end

      def detect_version_from_file(path)
        return '' unless path && File.file?(path)
        text = File.read(path, encoding: 'UTF-8', invalid: :replace, undef: :replace, replace: '')
        [
          /(?:PLUGIN_VERSION|EXTENSION_VERSION|VERSION)\s*=\s*['\"]v?([^'\"]+)['\"]/i,
          /\.version\s*=\s*['\"]v?([^'\"]+)['\"]/i,
          /version\s*[:=]\s*['\"]?v?(\d+\.\d+\.\d+)/i
        ].each do |pattern|
          match = text.match(pattern)
          return match[1] if match
        end
        ''
      rescue StandardError
        ''
      end

      def match_extension(plugin, extensions)
        exact = Array(plugin['extension_names']).map { |n| normalize_text(n) }.reject(&:empty?)
        exact_match = extensions.find { |ext| exact.include?(normalize_text(ext[:name])) }
        return exact_match if exact_match

        tokens = (Array(plugin['detect_tokens']) + [plugin['name']]).map { |n| normalize_text(n) }.reject(&:empty?).uniq
        matches = extensions.select do |ext|
          name = normalize_text(ext[:name])
          tokens.any? { |token| name.include?(token) || token.include?(name) }
        end
        matches.max { |a, b| compare_versions(a[:version].to_s, b[:version].to_s) }
      end

      def scan_loader_by_tokens(plugin)
        tokens = (Array(plugin['detect_tokens']) + [plugin['name']]).map { |t| normalize_text(t) }.reject(&:empty?).uniq
        return nil if tokens.empty?
        Dir.glob(File.join(PLUGINS_DIR, '*.rb')).find do |file|
          base = normalize_text(File.basename(file, '.rb'))
          next true if tokens.any? { |token| base.include?(token) || token.include?(base) }
          begin
            sample = File.read(file, 24_000, encoding: 'UTF-8', invalid: :replace, undef: :replace, replace: '')
            normalized = normalize_text(sample)
            tokens.any? { |token| normalized.include?(token) }
          rescue StandardError
            false
          end
        end
      end

      def local_version_candidates(plugin, ext, loader)
        candidates = []
        candidates << ext[:version].to_s if ext && !ext[:version].to_s.empty?
        [loader, (ext && ext[:path]), resolve_reload_target(plugin)].compact.uniq.each do |path|
          version = detect_version_from_file(path)
          candidates << version unless version.to_s.empty?
        end
        candidates.select { |v| v.to_s.match?(/\d+\.\d+(?:\.\d+)?/) }.uniq
      end

      def highest_version(versions)
        versions.max { |a, b| compare_versions(a, b) }
      end

      def detect_local!(plugin, extensions)
        ext = match_extension(plugin, extensions)
        loader = resolve_loader(plugin)
        loader ||= scan_loader_by_tokens(plugin) unless ext
        if ext || loader
          plugin['installed'] = true
          plugin['loader'] = loader
          versions = local_version_candidates(plugin, ext, loader)
          version = highest_version(versions)
          plugin['local_version'] = version.to_s.empty? ? 'đã cài' : version
        else
          plugin['installed'] = false
          plugin['loader'] = nil
          plugin['local_version'] = '-'
        end
      end

      def resolve_reload_target(plugin)
        Array(plugin['reload_candidates']).each do |rel|
          path = File.join(PLUGINS_DIR, rel.to_s)
          return path if File.file?(path)
        end
        loader = resolve_loader(plugin)
        plugin.fetch('reload_loader', true) ? loader : nil
      end

      def update_available?(plugin)
        return false unless plugin['installed']
        local = plugin['local_version'].to_s
        remote = plugin['latest_version'].to_s
        return false if remote.empty?
        return true if local.empty? || local == 'đã cài'
        compare_versions(remote, local) > 0
      end

      def plugin_catalog
        manifest = @manifest || fallback_manifest
        extensions = extension_snapshot
        items = manifest.fetch('plugins', []).map do |source|
          p = source.dup
          detect_local!(p, extensions)
          p['update_available'] = update_available?(p)
          p['reload_target'] = resolve_reload_target(p)
          p['reloadable'] = p['installed'] && p.fetch('hot_reload', false) && !p['reload_target'].to_s.empty?
          p
        end
        items.sort_by do |p|
          rank = if !p['installed'] && !p['rbz_url'].to_s.empty? then 0
                 elsif p['installed'] && p['update_available'] then 1
                 elsif p['installed'] then 2
                 else 3 end
          [rank, p['name'].to_s.downcase]
        end
      end

      def http_get(url, timeout = 10)
        uri = URI(url)
        req = Net::HTTP::Get.new(uri)
        req['User-Agent'] = "VADA-Plugin-Manager/#{VERSION}"
        req['Accept'] = 'application/vnd.github+json' if uri.host == 'api.github.com'
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: timeout) { |h| h.request(req) }
        return http_get(res['location'], timeout) if res.is_a?(Net::HTTPRedirection)
        raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
        res.body
      end

      def raw_url(path)
        return '' if path.to_s.empty?
        encoded = path.split('/').map { |seg| URI::DEFAULT_PARSER.escape(seg) }.join('/')
        "https://raw.githubusercontent.com/#{OWNER}/#{REPO}/#{BRANCH}/#{encoded}"
      end

      def direct_versions(base, dirs)
        dirs.filter_map do |path|
          next unless path.start_with?(base + '/')
          rest = path[(base.length + 1)..-1]
          next if rest.include?('/')
          m = rest.match(/^v?(\d+\.\d+\.\d+)$/i)
          m && [m[1], path]
        end
      end

      def enrich_plugin!(plugin, files, dirs)
        base = plugin['repo_path'].to_s
        return if base.empty?
        versions = direct_versions(base, dirs)
        if versions.any?
          latest = versions.max { |a, b| compare_versions(a[0], b[0]) }
          plugin['latest_version'] = latest[0]
          rbz = files.find { |path| path.start_with?(latest[1] + '/') && path.downcase.end_with?('.rbz') }
          plugin['rbz_url'] = raw_url(rbz) if rbz
          return
        end
        candidates = files.filter_map do |path|
          next unless path.start_with?(base + '/releases/') && path.downcase.end_with?('.rbz')
          m = File.basename(path).match(/v?(\d+\.\d+\.\d+)/i)
          m && [m[1], path]
        end
        return if candidates.empty?
        latest = candidates.max { |a, b| compare_versions(a[0], b[0]) }
        plugin['latest_version'] = latest[0]
        plugin['rbz_url'] = raw_url(latest[1])
      end

      def discover_unlisted!(manifest, files, dirs)
        known = manifest['plugins'].map { |p| p['repo_path'].to_s }
        dirs.select { |path| !path.include?('/') && path.match?(/^\d+\s*-\s*.+/) }.each do |base|
          next if known.include?(base)
          versions = direct_versions(base, dirs)
          next if versions.empty?
          latest = versions.max { |a, b| compare_versions(a[0], b[0]) }
          rbz = files.find { |path| path.start_with?(latest[1] + '/') && path.downcase.end_with?('.rbz') }
          next unless rbz
          name = base.sub(/^\d+\s*-\s*/, '')
          manifest['plugins'] << {
            'id'=>normalize_text(base).tr(' ','_'), 'name'=>name, 'repo_path'=>base,
            'latest_version'=>latest[0], 'rbz_url'=>raw_url(rbz), 'loader_candidates'=>[],
            'extension_names'=>[name, "VADA #{name}"], 'detect_tokens'=>[name], 'hot_reload'=>false
          }
        end
      end

      def check_updates(auto: false)
        manifest = JSON.parse(http_get(MANIFEST_URL, 8))
        tree = JSON.parse(http_get(TREE_URL, 15)).fetch('tree', [])
        files = tree.select { |e| e['type'] == 'blob' }.map { |e| e['path'].to_s }
        dirs = tree.select { |e| e['type'] == 'tree' }.map { |e| e['path'].to_s }
        manifest.fetch('plugins', []).each { |p| enrich_plugin!(p, files, dirs) }
        discover_unlisted!(manifest, files, dirs)
        @manifest = manifest
        @last_check = Time.now
        toast('Đã quét GitHub trực tiếp.', 'ok') unless auto
      rescue StandardError => e
        toast("Không kiểm tra được GitHub: #{escape_js(e.message)}", 'err') unless auto
      ensure
        refresh_ui
      end

      def safe_reload(plugin)
        target = resolve_reload_target(plugin)
        return [:restart, nil] unless target
        load target
        [:ok, target]
      rescue Exception => e
        [:error, e.message]
      end

      def reload_plugin(id)
        p = plugin_catalog.find { |x| x['id'] == id }
        return toast('Không tìm thấy plugin', 'err') unless p
        return toast('Plugin này chưa có cấu hình reload an toàn', 'warn') unless p['reloadable']
        status, detail = safe_reload(p)
        status == :ok ? toast("Đã reload: #{p['name']}", 'ok') : toast("Reload lỗi: #{detail}", 'err')
        refresh_ui
      end

      def reload_all
        ok = 0
        fail = 0
        plugin_catalog.each do |p|
          next unless p['reloadable']
          safe_reload(p).first == :ok ? ok += 1 : fail += 1
        end
        toast("Reload xong: #{ok} thành công, #{fail} lỗi", fail.zero? ? 'ok' : 'warn')
        refresh_ui
      end

      def download(url, filename)
        path = File.join(Dir.tmpdir, filename)
        File.binwrite(path, http_get(url, 30))
        path
      end

      def update_plugin(id)
        p = plugin_catalog.find { |x| x['id'] == id }
        return toast('Không tìm thấy plugin', 'err') unless p
        return toast('Plugin đang là bản mới nhất', 'ok') if p['installed'] && !p['update_available']
        return toast('Không tìm thấy RBZ', 'warn') if p['rbz_url'].to_s.empty?
        path = nil
        begin
          path = download(p['rbz_url'], "vada_#{p['id']}_#{p['latest_version']}.rbz")
          raise 'SketchUp không hỗ trợ cài RBZ tự động.' unless Sketchup.respond_to?(:install_from_archive)
          raise 'Cài RBZ thất bại.' unless Sketchup.install_from_archive(path)
          if p.fetch('hot_reload', false)
            status, = safe_reload(p)
            if status == :ok
              toast("Đã #{p['installed'] ? 'cập nhật' : 'cài mới'} và reload: #{p['name']}", 'ok')
            else
              toast("Đã #{p['installed'] ? 'cập nhật' : 'cài mới'} #{p['name']}. Cần mở lại SketchUp.", 'warn')
            end
          else
            toast("Đã #{p['installed'] ? 'cập nhật' : 'cài mới'} #{p['name']}. Cần mở lại SketchUp nếu chưa xuất hiện.", 'warn')
          end
        rescue StandardError => e
          toast("Cài đặt lỗi: #{escape_js(e.message)}", 'err')
        ensure
          File.delete(path) if path && File.file?(path)
          refresh_ui
        end
      end

      def update_all
        list = plugin_catalog.select { |p| (!p['installed'] || p['update_available']) && !p['rbz_url'].to_s.empty? }
        return toast('Không có plugin cần cài/cập nhật', 'ok') if list.empty?
        ok = 0
        fail = 0
        list.each do |p|
          path = nil
          begin
            path = download(p['rbz_url'], "vada_#{p['id']}_#{p['latest_version']}.rbz")
            raise 'Không hỗ trợ install_from_archive' unless Sketchup.respond_to?(:install_from_archive)
            raise 'Cài đặt thất bại' unless Sketchup.install_from_archive(path)
            safe_reload(p) if p.fetch('hot_reload', false)
            ok += 1
          rescue StandardError
            fail += 1
          ensure
            File.delete(path) if path && File.file?(path)
          end
        end
        toast("Cài/cập nhật xong: #{ok} thành công, #{fail} lỗi", fail.zero? ? 'ok' : 'warn')
        refresh_ui
      end

      def refresh_ui
        return unless @dialog && @dialog_ready
        list = plugin_catalog
        payload = {
          plugins: list,
          last_check: @last_check ? @last_check.strftime('%H:%M:%S') : nil,
          new_count: list.count { |p| !p['installed'] && !p['rbz_url'].to_s.empty? },
          update_count: list.count { |p| p['installed'] && p['update_available'] }
        }
        @dialog.execute_script("renderState(#{JSON.generate(payload)});")
      rescue StandardError
        @dialog_ready = false
      end

      def toast(message, type='ok')
        return unless @dialog && @dialog_ready
        @dialog.execute_script("toast('#{escape_js(message)}','#{type}')")
      rescue StandardError
      end

      def escape_js(str)
        str.to_s.gsub('\\', '\\\\').gsub("'", "\\'").gsub("\r", '').gsub("\n", '\\n')
      end

      def html
        <<~HTML
          <!doctype html><html><head><meta charset="utf-8"><style>
          *{box-sizing:border-box}body{margin:0;background:#000;color:#eee;font-family:Segoe UI,Arial,sans-serif;font-size:13px}.top{position:sticky;top:0;background:#050505;border-bottom:1px solid #222;padding:14px 16px;z-index:2}h1{font-size:18px;margin:0 0 3px}.ver,.summary{color:#888}.actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px}button{background:#171717;color:#fff;border:1px solid #333;border-radius:8px;padding:8px 11px;cursor:pointer;font-weight:600}.primary{border-color:#c00;color:#ff5a5a}.body{padding:12px 16px 70px}.section-title{font-size:12px;color:#aaa;margin:16px 2px 8px;text-transform:uppercase}.card{display:grid;grid-template-columns:1fr auto;gap:10px;background:#0b0b0b;border:1px solid #222;border-radius:10px;padding:12px;margin-bottom:9px}.new-plugin{border-color:#26653d}.has-update{border-color:#603030}.name{font-weight:700;font-size:14px}.meta{color:#999;margin-top:5px}.ok,.new{color:#54d17a}.warn{color:#f0b84d}.outdated{color:#ff6565}.btns{display:flex;gap:6px;align-items:center}.small{padding:7px 9px;font-size:12px}.disabled{opacity:.35;pointer-events:none}.install{border-color:#28673e;color:#72e597}.update{border-color:#8e3131;color:#ff6969}#toast{position:fixed;left:16px;right:16px;bottom:14px;background:#141414;border:1px solid #333;border-radius:9px;padding:10px 12px;display:none;z-index:5}
          </style></head><body>
          <div class="top"><h1>VADA Plugin Manager</h1><div class="ver">Phiên bản #{VERSION} · Công ty TNHH VADA</div><div class="actions"><button class="primary" onclick="sketchup.checkUpdates()">↻ Kiểm tra cập nhật</button><button onclick="sketchup.updateAll()">⇩ Cài/Cập nhật tất cả</button><button onclick="sketchup.reloadAll()">⟳ Reload tất cả</button><button onclick="sketchup.refresh()">Làm mới</button></div></div>
          <div class="body"><div class="summary" id="summary">Đang tải danh sách plugin...</div><div id="list"></div></div><div id="toast"></div>
          <script>
          function esc(s){return String(s??'').replace(/[&<>\"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;'}[c]))}
          function card(p){const installed=p.installed?'<span class="ok">● Đã cài</span>':'<span class="warn">● Chưa cài</span>';let state='',cls='',btn='';if(!p.installed&&p.rbz_url){state='<span class="new">Plugin mới</span>';cls='new-plugin';btn=`<button class="small install" onclick="sketchup.updatePlugin('${esc(p.id)}')">Cài mới</button>`}else if(p.installed&&p.update_available){state='<span class="outdated">Có bản mới</span>';cls='has-update';btn=`<button class="small update" onclick="sketchup.updatePlugin('${esc(p.id)}')">Cập nhật</button>`}else{state='<span class="ok">Mới nhất</span>';btn='<button class="small disabled">Cập nhật</button>'}const reload=`<button class="small ${p.reloadable?'':'disabled'}" onclick="sketchup.reloadPlugin('${esc(p.id)}')">Reload</button>`;const rbz=p.rbz_url?'Có RBZ':'Chưa có RBZ';return `<div class="card ${cls}"><div><div class="name">${esc(p.name)}</div><div class="meta">Máy: <b>${esc(p.local_version)}</b> · GitHub: <b>${esc(p.latest_version||'-')}</b> · ${installed} · ${state} · ${rbz}</div></div><div class="btns">${btn}${reload}</div></div>`}
          function renderState(state){const list=state.plugins||[];document.getElementById('summary').textContent=state.last_check?`Quét GitHub lúc ${state.last_check} · ${state.new_count||0} plugin mới · ${state.update_count||0} plugin có bản mới`:'Danh sách cục bộ · đang tự kiểm tra GitHub';const root=document.getElementById('list');root.innerHTML='';[['Plugin mới chưa cài',list.filter(p=>!p.installed&&p.rbz_url)],['Có bản cập nhật',list.filter(p=>p.installed&&p.update_available)],['Đã cài / mới nhất',list.filter(p=>p.installed&&!p.update_available)],['Chưa nhận diện / chưa có gói cài',list.filter(p=>!p.installed&&!p.rbz_url)]].forEach(g=>{if(g[1].length)root.innerHTML+=`<div class="section-title">${g[0]}</div>`+g[1].map(card).join('')})}
          function toast(msg,type='ok'){const t=document.getElementById('toast');t.className=type;t.textContent=msg;t.style.display='block';clearTimeout(window.__tt);window.__tt=setTimeout(()=>t.style.display='none',4500)}
          document.addEventListener('DOMContentLoaded',()=>{if(window.sketchup&&sketchup.ready){sketchup.ready()}});
          </script></body></html>
        HTML
      end

      def install_ui
        @command ||= UI::Command.new('VADA Plugin Manager') { show }
        icon = File.join(__dir__, 'icon.png')
        if File.file?(icon)
          @command.small_icon = icon
          @command.large_icon = icon
        end
        @command.tooltip = 'VADA Plugin Manager - Cài mới, cập nhật và reload plugin'
        @toolbar ||= UI::Toolbar.new('VADA Plugin Manager')
        @toolbar.add_item(@command) if @toolbar.size == 0
        @toolbar.restore
        UI.start_timer(0.25, false) { @toolbar.show unless @toolbar.visible? rescue @toolbar.show }
        unless @menu_installed
          UI.menu('Extensions').add_item(@command)
          @menu_installed = true
        end
      end
    end

    unless file_loaded?(__FILE__)
      install_ui
      file_loaded(__FILE__)
    end
  end
end
