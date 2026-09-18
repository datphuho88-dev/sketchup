# 02 - Dọn plugin rác

**Phiên bản mới nhất:** v1.4.1

Plugin tìm, kiểm tra, thử hiển thị, tắt, cách ly, gỡ hẳn và khôi phục nhanh plugin/extension SketchUp.

## Chức năng chính

- Quét Extension Manager và thư mục Plugins.
- Tìm kiếm, lọc theo lỗi nạp, trạng thái tắt, plugin không quản lý và thư viện phụ thuộc.
- **Thử hiển thị:** với extension đã đăng ký, v1.4.1 dùng `SketchupExtension#check` để nạp code thực thi ngay trong phiên SketchUp hiện tại.
- Nếu extension vốn đang tắt khi khởi động, sau khi thử plugin trả trạng thái lưu về tắt bằng `uncheck`; code đã nạp vẫn tồn tại đến khi đóng SketchUp.
- Plugin cài thủ công chỉ thử nạp loader phù hợp, tránh chạy bừa toàn bộ file Ruby.
- Lỗi nạp khi Thử hiển thị được báo trực tiếp.
- **Gỡ hẳn:** xoá vĩnh viễn file/thư mục plugin, có xác nhận và log riêng.
- Chọn nhiều plugin để tắt, cách ly, gỡ hẳn hoặc khôi phục.
- Giảm nguy cơ xử lý nhầm LibFredo, TT_Lib và AMS_Lib.
- Tối ưu cho SketchUp 2023.

## File phát hành

- v1.4.1/VADA_Don_Plugin_v1.4.1.rbz
- v1.4.1/VADA_Don_Plugin_v1.4.1_source.zip
- v1.4.0/VADA_Don_Plugin_v1.4.0.rbz
- v1.4.0/VADA_Don_Plugin_v1.4.0_source.zip
- v1.3.0/VADA_Don_Plugin_v1.3.0.rbz
- v1.3.0/VADA_Don_Plugin_v1.3.0_source.zip

## Cài đặt

SketchUp → Extension Manager → Install Extension → chọn file RBZ. Sau khi cập nhật nên thoát hoàn toàn SketchUp rồi mở lại.
