# 🧩 VADA SketchUp Plugins

Kho plugin SketchUp nội bộ của **Công ty TNHH VADA**.

## 📦 Danh sách plugin

| # | Plugin | Phiên bản mới nhất | Gói cài |
|---|---|---:|---|
| 01 | 📏 Ghi kích thước tự động | v1.1.0 | Chưa đủ RBZ + source đã kiểm thử |
| 02 | 🧹 Dọn plugin rác | v1.4.2 | Có RBZ + source |
| 03 | 🔎 Tìm công cụ nhanh | v0.4.2 | Có RBZ + source |
| 04 | ✂️ Tạo mặt cắt và góc nhìn | v1.6.0 | Có RBZ + source |
| 05 | 📐 Tính tổng độ dài cạnh | v1.0.1 | Có RBZ + source |
| 06 | 🧱 Thống kê sắt hộp | v1.1.1 | Có RBZ + source |
| 07 | ◻️ Tính tổng diện tích | v1.0.1 | Có RBZ + source |
| 08 | 🔄 VADA Plugin Manager | v1.4.0 | Có RBZ + source |
| 09 | 🏠 Tạo phòng nhanh | v1.1.0 | Có RBZ + source |
| 10 | 🗂️ VADA Workspace Manager | v1.0.3 | Có RBZ + source |
| 11 | ✏️ Quản lý Style Dim & Ghi chú | v1.2.0 | Có RBZ + source |
| 12 | 📌 Chọn toàn bộ DIM | v1.0.0 | Có RBZ + source |

## 📝 Ghi chú phiên bản mới nhất

## 🗂️ Nhìn nhanh cấu trúc thư mục

> GitHub không hỗ trợ icon tùy chỉnh cho folder. Repo dùng emoji trong README để nhận diện nhanh mà không đổi đường dẫn thật, tránh làm hỏng Plugin Manager và link RBZ.

- 📏 `01 - Ghi kích thước tự động/`
- 🧹 `02 - Dọn plugin rác/`
- 🔎 `03 - Tìm công cụ nhanh/`
- ✂️ `04 - Tạo mặt cắt và góc nhìn/`
- 📐 `05 - Tính tổng độ dài cạnh/`
- 🧱 `06 - Thống kê sắt hộp/`
- ◻️ `07 - Tính tổng diện tích/`
- 🔄 `08 - VADA Plugin Manager/`
- 🏠 `09 - Tạo phòng nhanh/`
- 🗂️ `10 - VADA Workspace Manager/`
- ✏️ `11 - Quản lý Style Dim & Ghi chú/`
- 📌 `12 - Chọn toàn bộ DIM/`

### 📄 Quy ước tệp
- 📦 `*.rbz` — file cài plugin.
- 💎 `*.rb` — mã Ruby/loader.
- 🌐 `*.html`, `*.css`, `*.js` — giao diện HTMLDialog.
- 🖼️ `*.png`, `*.svg` — icon và tài nguyên hình ảnh.
- 📝 `README.md` — mô tả, lịch sử phiên bản và hướng dẫn.
- ⚙️ `vada_plugin_manifest.json` — dữ liệu Plugin Manager dùng để nhận diện/cập nhật.
- 🗃️ `vX.Y.Z/` — thư mục lưu từng phiên bản, không ghi đè bản cũ.


### 📏 01 - Ghi kích thước tự động — v1.1.0
- Hỗ trợ ghi kích thước nhanh cho mặt tròn/mặt cong khó bắt điểm.
- Tối ưu hiển thị thông tin kích thước trực quan hơn.
- Trạng thái kho hiện chưa đủ bộ RBZ + source đã kiểm thử của v1.1.0.

### 🧹 02 - Dọn plugin rác — v1.4.2
- Sửa lỗi đóng gói của v1.4.1: file RBZ trên GitHub trước đó bị trỏ nhầm cùng blob với source ZIP nên SketchUp không cài được.
- Đóng gói lại RBZ đúng cấu trúc SketchUp Extension Manager.
- Giữ nguyên sửa lỗi **Thử hiển thị** từ v1.4.1.

### 🧹 02 - Dọn plugin rác — v1.4.1
- Sửa **Thử hiển thị**: extension đã đăng ký được nạp bằng `SketchupExtension#check`, thay vì chạy lại loader ngoài đã bị `file_loaded?` chặn.
- Giữ nguyên trạng thái bật/tắt khi khởi động: extension vốn tắt sẽ được `uncheck` lại sau khi thử.
- Plugin cài thủ công chỉ thử loader phù hợp và báo lỗi nạp trực tiếp.
- Giữ nguyên Gỡ hẳn, Cách ly, Khôi phục, tìm kiếm và bộ lọc của v1.4.0.

