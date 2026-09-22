# Changelog

## v0.4.4 — 2026-09-22

- Fixed: hộp thoại “Không tìm thấy công cụ gốc” bị mở lặp lại khi SketchUp khởi động.
- Fixed: proxy ghim được tạo quá sớm trước khi extension nguồn đăng ký command.
- Changed: restore ghim quét lại command trước mỗi lượt retry và chỉ tạo proxy khi target đã resolve.
- Changed: target tạm thời không tìm thấy chỉ báo ở status bar, không dùng modal messagebox.
- Preserved: icon tìm kiếm, nhóm ghim, ẩn/hiện nhóm, aliases và shortcut helper.
