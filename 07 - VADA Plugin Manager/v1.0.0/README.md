# VADA Plugin Manager v1.0.0

Plugin quản lý chung cho các plugin SketchUp của Công ty TNHH VADA.

## Chức năng
- Quét và hiển thị các plugin VADA đang cài.
- Kiểm tra phiên bản mới từ manifest trên GitHub.
- Tải và cài gói .RBZ trực tiếp khi plugin có gói cập nhật.
- Reload plugin ngay trong SketchUp nếu plugin được đánh dấu hỗ trợ hot reload.
- Reload tất cả plugin hỗ trợ mà không cần khởi động lại SketchUp.
- Plugin không có .RBZ sẽ chỉ hiện trạng thái, không bị ghi đè.

## Lưu ý
Một số plugin cũ chưa tách loader/core theo chuẩn hot reload. Các plugin đó được đánh dấu cần khởi động lại cho đến khi được chuẩn hóa.
