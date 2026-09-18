# 02 - Dọn plugin rác

**Phiên bản mới nhất:** v1.4.0

Plugin tìm, kiểm tra, thử hiển thị, tắt, cách ly, gỡ hẳn và khôi phục nhanh plugin/extension SketchUp.

## Chức năng chính

- Quét Extension Manager và thư mục Plugins.
- Tìm kiếm, lọc theo lỗi nạp, trạng thái tắt, plugin không quản lý và thư viện phụ thuộc.
- **Thử hiển thị (mới v1.4.0):** nạp tạm plugin vào phiên SketchUp hiện tại để xem toolbar/menu của nó là gì, trước khi quyết định tắt/cách ly/gỡ — không đổi trạng thái bật/tắt đã lưu, không cần khởi động lại.
- **Gỡ hẳn (mới v1.4.0):** xoá vĩnh viễn file/thư mục plugin, khác với Cách ly (có thể khôi phục). Yêu cầu gõ xác nhận trước khi thực hiện và có ghi log riêng (`removed_log.json`) trong vùng Cách ly để tra cứu sau này.
- Chọn nhiều plugin để tắt, cách ly, gỡ hẳn hoặc khôi phục.
- Giảm nguy cơ xử lý nhầm LibFredo, TT_Lib và AMS_Lib.
- Đã sửa lỗi callback UI::ActionCallbackContext.

## File phát hành

- v1.4.0/VADA_Don_Plugin_v1.4.0.rbz
- v1.4.0/VADA_Don_Plugin_v1.4.0_source.zip
- v1.3.0/VADA_Don_Plugin_v1.3.0.rbz
- v1.3.0/VADA_Don_Plugin_v1.3.0_source.zip
