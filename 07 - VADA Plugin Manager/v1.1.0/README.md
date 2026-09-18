# VADA Plugin Manager v1.1.0

## Thay đổi
- Quét trực tiếp Git tree của repository bằng 1 request.
- Tự tìm thư mục phiên bản `vX.Y.Z` cao nhất cho từng plugin.
- Tự tìm file `.RBZ` thuộc phiên bản mới nhất.
- Không còn phụ thuộc `latest_version` trong manifest khi kiểm tra cập nhật.
- Chỉ bật nút Cập nhật khi phiên bản GitHub mới hơn phiên bản trên máy.
- Hiển thị thời điểm quét và số plugin có bản mới.
- Giữ cơ chế hot reload an toàn; plugin không hỗ trợ sẽ báo cần khởi động lại SketchUp.