### 🧹 02 - Dọn plugin rác — v1.4.0
- Thêm **Thử hiển thị**: nạp tạm plugin vào phiên SketchUp hiện tại để xem toolbar/menu trước khi tắt/cách ly/gỡ, không cần khởi động lại và không đổi trạng thái bật/tắt đã lưu.
- Thêm **Gỡ hẳn**: xoá vĩnh viễn file/thư mục plugin thay vì chỉ tắt hoặc cách ly. Yêu cầu gõ xác nhận trước khi xoá, có log riêng để tra cứu lại.
- Giữ nguyên toàn bộ cơ chế quét, tắt, cách ly và khôi phục của v1.3.0.

### 🧹 02 - Dọn plugin rác — v1.3.0
- Kế thừa bản v1.2.1 đã sửa lỗi callback `UI::ActionCallbackContext`.
- Tối ưu giao diện, tìm kiếm, bộ lọc và sắp xếp.
- Cải thiện vùng Cách ly và nhận diện thư viện phụ thuộc.
- Giảm nguy cơ thao tác nhầm với LibFredo, TT_Lib và AMS_Lib.

### 🔎 03 - Tìm công cụ nhanh — v0.4.2
- Thêm ghim/hiện riêng từng nhóm toolbar.
- Thêm ẩn riêng từng nhóm mà không xóa các công cụ đã ghim.
- Lưu trạng thái hiện/ẩn của từng nhóm và tự khôi phục sau khi mở lại SketchUp.
- Giữ nguyên gỡ ghim, quản lý nhóm, tên gợi nhớ và phím tắt.
- Có đầy đủ RBZ + source archive của v0.4.2.

### ✂️ 04 - Tạo mặt cắt và góc nhìn — v1.6.0
- Thêm Scene `ALL` nhìn tổng toàn bộ model.
- ALL dùng camera Perspective 35°.
- ALL không dùng Section Plane và tự tắt mặt cắt đang active.
- Giữ 6 Scene mặt cắt: MB, VIEW TRẦN, MD1, MD2, MC1, MC2.
- Các Scene mặt cắt tiếp tục kích hoạt đúng Section Plane tương ứng.

### 📐 05 - Tính tổng độ dài cạnh — v1.0.1
- Đổi phần hiển thị kích thước sang chữ đỏ.
- Thêm badge số thứ tự #1, #2... để không lẫn với số đo.
- Thêm nền tối phía sau chữ để dễ đọc trên model.

### 🧱 06 - Thống kê sắt hộp — v1.1.1
- Cải thiện nhận diện tiết diện sắt hộp.
- Sửa trường hợp một số hộp chưa được tô màu.
- Giữ thống kê tổng chiều dài, số lượng và phân loại theo tiết diện.

### ◻️ 07 - Tính tổng diện tích — v1.0.1
- Đổi phần hiển thị diện tích sang chữ đỏ.
- Thêm badge số thứ tự #1, #2... và nền tối phía sau chữ.
- RBZ v1.0.1 và source đã được chuẩn hóa vào đúng thư mục `07 - Tính tổng diện tích`.
- Đường dẫn legacy đã được loại bỏ sau khi sao lưu đầy đủ file phiên bản.

### 🔄 08 - VADA Plugin Manager — v1.4.0
- Thêm tab **KHO PLUGIN NGOÀI** để quét extension ngoài đang cài trên máy.
- Có thể lưu metadata: tên, version, tác giả và link nguồn.
- Plugin người dùng có quyền sao lưu/phân phối có thể được đóng gói thành RBZ và lưu trong `90 - Kho plugin ngoài`.
- Mỗi version được giữ riêng; máy khác đọc `external_plugins_manifest.json` và có nút **CÀI NHANH**.
- Kiểm tra SHA-256 trước khi cài gói đã lưu.
- GitHub token chỉ giữ trong RAM phiên SketchUp, không ghi xuống file.
- Plugin có `.rbe/.rbs` không được tự đưa RBZ lên repo công khai; chỉ lưu metadata/link nguồn.
- Giữ nguyên kiểm tra GitHub, cài mới/cập nhật, nhận diện version và reload an toàn.


