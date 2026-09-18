# VADA SketchUp Plugins

Kho plugin SketchUp nội bộ của **Công ty TNHH VADA**.

## Danh sách plugin

| # | Plugin | Phiên bản mới nhất | Gói cài |
|---|---|---:|---|
| 01 | Ghi kích thước tự động | v1.1.0 | Chưa có RBZ trong kho |
| 02 | Dọn plugin rác | v1.3.0 | Có RBZ + source |
| 03 | Tìm công cụ nhanh | v0.4.1 | RBZ bản mới nhất chưa có |
| 04 | Tạo mặt cắt và góc nhìn | v1.5.0 | Có RBZ + source |
| 05 | Tính tổng độ dài cạnh | v1.0.1 | Có RBZ + source |
| 06 | Thống kê sắt hộp | v1.1.1 | Có RBZ + source |
| 07 | Tính tổng diện tích | v1.0.1 | Source v1.0.1; RBZ hiện có v1.0.0 |
| 08 | VADA Plugin Manager | v1.1.0 | Có RBZ + source |

## Cấu trúc chuẩn

- Thư mục plugin dùng số thứ tự 01 đến 08.
- Mỗi phiên bản mới ưu tiên nằm trong thư mục vX.Y.Z và không ghi đè bản cũ.
- Tên plugin, cửa sổ và nhãn giao diện ưu tiên tiếng Việt.
- Giao diện VADA dùng nền #000000 và hiển thị rõ phiên bản hiện tại.
- Plugin có toolbar phải có icon rõ, dễ nhận biết ở kích thước nhỏ.
- Khi phát hành bản mới phải cập nhật đồng thời source, file RBZ, README và vada_plugin_manifest.json.
- VADA Plugin Manager dùng cây thư mục GitHub để kiểm tra phiên bản mới.

## File hệ thống

- vada_plugin_manifest.json: nhận diện plugin, loader, hot reload và đường dẫn kho.
- README.md: trang tổng quan và trạng thái phát hành.
