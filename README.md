# VADA SketchUp Plugins

Kho plugin SketchUp nội bộ của **Công ty TNHH VADA**.

## Danh sách plugin

| # | Plugin | Phiên bản mới nhất | Gói cài |
|---|---|---:|---|
| 01 | Ghi kích thước tự động | v1.1.0 | Chưa đủ RBZ + source đã kiểm thử |
| 02 | Dọn plugin rác | v1.3.0 | Có RBZ + source |
| 03 | Tìm công cụ nhanh | v0.4.1 | RBZ bản mới nhất chưa có |
| 04 | Tạo mặt cắt và góc nhìn | v1.6.0 | Có RBZ + source |
| 05 | Tính tổng độ dài cạnh | v1.0.1 | Có RBZ + source |
| 06 | Thống kê sắt hộp | v1.1.1 | Có RBZ + source |
| 07 | Tính tổng diện tích | v1.0.1 | Có RBZ + source; RBZ hiện nằm ở đường dẫn legacy |
| 08 | VADA Plugin Manager | v1.3.1 | Có RBZ + source |
| 09 | Tạo phòng nhanh | v1.0.0 | Có RBZ + source |

## Ghi chú phiên bản mới nhất

### 01 - Ghi kích thước tự động — v1.1.0
- Hỗ trợ ghi kích thước nhanh cho mặt tròn/mặt cong khó bắt điểm.
- Tối ưu hiển thị thông tin kích thước trực quan hơn.
- Trạng thái kho hiện chưa đủ bộ RBZ + source đã kiểm thử của v1.1.0.

### 02 - Dọn plugin rác — v1.3.0
- Kế thừa bản v1.2.1 đã sửa lỗi callback `UI::ActionCallbackContext`.
- Tối ưu giao diện, tìm kiếm, bộ lọc và sắp xếp.
- Cải thiện vùng Cách ly và nhận diện thư viện phụ thuộc.
- Giảm nguy cơ thao tác nhầm với LibFredo, TT_Lib và AMS_Lib.

### 03 - Tìm công cụ nhanh — v0.4.1
- Sửa chức năng gỡ ghim.
- Cải thiện quản lý nhóm ghim: tạo, đổi tên, xóa nhóm.
- Giữ khả năng lưu/khôi phục các ghim sau khi khởi động lại SketchUp.
- Bản v0.4.1 hiện chưa có RBZ trong kho.

### 04 - Tạo mặt cắt và góc nhìn — v1.6.0
- Thêm Scene `ALL` nhìn tổng toàn bộ model.
- ALL dùng camera Perspective 35°.
- ALL không dùng Section Plane và tự tắt mặt cắt đang active.
- Giữ 6 Scene mặt cắt: MB, VIEW TRẦN, MD1, MD2, MC1, MC2.
- Các Scene mặt cắt tiếp tục kích hoạt đúng Section Plane tương ứng.

### 05 - Tính tổng độ dài cạnh — v1.0.1
- Đổi phần hiển thị kích thước sang chữ đỏ.
- Thêm badge số thứ tự #1, #2... để không lẫn với số đo.
- Thêm nền tối phía sau chữ để dễ đọc trên model.

### 06 - Thống kê sắt hộp — v1.1.1
- Cải thiện nhận diện tiết diện sắt hộp.
- Sửa trường hợp một số hộp chưa được tô màu.
- Giữ thống kê tổng chiều dài, số lượng và phân loại theo tiết diện.

### 07 - Tính tổng diện tích — v1.0.1
- Đổi phần hiển thị diện tích sang chữ đỏ.
- Thêm badge số thứ tự #1, #2... và nền tối phía sau chữ.
- RBZ v1.0.1 đã có trong repo nhưng hiện nằm tại đường dẫn legacy `VADA-Tong-Dien-Tich/...`.
- Cần tiếp tục chuẩn hóa RBZ vào đúng thư mục `07 - Tính tổng diện tích` để cấu trúc phát hành đồng nhất.

### 08 - VADA Plugin Manager — v1.3.1
- Sửa lỗi toolbar/icon không hiện sau khi cài v1.3.0.
- Giữ tham chiếu toolbar và tự ép hiển thị sau khi SketchUp khởi tạo UI.
- Plugin mới trên GitHub nhưng chưa cài trong SketchUp được đưa lên đầu danh sách.
- Có nút **Cài mới** và tự phát hiện plugin mới từ cây thư mục GitHub.
- Giữ cơ chế nhận diện phiên bản từ SketchUp Extensions, fallback quét file Ruby.
- Hỗ trợ `reload_candidates` để reload phần core an toàn.
- `Tạo mặt cắt và góc nhìn` dùng hot reload phần core nên cập nhật logic không còn mặc định yêu cầu restart.

### 09 - Tạo phòng nhanh — v1.0.0
- Phiên bản phát hành đầu tiên.
- Tạo nhanh một căn phòng trong SketchUp.
- Có gói RBZ + source để cài đặt và tiếp tục phát triển.

## Cấu trúc chuẩn

- Thư mục plugin dùng số thứ tự 01 đến 09.
- Mỗi phiên bản mới ưu tiên nằm trong thư mục `vX.Y.Z` và không ghi đè bản cũ.
- Tên plugin, cửa sổ và nhãn giao diện ưu tiên tiếng Việt.
- Giao diện VADA dùng nền `#000000` và hiển thị rõ phiên bản hiện tại.
- Plugin có toolbar phải có icon rõ, dễ nhận biết ở kích thước nhỏ.
- Khi phát hành bản mới phải cập nhật đồng thời source, file RBZ, README và `vada_plugin_manifest.json`.
- Mỗi phiên bản mới phải có ghi chú: **đã thêm gì, đã sửa lỗi gì, có thay đổi hành vi nào**.
- VADA Plugin Manager dùng cây thư mục GitHub để kiểm tra phiên bản mới.

## File hệ thống

- `vada_plugin_manifest.json`: nhận diện plugin, loader, hot reload và đường dẫn kho.
- `README.md`: trang tổng quan, trạng thái phát hành và changelog tóm tắt.
