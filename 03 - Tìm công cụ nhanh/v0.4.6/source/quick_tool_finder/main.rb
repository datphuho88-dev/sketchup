# frozen_string_literal: true

require 'sketchup.rb'
require 'json'
require 'digest/sha1'
require 'fileutils'
require 'base64'

module VADA
  module QuickToolFinder
    VERSION = '0.4.6'
    PREF_KEY = 'VADA_QuickToolFinder'
    DIALOG_TITLE = 'Tìm Công Cụ Nhanh'
    TOOLBAR_NAME = 'Tìm Công Cụ Nhanh'
    QUICK_TOOLS_TOOLBAR = 'Quick Tools' # tên cũ, giữ để tương thích dữ liệu
    ALIASES_KEY = 'aliases_json'
    PINS_KEY = 'pins_json'
    LAST_GROUP_KEY = 'last_pin_group'
    GROUPS_KEY = 'pin_groups_json'
    GROUP_VISIBILITY_KEY = 'pin_group_visibility_json'

    class << self
      def show
        unless defined?(UI::HtmlDialog)
          UI.messagebox('Tìm Công Cụ Nhanh yêu cầu SketchUp 2017 trở lên.')
          return
        end

        unless command_proc_supported?
          UI.messagebox('Tìm Công Cụ Nhanh có thể tìm/chạy lệnh extension trên SketchUp 2022 trở lên.')
          return
        end

        build_index if @command_records.nil? || @command_records.empty?
        create_dialog unless @dialog
        @dialog.show
        @dialog.bring_to_front if @dialog.respond_to?(:bring_to_front)
      rescue StandardError => e
        UI.messagebox("Lỗi Tìm Công Cụ Nhanh.\n\n#{e.class}: #{e.message}")
      end

      def command_proc_supported?
        UI::Command.instance_methods.include?(:proc)
      rescue StandardError
        false
      end

      def build_index
        @commands = {}
        @commands_by_key = {}
        @records_by_key = {}
        @command_records = []
        seen = {}

        ObjectSpace.each_object(UI::Command) do |command|
          add_command(command, seen)
        end

        begin
          ObjectSpace.each_object(UI::Toolbar) do |toolbar|
            next unless toolbar.respond_to?(:each)
            toolbar.each do |item|
              add_command(item, seen, safe_text { toolbar.name }) if item.is_a?(UI::Command)
            end
          end
        rescue StandardError
          nil
        end

        @command_records.each { |record| apply_saved_data!(record) }
        @command_records.sort_by! do |item|
          [item[:pinned] ? 0 : 1, item[:alias].to_s.empty? ? 1 : 0, item[:name].downcase]
        end
        @command_records
      end

      def add_command(command, seen, toolbar_name = nil)
        return unless command.respond_to?(:proc)

        oid = command.object_id
        return if seen[oid]
        return if own_command?(command)

        action = safe_call { command.proc }
        return unless action.respond_to?(:call)

        name = clean_text(safe_call { command.menu_text })
        tooltip = clean_text(safe_call { command.tooltip })
        status = clean_text(safe_call { command.status_bar_text })
        name = tooltip if name.empty?
        return if name.empty?

        extension_name = clean_text(safe_call do
          ext = command.respond_to?(:extension) ? command.extension : nil
          ext && ext.respond_to?(:name) ? ext.name : nil
        end)

        source_path = clean_text(safe_call do
          location = action.respond_to?(:source_location) ? action.source_location : nil
          location && location.first ? File.expand_path(location.first) : nil
        end)
        source = source_path.empty? ? '' : File.basename(File.dirname(source_path))

        small_icon = command_icon_path(command, :small_icon, source_path)
        large_icon = command_icon_path(command, :large_icon, source_path)
        icon_preview = image_data_uri(small_icon) || image_data_uri(large_icon) || '' 
        toolbar = clean_text(toolbar_name)
        key = command_key(name, tooltip, status, extension_name, source_path, toolbar)
        id = oid.to_s

        record = {
          id: id,
          key: key,
          name: name,
          alias: '',
          shortcut: '',
          pinned: false,
          pin_group: '',
          tooltip: tooltip,
          status: status,
          extension: extension_name,
          source: source,
          toolbar: toolbar,
          small_icon: small_icon,
          large_icon: large_icon,
          icon_preview: icon_preview
        }

        @commands[id] = command
        @commands_by_key[key] = command
        @records_by_key[key] = record
        @command_records << record
        seen[oid] = true
      end

      def command_icon_path(command, method_name, source_path = '')
        return '' unless command.respond_to?(method_name)
        raw = clean_text(safe_call { command.public_send(method_name) })
        return '' if raw.empty?

        candidates = [raw]
        candidates << (File.expand_path(raw) rescue nil)
        unless clean_text(source_path).empty?
          source_dir = File.dirname(source_path)
          candidates << (File.expand_path(raw, source_dir) rescue nil)
          candidates << (File.expand_path(raw, File.dirname(source_dir)) rescue nil)
        end

        found = candidates.compact.find { |candidate| File.file?(candidate) }
        found ? File.expand_path(found) : raw
      rescue StandardError
        ''
      end

      def image_data_uri(path)
        absolute = clean_text(path)
        return nil if absolute.empty? || !File.file?(absolute)

        @icon_data_cache ||= {}
        return @icon_data_cache[absolute] if @icon_data_cache.key?(absolute)

        # Giới hạn kích thước để danh sách nhiều plugin vẫn mở nhanh.
        if File.size(absolute) > 64 * 1024
          @icon_data_cache[absolute] = nil
          return nil
        end

        ext = File.extname(absolute).downcase
        mime = case ext
               when '.png' then 'image/png'
               when '.svg' then 'image/svg+xml'
               when '.jpg', '.jpeg' then 'image/jpeg'
               when '.gif' then 'image/gif'
               when '.webp' then 'image/webp'
               when '.bmp' then 'image/bmp'
               else nil
               end
        unless mime
          @icon_data_cache[absolute] = nil
          return nil
        end

        data = Base64.strict_encode64(File.binread(absolute))
        @icon_data_cache[absolute] = "data:#{mime};base64,#{data}"
      rescue StandardError
        @icon_data_cache[absolute] = nil if defined?(absolute) && absolute
        nil
      end

      def command_key(name, tooltip, status, extension_name, source_path, toolbar)
        raw = [name, tooltip, status, extension_name, source_path, toolbar].map { |v| clean_text(v).downcase }.join("\u001F")
        Digest::SHA1.hexdigest(raw)
      end

      def create_dialog
        html_path = File.join(__dir__, 'ui.html')
        @dialog = UI::HtmlDialog.new(
          dialog_title: DIALOG_TITLE,
          preferences_key: PREF_KEY,
          scrollable: false,
          resizable: true,
          width: 820,
          height: 620,
          min_width: 560,
          min_height: 420,
          style: UI::HtmlDialog::STYLE_DIALOG
        )
        @dialog.set_file(html_path)

        @dialog.add_action_callback('ready') { |_context| push_index_to_dialog }
        @dialog.add_action_callback('refresh') do |_context|
          build_index
          push_index_to_dialog
        end
        @dialog.add_action_callback('run') do |_context, command_id|
          command = @commands && @commands[command_id.to_s]
          next unless command

          dialog = @dialog
          @dialog = nil
          dialog.close if dialog
          UI.start_timer(0.05, false) { execute_command(command) }
        end
        @dialog.add_action_callback('editAlias') { |_context, key| edit_alias(key.to_s) }
        @dialog.add_action_callback('shortcut') { |_context, key| prepare_shortcut(key.to_s) }
        @dialog.add_action_callback('pin') { |_context, key| pin_tool(key.to_s) }
        @dialog.add_action_callback('unpin') { |_context, key| unpin_tool(key.to_s) }
        @dialog.add_action_callback('editPinGroup') { |_context, key| edit_pin_group(key.to_s) }
        @dialog.add_action_callback('pinToGroup') do |_context, payload|
          data = JSON.parse(payload.to_s) rescue {}
          pin_tool(data['key'].to_s, data['group'])
        end
        @dialog.add_action_callback('movePinGroup') do |_context, payload|
          data = JSON.parse(payload.to_s) rescue {}
          edit_pin_group(data['key'].to_s, data['group'])
        end
        @dialog.add_action_callback('groupAction') { |_context, payload| handle_group_action(payload.to_s) }
        @dialog.add_action_callback('finderShortcut') { |_context| show_shortcuts_help('Tìm Công Cụ Nhanh') }
        @dialog.add_action_callback('showToolbar') { |_context| force_show_toolbar }
        @dialog.add_action_callback('showQuickTools') { |_context| force_show_quick_tools_toolbar }
        @dialog.set_on_closed { @dialog = nil }
      end

      def display_command_records
        records = @command_records || []
        grouped = {}
        order = []

        records.each do |record|
          signature = [
            record[:name],
            record[:tooltip],
            record[:status],
            record[:extension],
            record[:source]
          ].map { |value| clean_text(value).downcase }.join("\u001F")

          unless grouped.key?(signature)
            grouped[signature] = record
            order << signature
            next
          end

          current = grouped[signature]
          # Nếu có nhiều command hiển thị giống nhau, ưu tiên bản đang ghim / có alias / có icon.
          current_score = (current[:pinned] ? 100 : 0) + (current[:alias].to_s.empty? ? 0 : 20) + (current[:icon_preview].to_s.empty? ? 0 : 5)
          candidate_score = (record[:pinned] ? 100 : 0) + (record[:alias].to_s.empty? ? 0 : 20) + (record[:icon_preview].to_s.empty? ? 0 : 5)
          grouped[signature] = record if candidate_score > current_score
        end

        order.map { |signature| grouped[signature] }
      end

      def push_index_to_dialog
        return unless @dialog
        json = JSON.generate(display_command_records)
        @dialog.execute_script("window.setCommands(#{json});")
        groups_json = JSON.generate(group_names)
        @dialog.execute_script("window.setGroups(#{groups_json});")
        states_json = JSON.generate(group_state_records)
        @dialog.execute_script("window.setGroupStates(#{states_json});")
      end

      def execute_command(command)
        validation = safe_call do
          command.respond_to?(:get_validation_proc) ? command.get_validation_proc : nil
        end
        if validation.respond_to?(:call)
          state = safe_call { validation.call }
          if (defined?(MF_DISABLED) && state == MF_DISABLED) || (defined?(MF_GRAYED) && state == MF_GRAYED)
            UI.messagebox('This command is currently disabled in the current SketchUp context.')
            return
          end
        end

        action = command.proc
        action.call
      rescue StandardError => e
        UI.messagebox("Could not run command.\n\n#{e.class}: #{e.message}")
      end

      def run_by_key(key)
        build_index if @commands_by_key.nil?
        command = @commands_by_key[key]

        unless command
          build_index
          command = @commands_by_key[key]
        end

        unless command
          saved = saved_entry_for_key(key)
          command = find_command_fallback(saved) if saved
        end

        if command
          execute_command(command)
          true
        else
          # Không dùng messagebox ở đây. Proxy command có thể được SketchUp gọi lại
          # khi khôi phục toolbar lúc startup; hộp thoại modal sẽ lặp liên tục nếu
          # command gốc chưa được extension nguồn đăng ký.
          UI.set_status_text('Tìm Công Cụ Nhanh: công cụ gốc chưa sẵn sàng. Hãy bấm ↻ để quét lại.') if UI.respond_to?(:set_status_text)
          false
        end
      end

      def saved_entry_for_key(key)
        alias_entry_for_key(key) || pin_entry_for_key(key)
      end

      def find_command_fallback(saved)
        return nil unless saved
        build_index if @command_records.nil?

        name = clean_text(saved['target_name'])
        extension_name = clean_text(saved['extension'])
        source = clean_text(saved['source'])

        record = @command_records.find do |item|
          next false unless item[:name].casecmp?(name)
          ext_ok = extension_name.empty? || item[:extension].casecmp?(extension_name)
          src_ok = source.empty? || item[:source].casecmp?(source)
          ext_ok && src_ok
        end
        record && @commands[record[:id]]
      end

      def edit_alias(key)
        build_index if @records_by_key.nil?
        record = @records_by_key[key]
        return unless record

        current = alias_for_key(key).to_s
        result = UI.inputbox(['Tên gợi nhớ:'], [current], "Đặt tên cho: #{record[:name]}")
        return unless result

        value = clean_text(result[0])
        if value.empty?
          remove_alias(key)
        else
          save_alias(record, value)
        end

        build_index
        push_index_to_dialog
      rescue StandardError => e
        UI.messagebox("Không lưu được tên gợi nhớ.\n\n#{e.class}: #{e.message}")
      end

      def prepare_shortcut(key)
        build_index if @records_by_key.nil?
        record = @records_by_key[key]
        return unless record

        saved_alias = alias_for_key(key).to_s
        if saved_alias.empty?
          result = UI.inputbox(
            ['Tên gợi nhớ trước khi tạo phím tắt:'],
            [record[:name]],
            "Phím tắt cho: #{record[:name]}"
          )
          return unless result
          saved_alias = clean_text(result[0])
          return if saved_alias.empty?
          save_alias(record, saved_alias)
          build_index
        end

        register_alias_command(alias_entry_for_key(key))
        push_index_to_dialog
        show_shortcuts_help(saved_alias)
      rescue StandardError => e
        UI.messagebox("Không chuẩn bị được phím tắt.\n\n#{e.class}: #{e.message}")
      end

      def pin_tool(key, chosen_group = nil)
        build_index if @records_by_key.nil?
        record = @records_by_key[key]
        return unless record

        if pinned_key?(key)
          edit_pin_group(key, chosen_group)
          return
        end

        group = if chosen_group.nil?
                  ask_pin_group(record, last_pin_group)
                else
                  normalized_group(chosen_group)
                end
        return if group.nil?
        group = ensure_group(group)

        entry = {
          'key' => record[:key],
          'target_name' => record[:name],
          'alias' => clean_text(record[:alias]),
          'group' => group,
          'extension' => record[:extension],
          'source' => record[:source],
          'toolbar' => record[:toolbar],
          'small_icon' => record[:small_icon],
          'large_icon' => record[:large_icon]
        }
        pins << entry
        save_last_pin_group(group)
        persist_pins
        rebuild_group_toolbar(group)

        record[:pinned] = true
        record[:pin_group] = group
        push_index_to_dialog
      rescue StandardError => e
        UI.messagebox("Không ghim được công cụ.\n\n#{e.class}: #{e.message}")
      end

      def unpin_tool(key)
        entry = pin_entry_for_key(key)
        return unless entry

        old_group = normalized_group(entry['group'])
        pins.reject! { |item| clean_text(item['key']) == key }
        persist_pins

        if @records_by_key && (record = @records_by_key[key])
          record[:pinned] = false
          record[:pin_group] = ''
        end

        rebuild_group_toolbar(old_group)
        push_index_to_dialog
      rescue StandardError => e
        UI.messagebox("Không gỡ ghim được công cụ.\n\n#{e.class}: #{e.message}")
      end

      def edit_pin_group(key, chosen_group = nil)
        entry = pin_entry_for_key(key)
        return unless entry

        record = @records_by_key && @records_by_key[key]
        record ||= { name: clean_text(entry['target_name']), alias: clean_text(entry['alias']) }
        old_group = normalized_group(entry['group'])
        group = if chosen_group.nil?
                  ask_pin_group(record, old_group)
                else
                  normalized_group(chosen_group)
                end
        return if group.nil? || group.casecmp?(old_group)
        group = ensure_group(group)

        entry['group'] = group
        save_last_pin_group(group)
        persist_pins

        if @records_by_key && (current = @records_by_key[key])
          current[:pin_group] = group
        end

        rebuild_group_toolbar(old_group)
        rebuild_group_toolbar(group)
        push_index_to_dialog
      rescue StandardError => e
        UI.messagebox("Không đổi được nhóm ghim.\n\n#{e.class}: #{e.message}")
      end

      def ask_pin_group(record, current_group)
        current = normalized_group(current_group)
        result = UI.inputbox(
          ['Nhóm ghim:'],
          [current],
          "Phân loại: #{display_name_for_record(record)}"
        )
        return nil unless result

        value = clean_text(result[0])
        value.empty? ? 'Chưa phân loại' : value
      end

      def normalized_group(value)
        group = clean_text(value)
        group.empty? ? 'Chưa phân loại' : group
      end

      def group_names
        @group_names ||= begin
          stored = read_json_array(GROUPS_KEY).map do |item|
            item.is_a?(Hash) ? item['name'] : item
          end
          derived = pins.map { |entry| entry['group'] }
          names = (['Chưa phân loại'] + stored + derived).map { |name| normalized_group(name) }
          unique_casefold(names).sort_by { |name| name == 'Chưa phân loại' ? '' : name.downcase }
        end
      end

      def unique_casefold(values)
        seen = {}
        values.each_with_object([]) do |value, output|
          name = normalized_group(value)
          key = name.downcase
          next if seen[key]
          seen[key] = true
          output << name
        end
      end

      def persist_groups
        Sketchup.write_default(PREF_KEY, GROUPS_KEY, JSON.generate(group_names))
      rescue StandardError
        nil
      end

      def group_visibility_map
        @group_visibility_map ||= begin
          map = {}
          read_json_array(GROUP_VISIBILITY_KEY).each do |item|
            next unless item.is_a?(Hash)
            name = normalized_group(item['name'])
            map[name.downcase] = item['visible'] != false
          end
          map
        end
      end

      def group_visible?(group)
        name = normalized_group(group)
        value = group_visibility_map[name.downcase]
        value.nil? ? true : !!value
      end

      def group_state_records
        group_names.map do |name|
          {
            name: name,
            visible: group_visible?(name)
          }
        end
      end

      def persist_group_visibility
        payload = group_names.map do |name|
          { 'name' => name, 'visible' => group_visible?(name) }
        end
        Sketchup.write_default(PREF_KEY, GROUP_VISIBILITY_KEY, JSON.generate(payload))
      rescue StandardError
        nil
      end

      def set_group_visible(group, visible)
        name = ensure_group(group)
        group_visibility_map[name.downcase] = !!visible
        persist_group_visibility

        if visible
          rebuild_group_toolbar(name)
        else
          hide_group_toolbar(name)
        end
        push_index_to_dialog
        true
      rescue StandardError => e
        UI.messagebox("Không đổi được trạng thái nhóm '#{normalized_group(group)}'.\n\n#{e.class}: #{e.message}")
        false
      end

      def ensure_group(group)
        name = normalized_group(group)
        existing = group_names.find { |item| item.casecmp?(name) }
        return existing if existing

        group_names << name
        @group_names = unique_casefold(group_names)
        persist_groups
        name
      end

      def handle_group_action(payload)
        data = JSON.parse(payload) rescue {}
        action = clean_text(data['action'])
        case action
        when 'create'
          create_group(data['name'])
        when 'rename'
          rename_group(data['old_name'], data['new_name'])
        when 'delete'
          delete_group(data['name'])
        when 'show'
          set_group_visible(data['name'], true)
        when 'hide'
          set_group_visible(data['name'], false)
        end
      rescue StandardError => e
        UI.messagebox("Không cập nhật được nhóm.\n\n#{e.class}: #{e.message}")
      end

      def create_group(name)
        value = clean_text(name)
        return if value.empty?
        group = ensure_group(value)
        group_visibility_map[group.downcase] = true unless group_visibility_map.key?(group.downcase)
        persist_group_visibility
        push_index_to_dialog
      end

      def rename_group(old_name, new_name)
        old_group = normalized_group(old_name)
        value = clean_text(new_name)
        return if value.empty? || old_group == 'Chưa phân loại'

        old_visible = group_visible?(old_group)
        target_existed = group_names.any? { |item| item.casecmp?(value) && !item.casecmp?(old_group) }
        new_group = ensure_group(value)
        return if new_group.casecmp?(old_group)

        pins.each do |entry|
          entry['group'] = new_group if normalized_group(entry['group']).casecmp?(old_group)
        end
        persist_pins
        @group_names = group_names.reject { |item| item.casecmp?(old_group) }
        @group_names << new_group
        @group_names = unique_casefold(@group_names)
        persist_groups

        old_key = old_group.downcase
        new_key = new_group.downcase
        existing_visibility = group_visibility_map[new_key]
        group_visibility_map.delete(old_key)
        group_visibility_map[new_key] = target_existed && !existing_visibility.nil? ? existing_visibility : old_visible
        persist_group_visibility

        hide_group_toolbar(old_group)
        rebuild_group_toolbar(new_group)
        build_index
        push_index_to_dialog
      end

      def delete_group(name)
        old_group = normalized_group(name)
        return if old_group == 'Chưa phân loại'

        fallback = ensure_group('Chưa phân loại')
        pins.each do |entry|
          entry['group'] = fallback if normalized_group(entry['group']).casecmp?(old_group)
        end
        persist_pins
        @group_names = group_names.reject { |item| item.casecmp?(old_group) }
        persist_groups
        group_visibility_map.delete(old_group.downcase)
        persist_group_visibility

        hide_group_toolbar(old_group)
        rebuild_group_toolbar(fallback)
        build_index
        push_index_to_dialog
      end

      def last_pin_group
        normalized_group(Sketchup.read_default(PREF_KEY, LAST_GROUP_KEY, 'Chưa phân loại'))
      rescue StandardError
        'Chưa phân loại'
      end

      def save_last_pin_group(group)
        Sketchup.write_default(PREF_KEY, LAST_GROUP_KEY, normalized_group(group))
      rescue StandardError
        nil
      end

      def pin_group_for_key(key)
        entry = pin_entry_for_key(key)
        entry ? normalized_group(entry['group']) : ''
      end

      def display_name_for_record(record)
        name = clean_text(record[:alias])
        name.empty? ? clean_text(record[:name]) : name
      end

      def show_shortcuts_help(search_text)
        UI.messagebox(
          "SketchUp không có API chính thức để plugin tự ghi phím tắt.\n\n" \
          "Tôi đã tạo lệnh có tên: #{search_text}\n" \
          "Cửa sổ Shortcuts sẽ mở. Tìm '#{search_text}' rồi gán phím bạn muốn."
        )

        page = begin
          pages = UI.respond_to?(:preferences_pages) ? UI.preferences_pages : []
          pages.find { |name| name.to_s.downcase.include?('shortcut') } || 'Shortcuts'
        rescue StandardError
          'Shortcuts'
        end
        UI.show_preferences(page)
      end

      def aliases
        @aliases ||= read_json_array(ALIASES_KEY)
      end

      def pins
        @pins ||= load_pins_from_storage
      end

      def reload_pins!
        @pins = nil
        pins
      end

      def load_pins_from_storage
        # Primary storage is authoritative, including an intentionally empty array after unpin.
        # Backup/file are only recovery sources when the primary value is missing or corrupt.
        primary, primary_valid = read_json_array_state(PINS_KEY)
        source = primary

        unless primary_valid
          backup, backup_valid = read_json_array_state("#{PINS_KEY}_backup")
          source = backup_valid ? backup : read_json_file(pins_file_path)
        end

        result = source.each_with_object([]) do |item, output|
          next unless item.is_a?(Hash)
          key = clean_text(item['key'])
          next if key.empty?
          item['group'] = normalized_group(item['group'])
          output << item
        end

        # Remove duplicate keys while keeping the newest entry from the chosen source.
        deduped = {}
        result.each { |item| deduped[clean_text(item['key'])] = item }
        final = deduped.values
        sync_pins_storage(final) unless primary_valid
        final
      rescue StandardError
        []
      end

      def read_json_array_state(key)
        raw = Sketchup.read_default(PREF_KEY, key, nil)
        return [[], false] if raw.nil?
        parsed = JSON.parse(raw.to_s)
        return [[], false] unless parsed.is_a?(Array)
        [parsed, true]
      rescue StandardError
        [[], false]
      end

      def read_json_array(key)
        raw = Sketchup.read_default(PREF_KEY, key, '[]').to_s
        parsed = JSON.parse(raw)
        parsed.is_a?(Array) ? parsed : []
      rescue StandardError
        []
      end

      def read_json_file(path)
        return [] unless path && File.file?(path)
        parsed = JSON.parse(File.read(path, encoding: 'UTF-8'))
        parsed.is_a?(Array) ? parsed : []
      rescue StandardError
        []
      end

      def storage_dir
        base = ENV['APPDATA'].to_s
        base = ENV['LOCALAPPDATA'].to_s if base.empty?
        base = ENV['HOME'].to_s if base.empty?
        base = Sketchup.temp_dir.to_s if base.empty? && Sketchup.respond_to?(:temp_dir)
        return nil if base.empty?

        dir = File.join(base, 'VADA', 'TimCongCuNhanh')
        FileUtils.mkdir_p(dir)
        dir
      rescue StandardError
        nil
      end

      def pins_file_path
        dir = storage_dir
        dir ? File.join(dir, 'pins.json') : nil
      end

      def sync_pins_storage(list)
        payload = JSON.generate(list || [])
        Sketchup.write_default(PREF_KEY, PINS_KEY, payload)
        Sketchup.write_default(PREF_KEY, "#{PINS_KEY}_backup", payload)

        path = pins_file_path
        if path
          tmp = "#{path}.tmp"
          File.open(tmp, 'wb') { |file| file.write(payload.encode('UTF-8')) }
          FileUtils.mv(tmp, path)
        end
        true
      rescue StandardError
        false
      end

      def alias_entry_for_key(key)
        aliases.find { |item| item['key'] == key }
      end

      def pin_entry_for_key(key)
        pins.find { |item| item['key'] == key }
      end

      def alias_for_key(key)
        item = alias_entry_for_key(key)
        item && item['alias']
      end

      def pinned_key?(key)
        !!pin_entry_for_key(key)
      end

      def save_alias(record, alias_name)
        normalized = clean_text(alias_name)
        return if normalized.empty?

        aliases.reject! do |item|
          item['key'] == record[:key] || clean_text(item['alias']).casecmp?(normalized)
        end
        aliases << {
          'key' => record[:key],
          'alias' => normalized,
          'target_name' => record[:name],
          'extension' => record[:extension],
          'source' => record[:source],
          'toolbar' => record[:toolbar]
        }
        persist_aliases
        register_alias_command(alias_entry_for_key(record[:key]))

        pin = pin_entry_for_key(record[:key])
        if pin
          pin['alias'] = normalized
          persist_pins
        end
      end

      def remove_alias(key)
        aliases.reject! { |item| item['key'] == key }
        persist_aliases
        pin = pin_entry_for_key(key)
        if pin
          pin['alias'] = ''
          persist_pins
        end
      end

      def persist_aliases
        Sketchup.write_default(PREF_KEY, ALIASES_KEY, JSON.generate(aliases))
      end

      def persist_pins
        sync_pins_storage(pins)
      end

      def apply_saved_data!(record)
        entry = alias_entry_for_key(record[:key])
        if entry
          record[:alias] = clean_text(entry['alias'])
          record[:shortcut] = shortcut_for_alias(record[:alias])
        end
        pin = pin_entry_for_key(record[:key])
        record[:pinned] = !!pin
        record[:pin_group] = pin ? normalized_group(pin['group']) : ''
        record
      end

      def shortcut_for_alias(alias_name)
        name = clean_text(alias_name)
        return '' if name.empty?

        shortcuts = Sketchup.respond_to?(:get_shortcuts) ? Sketchup.get_shortcuts : []
        matches = shortcuts.filter_map do |line|
          shortcut, path = line.to_s.split("\t", 2)
          next unless path
          leaf = path.split('/').last.to_s
          next unless leaf.casecmp?(name) || leaf.downcase.include?(name.downcase)
          shortcut.to_s.strip
        end
        matches.reject(&:empty?).uniq.join(', ')
      rescue StandardError
        ''
      end

      def register_saved_alias_commands
        aliases.each { |entry| register_alias_command(entry) }
      end

      def register_alias_command(entry)
        return unless entry.is_a?(Hash)
        key = clean_text(entry['key'])
        name = clean_text(entry['alias'])
        return if key.empty? || name.empty?

        @registered_aliases ||= {}
        return if @registered_aliases[key] == name

        command = UI::Command.new(name) { run_by_key(key) }
        command.tooltip = "#{name} → #{clean_text(entry['target_name'])}"
        command.status_bar_text = "Tên gợi nhớ của Tìm Công Cụ Nhanh cho #{clean_text(entry['target_name'])}"
        command.extension = EXTENSION if command.respond_to?(:extension=) && const_defined?(:EXTENSION, false)
        track_own_command(command)

        alias_menu.add_item(command)
        @alias_commands ||= []
        @alias_commands << command
        @registered_aliases[key] = name
      rescue StandardError
        nil
      end

      def register_saved_pin_commands(only_resolved = false)
        pins.sort_by { |entry| [normalized_group(entry['group']).downcase, clean_text(entry['alias']).downcase, clean_text(entry['target_name']).downcase] }
            .each do |entry|
          next if only_resolved && !saved_command_available?(entry)
          register_pin_command(entry)
        end
      end

      def saved_command_available?(entry)
        return false unless entry.is_a?(Hash)
        key = clean_text(entry['key'])
        return false if key.empty?

        command = @commands_by_key && @commands_by_key[key]
        command ||= find_command_fallback(entry)
        !command.nil?
      rescue StandardError
        false
      end

      def register_pin_command(entry, target_toolbar = nil, force_new = false)
        return unless entry.is_a?(Hash)
        key = clean_text(entry['key'])
        return if key.empty?

        group = normalized_group(entry['group'])
        registry_key = "#{key}\u001F#{group.downcase}"
        @registered_pins ||= {}
        return @registered_pins[registry_key] if @registered_pins[registry_key] && !force_new

        target_name = clean_text(entry['target_name'])
        alias_name = clean_text(entry['alias'])
        label = alias_name.empty? ? target_name : alias_name
        label = 'Quick Tool' if label.empty?

        command = UI::Command.new(label) do
          if pinned_key?(key) && pin_group_for_key(key).casecmp?(group)
            run_by_key(key)
          else
            UI.messagebox('Ghim này đã được gỡ hoặc chuyển nhóm. Khởi động lại SketchUp để dọn icon cũ khỏi thanh công cụ.')
          end
        end
        command.tooltip = alias_name.empty? ? target_name : "#{alias_name} → #{target_name}"
        command.status_bar_text = "#{group}: #{target_name}"
        command.extension = EXTENSION if command.respond_to?(:extension=) && const_defined?(:EXTENSION, false)
        command.set_validation_proc do
          pinned_key?(key) && pin_group_for_key(key).casecmp?(group) ? MF_ENABLED : MF_GRAYED
        end
        apply_pin_icons(command, entry)
        track_own_command(command)

        (target_toolbar || quick_tools_toolbar(group)).add_item(command)
        @pin_commands ||= []
        @pin_commands << command
        @registered_pins[registry_key] = command
        command
      rescue StandardError
        nil
      end

      def apply_pin_icons(command, entry)
        small = usable_icon(entry['small_icon']) || File.join(__dir__, 'icons', 'pin_24.png')
        large = usable_icon(entry['large_icon']) || File.join(__dir__, 'icons', 'pin_32.png')
        command.small_icon = small if File.file?(small)
        command.large_icon = large if File.file?(large)
      rescue StandardError
        nil
      end

      def usable_icon(path)
        value = clean_text(path)
        return nil if value.empty?
        expanded = File.expand_path(value) rescue value
        File.file?(expanded) ? expanded : nil
      rescue StandardError
        nil
      end

      def extension_menu
        UI.menu('Extensions')
      rescue StandardError
        UI.menu('Plugins')
      end

      def qtf_menu
        @qtf_menu ||= extension_menu.add_submenu('Tìm Công Cụ Nhanh')
      end

      def alias_menu
        @alias_menu ||= qtf_menu.add_submenu('Tên gợi nhớ')
      end

      def quick_tools_toolbar_name(group)
        "Quick Tools - #{normalized_group(group)}"
      end

      def quick_tools_toolbar_runtime_name(group)
        normalized = normalized_group(group)
        @quick_tools_toolbar_names ||= {}
        @quick_tools_toolbar_names[normalized] || quick_tools_toolbar_name(normalized)
      end

      def quick_tools_toolbar(group = 'Chưa phân loại')
        @quick_tools_toolbars ||= {}
        @quick_tools_toolbar_names ||= {}
        normalized = normalized_group(group)
        return @quick_tools_toolbars[normalized] if @quick_tools_toolbars[normalized]

        name = quick_tools_toolbar_name(normalized)
        toolbar = UI::Toolbar.new(name)
        @quick_tools_toolbars[normalized] = toolbar
        @quick_tools_toolbar_names[normalized] = name
        toolbar
      end

      def pin_groups
        pins.map { |entry| normalized_group(entry['group']) }.uniq.sort_by(&:downcase)
      end

      def hide_group_toolbar(group)
        normalized = normalized_group(group)
        toolbar = @quick_tools_toolbars && @quick_tools_toolbars[normalized]
        name = quick_tools_toolbar_runtime_name(normalized)
        toolbar.hide if toolbar
        UI.set_toolbar_visible(name, false) if UI.respond_to?(:set_toolbar_visible)
        true
      rescue StandardError
        false
      end

      def rebuild_group_toolbar(group)
        normalized = normalized_group(group)
        old_toolbar = @quick_tools_toolbars && @quick_tools_toolbars[normalized]
        old_name = quick_tools_toolbar_runtime_name(normalized)
        begin
          old_toolbar.hide if old_toolbar
          UI.set_toolbar_visible(old_name, false) if UI.respond_to?(:set_toolbar_visible)
        rescue StandardError
          nil
        end

        entries = pins.select { |entry| normalized_group(entry['group']).casecmp?(normalized) }
        @quick_tools_toolbars ||= {}
        @quick_tools_toolbar_names ||= {}
        @quick_tools_toolbar_generations ||= Hash.new(0)
        @quick_tools_toolbars.delete(normalized)

        return true if entries.empty?

        @quick_tools_toolbar_generations[normalized] += 1
        generation = @quick_tools_toolbar_generations[normalized]
        # SketchUp không có API xóa một item khỏi Toolbar. Tạo toolbar mới với tên
        # hiển thị tương đương (ký tự zero-width) để việc gỡ/chuyển nhóm có hiệu lực ngay.
        runtime_name = quick_tools_toolbar_name(normalized) + ("\u200B" * generation)
        toolbar = UI::Toolbar.new(runtime_name)
        @quick_tools_toolbars[normalized] = toolbar
        @quick_tools_toolbar_names[normalized] = runtime_name

        entries.sort_by { |entry| [clean_text(entry['alias']).downcase, clean_text(entry['target_name']).downcase] }.each do |entry|
          register_pin_command(entry, toolbar, true)
        end

        if group_visible?(normalized)
          show_named_toolbar(toolbar, runtime_name)
        else
          hide_group_toolbar(normalized)
        end
        true
      rescue StandardError => e
        UI.messagebox("Không làm mới được nhóm '#{normalized}'.\n\n#{e.class}: #{e.message}")
        false
      end

      def hide_group_toolbar_if_empty(group)
        normalized = normalized_group(group)
        return if pins.any? { |entry| normalized_group(entry['group']).casecmp?(normalized) }
        hide_group_toolbar(normalized)
      end

      def setup_ui
        @own_command_ids = {}

        finder_command = UI::Command.new('Tìm Công Cụ Nhanh') { show }
        finder_command.tooltip = 'Tìm Công Cụ Nhanh'
        finder_command.status_bar_text = 'Search and run SketchUp tools quickly.'
        finder_command.menu_text = 'Mở Tìm Công Cụ Nhanh' if finder_command.respond_to?(:menu_text=)
        finder_command.extension = EXTENSION if finder_command.respond_to?(:extension=) && const_defined?(:EXTENSION, false)
        track_own_command(finder_command)

        small_icon = File.join(__dir__, 'icons', 'search_24.png')
        large_icon = File.join(__dir__, 'icons', 'search_32.png')
        finder_command.small_icon = small_icon if File.file?(small_icon)
        finder_command.large_icon = large_icon if File.file?(large_icon)

        qtf_menu.add_item(finder_command)
        qtf_menu.add_item('Hiện icon Tìm Công Cụ Nhanh') { force_show_toolbar }
        qtf_menu.add_item('Hiện thanh Quick Tools đã ghim') { force_show_quick_tools_toolbar }
        qtf_menu.add_item('Đặt phím tắt cho Tìm Công Cụ Nhanh') { show_shortcuts_help('Tìm Công Cụ Nhanh') }
        qtf_menu.add_separator
        alias_menu

        @toolbar = UI::Toolbar.new(TOOLBAR_NAME)
        @toolbar.add_item(finder_command)
        force_show_toolbar

        group_names
        persist_groups
        persist_group_visibility
        pin_groups.each { |group| quick_tools_toolbar(group) }
        register_saved_alias_commands
        # Không dựng proxy ghim ngay khi plugin vừa load. Nhiều extension nguồn
        # đăng ký UI::Command muộn hơn, khiến proxy trỏ tới command chưa tồn tại.
        # Các lượt restore bên dưới chỉ dựng ghim sau khi tìm thấy command gốc.
        schedule_saved_pin_restore
      rescue StandardError => e
        UI.messagebox("Tìm Công Cụ Nhanh không thể khởi tạo thanh công cụ.\n\n#{e.class}: #{e.message}")
      end

      def force_show_toolbar
        show_named_toolbar(@toolbar, TOOLBAR_NAME)
      end

      def force_show_quick_tools_toolbar(group = nil)
        groups = if group
                   [normalized_group(group)]
                 else
                   pin_groups.select { |name| group_visible?(name) }
                 end
        groups.each do |name|
          next unless group_visible?(name)
          show_named_toolbar(quick_tools_toolbar(name), quick_tools_toolbar_runtime_name(name))
        end
        true
      end

      def apply_group_toolbar_visibility
        pin_groups.each do |name|
          if group_visible?(name)
            show_named_toolbar(quick_tools_toolbar(name), quick_tools_toolbar_runtime_name(name))
          else
            hide_group_toolbar(name)
          end
        end
        true
      rescue StandardError
        false
      end

      def schedule_saved_pin_restore
        [0.8, 2.5, 5.0].each do |delay|
          UI.start_timer(delay, false) { restore_saved_pins }
        end
      rescue StandardError
        nil
      end

      def restore_saved_pins
        reload_pins!
        return if pins.empty?

        # Quét lại command ở mỗi lượt retry vì extension nguồn có thể load muộn.
        build_index
        register_saved_pin_commands(true)
        apply_group_toolbar_visibility
      rescue StandardError
        nil
      end

      def show_named_toolbar(toolbar, name)
        toolbar.show if toolbar
        UI.set_toolbar_visible(name, true) if UI.respond_to?(:set_toolbar_visible)
        UI.start_timer(0.25, false) do
          begin
            toolbar.show if toolbar
            UI.set_toolbar_visible(name, true) if UI.respond_to?(:set_toolbar_visible)
          rescue StandardError
            nil
          end
        end
        true
      rescue StandardError
        false
      end

      def track_own_command(command)
        @own_command_ids ||= {}
        @own_command_ids[command.object_id] = true
        command
      end

      def own_command?(command)
        @own_command_ids && @own_command_ids[command.object_id]
      end

      def safe_call
        yield
      rescue StandardError
        nil
      end

      def safe_text
        clean_text(yield)
      rescue StandardError
        ''
      end

      def clean_text(value)
        value.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '').strip
      rescue StandardError
        value.to_s.strip
      end
    end

    unless file_loaded?(__FILE__)
      setup_ui
      file_loaded(__FILE__)
    end
  end
end
