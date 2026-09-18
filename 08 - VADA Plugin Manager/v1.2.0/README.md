# VADA Plugin Manager v1.2.0

## Sửa lỗi nhận diện plugin trên máy
- Ưu tiên đọc trực tiếp SketchUp Extensions để lấy tên và phiên bản extension đang cài.
- Không còn phụ thuộc hoàn toàn vào tên file loader .rb.
- Fallback quét file .rb trong thư mục Plugins khi extension không có metadata đầy đủ.
- Dò phiên bản từ VERSION, PLUGIN_VERSION, EXTENSION_VERSION và extension.version.
- Sửa thông báo sai “đã reload” khi cập nhật xong nhưng chưa xác định được loader.
- Chỉ cho Reload khi đã xác định được file reload an toàn.
- Giữ cơ chế tự quét phiên bản mới nhất trực tiếp từ cây thư mục GitHub.
