# VADA Plugin Manager

**Phiên bản mới nhất: v1.5.0**

Plugin trung tâm của VADA để quản lý cài mới, cập nhật, reload, sao lưu, cài lại và gỡ plugin SketchUp.

## Mới ở v1.5.0

- Tối ưu tốc độ mở cửa sổ: giao diện hiển thị trước, không chờ GitHub.
- Kiểm tra GitHub chạy nền; chỉ phần mạng/JSON chạy Thread, lệnh SketchUp vẫn quay về main thread bằng timer.
- Cache danh sách cục bộ 30 giây để giảm quét extension/file lặp lại.
- Sửa phát hiện bản mới: ưu tiên `vada_plugin_manifest.json`, quét Git tree để tìm version cao nhất, và fallback về manifest nếu Tree API lỗi/rate-limit.
- Tab **KHO PLUGIN NGOÀI** có tìm kiếm và bộ lọc:
  - Tất cả.
  - Đóng gói & lưu được.
  - Đã sao lưu GitHub.
  - Chưa sao lưu.
  - Chỉ có trên kho / PC khác.
- Hiển thị icon plugin ngoài để xem trước.
- Đóng gói RBZ từ loader `.rb` + thư mục support cùng tên.
- Sao lưu RBZ + metadata lên `90 - Kho plugin ngoài`.
- Kiểm tra SHA-256 trước khi cài lại.
- Có **Cài nhanh** trên PC khác.
- Có **Gỡ** plugin VADA/plugin ngoài; không tự gỡ chính Plugin Manager đang chạy.
- Plugin chứa `.rbe/.rbs` không tự upload RBZ lên repo công khai.
- GitHub token chỉ giữ trong RAM và bị xóa khi đóng cửa sổ.

## Dùng trên PC khác

1. Cài `VADA_Plugin_Manager_v1.5.0.rbz` bằng SketchUp Extension Manager.
2. Mở **VADA Plugin Manager** → **KHO PLUGIN NGOÀI**.
3. Chọn bộ lọc **Đã sao lưu** hoặc **Chỉ có trên kho / PC khác**.
4. Bấm **Cài nhanh**.
5. Plugin tải RBZ, kiểm tra SHA-256 rồi cài.
6. Với plugin không reload an toàn, khởi động lại SketchUp.

## File cài đặt

`VADA_Plugin_Manager_v1.5.0.rbz`

## Source

`VADA_Plugin_Manager_v1.5.0_source.zip`

Sau khi nâng từ bản cũ, nên thoát hoàn toàn SketchUp rồi mở lại.