### 🏠 09 - Tạo phòng nhanh — v1.1.0
- Tự động tô màu phân biệt **Sàn / Tường / Trần** ngay sau khi tạo phòng.
- Sàn dùng màu nâu, tường màu kem sáng, trần màu trắng.
- Đổi tên group phía trên từ **Mái** thành **Trần** để dễ quản lý trong Outliner.
- Giữ nguyên cách nhập kích thước và cách đặt phòng của v1.0.0.

### 🗂️ 10 - VADA Workspace Manager — v1.0.3
- Sửa trường hợp vừa **DỌN NHANH PLUGIN** xong nhưng một số toolbar/icon lại tự xuất hiện.
- Khi người dùng thao tác thủ công, plugin hủy các lượt startup cleanup còn chờ để không áp profile cũ.
- Sau khi dọn, kiểm tra lại theo các lượt ngắn `0.15 / 0.5 / 1.2 / 2.5 / 4 giây` để bắt toolbar do extension khác tự bật trễ.
- Thêm **CHỌN TẤT CẢ KẾT QUẢ / BỎ CHỌN TẤT CẢ / ẨN ĐÃ CHỌN / HIỆN ĐÃ CHỌN**.
- Chọn tất cả chỉ áp dụng cho danh sách đang lọc/tìm kiếm.
- Tách rõ checkbox **CHỌN** thao tác hàng loạt và checkbox **GIỮ** cho Dọn nhanh.
- Toolbar đang hiện vẫn được ưu tiên lên đầu; giữ tìm kiếm và bộ lọc của v1.0.2.


### ✏️ 11 - Quản lý Style Dim & Ghi chú — v1.2.0
- Làm lại giao diện theo dạng **thư viện Style**: danh sách bộ Style bên trái, khu chỉnh sửa bên phải, thao tác nhanh và rõ trạng thái chưa lưu.
- Thêm **Tạo Style mới / Nhân bản / Đổi tên / Xóa / Lưu thay đổi**; tên từng bộ Style được lưu độc lập để dùng lại khi mở file SketchUp khác.
- Làm lại cơ chế bắt Dimension native do plugin khác tạo bằng snapshot `persistent_id` sau transaction, kèm theo dõi entity mới/sửa để hạn chế plugin nguồn ghi đè Style.
- Thêm **Kiểm tra đối tượng đang chọn** để xác định plugin Dim đang tạo Dimension native hay chỉ vẽ Line/Text/Overlay riêng.
- Giữ áp Style cho toàn model hoặc đối tượng đang chọn, đơn vị, màu, mũi tên, vị trí chữ, ghi chú và tự áp.
- Không giả lập **Bold**: SketchUp 2023 Ruby API không cho extension đổi font/cỡ/Bold của Dimension; preset vẫn nhớ lựa chọn và UI mở đúng Model Info → Dimensions để đặt native.
- Không dùng polling quét model liên tục; ưu tiên observer + kiểm tra sau transaction.


### 📌 12 - Chọn toàn bộ DIM — v1.0.0
- Phát hành đầu tiên.
- Bấm một lần để quét và chọn toàn bộ Dimension native trong model.
- Quét đệ quy DIM nằm trong Group/Component lồng nhiều cấp.
- Bổ sung nhận diện đối tượng DIM do AutoDim/AuDim tạo qua tên, Tag/Layer và Attribute Dictionary.
- Có toolbar riêng, icon riêng, giao diện tiếng Việt nền đen và hiển thị rõ version v1.0.0.
- RBZ và source archive của v1.0.0 được lưu cùng thư mục version để máy khác có thể cài qua VADA Plugin Manager.

## 🧱 Cấu trúc chuẩn

- Thư mục plugin dùng số thứ tự 01 đến 100.
- Mỗi phiên bản mới ưu tiên nằm trong thư mục `vX.Y.Z` và không ghi đè bản cũ.
- Tên plugin, cửa sổ và nhãn giao diện ưu tiên tiếng Việt.
- Giao diện VADA dùng nền `#000000` và hiển thị rõ phiên bản hiện tại.
- Plugin có toolbar phải có icon rõ, dễ nhận biết ở kích thước nhỏ.
- Khi phát hành bản mới phải cập nhật đồng thời source, file RBZ, README và `vada_plugin_manifest.json`.
- Mỗi phiên bản mới phải có ghi chú: **đã thêm gì, đã sửa lỗi gì, có thay đổi hành vi nào**.
- VADA Plugin Manager dùng cây thư mục GitHub để kiểm tra phiên bản mới.

## ⚙️ File hệ thống

- `vada_plugin_manifest.json`: nhận diện plugin, loader, hot reload và đường dẫn kho.
- `README.md`: trang tổng quan, trạng thái phát hành và changelog tóm tắt.
