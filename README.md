# VADA SketchUp Plugins

Kho plugin SketchUp nội bộ của **Công ty TNHH VADA**.

## Danh sách plugin

| # | Plugin | Phiên bản mới nhất | Gói cài |
|---|---|---:|---|
| 01 | Ghi kích thước tự động | v1.1.0 | Chưa đủ RBZ + source đã kiểm thử |
| 02 | Dọn plugin rác | v1.3.0 | Có RBZ + source |
| 03 | Tìm công cụ nhanh | v0.4.2 | Có RBZ + source |
| 04 | Tạo mặt cắt và góc nhìn | v1.6.0 | Có RBZ + source |
| 05 | Tính tổng độ dài cạnh | v1.0.1 | Có RBZ + source |
| 06 | Thống kê sắt hộp | v1.1.1 | Có RBZ + source |
| 07 | Tính tổng diện tích | v1.0.1 | Có RBZ + source |
| 08 | VADA Plugin Manager | v1.3.3 | Có RBZ + source |
| 09 | Tạo phòng nhanh | v1.1.0 | Có RBZ + source |
| 10 | VADA Workspace Manager | v1.0.2 | Có RBZ + source |
| 11 | Quản lý Style Dim & Ghi chú | v1.1.1 | Có RBZ + source |

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

### 03 - Tìm công cụ nhanh — v0.4.2
- Thêm ghim/hiện riêng từng nhóm toolbar.
- Thêm ẩn riêng từng nhóm mà không xóa các công cụ đã ghim.
- Lưu trạng thái hiện/ẩn của từng nhóm và tự khôi phục sau khi mở lại SketchUp.
- Giữ nguyên gỡ ghim, quản lý nhóm, tên gợi nhớ và phím tắt.
- Có đầy đủ RBZ + source archive của v0.4.2.

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
- RBZ v1.0.1 và source đã được chuẩn hóa vào đúng thư mục `07 - Tính tổng diện tích`.
- Đường dẫn legacy đã được loại bỏ sau khi sao lưu đầy đủ file phiên bản.

### 08 - VADA Plugin Manager — v1.3.3
- Sửa lỗi nhận sai phiên bản máy (ví dụ v1.6.0 bị đọc thành v1.0.3).
- Ưu tiên Extension chính xác và đối chiếu thêm loader/core để lấy phiên bản cao nhất hợp lệ.
- Sửa lỗi đóng cửa sổ rồi mở lại bị trắng.
- Tự tạo HtmlDialog mới sau khi cửa sổ cũ đã đóng.
- Tự kiểm tra GitHub khi mở và bổ sung danh mục offline đầy đủ 01-10.
- Tạo phòng nhanh được hiển thị ngay cả trước khi quét GitHub.
- Sửa lỗi toolbar/icon không hiện sau khi cài v1.3.0.
- Giữ tham chiếu toolbar và tự ép hiển thị sau khi SketchUp khởi tạo UI.
- Plugin mới trên GitHub nhưng chưa cài trong SketchUp được đưa lên đầu danh sách.
- Có nút **Cài mới** và tự phát hiện plugin mới từ cây thư mục GitHub.
- Giữ cơ chế nhận diện phiên bản từ SketchUp Extensions, fallback quét file Ruby.
- Hỗ trợ `reload_candidates` để reload phần core an toàn.
- `Tạo mặt cắt và góc nhìn` dùng hot reload phần core nên cập nhật logic không còn mặc định yêu cầu restart.

### 09 - Tạo phòng nhanh — v1.1.0
- Tự động tô màu phân biệt **Sàn / Tường / Trần** ngay sau khi tạo phòng.
- Sàn dùng màu nâu, tường màu kem sáng, trần màu trắng.
- Đổi tên group phía trên từ **Mái** thành **Trần** để dễ quản lý trong Outliner.
- Giữ nguyên cách nhập kích thước và cách đặt phòng của v1.0.0.

### 10 - VADA Workspace Manager — v1.0.2
- Thêm ô **Tìm nhanh toolbar / plugin** theo tên.
- Thêm bộ lọc **TẤT CẢ / ĐANG HIỆN / ĐANG ẨN / MỚI / GIỮ**.
- Toolbar đang hiện luôn được đưa lên đầu danh sách, không phải cuộn xuống tìm.
- Hiển thị số kết quả đang lọc trên tổng số toolbar.
- Giữ trạng thái các ô **GIỮ** khi tìm kiếm/lọc.
- Phím `/` để tập trung ô tìm kiếm và `Esc` để xóa tìm kiếm.
- Giữ nguyên toàn bộ cơ chế ẩn/hiện trực tiếp `UI::Toolbar`, profile, hoàn tác và tự dọn của v1.0.1.


### 11 - Quản lý Style Dim & Ghi chú — v1.1.1
- Sửa trường hợp Dimension do plugin khác tạo không nhận Style.
- Theo dõi cả model root, active context và toàn bộ Component/Group definitions.
- Gắn DefinitionsObserver để bắt definition mới do plugin tạo.
- Gom Dimension/Text mới theo batch và áp Style sau khi transaction nguồn kết thúc, tránh plugin nguồn ghi đè lại Style VADA.
- Không dùng polling hoặc quét model liên tục.
- Giữ các chức năng preset, đơn vị, màu, mũi tên, vị trí chữ và tùy chọn Bold của v1.1.0.
- SketchUp 2023 vẫn không có Ruby API để đổi font/cỡ/Bold trực tiếp của Dimension; phần này cần đặt native trong Model Info → Dimensions.
## Cấu trúc chuẩn

- Thư mục plugin dùng số thứ tự 01 đến 100.
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
