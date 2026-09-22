# VADA Giảm Poly

**Phiên bản mới nhất:** v1.0.0  
**Tương thích mục tiêu:** SketchUp 2023+  
**Đơn vị phát triển:** Công ty TNHH VADA

## Chức năng chính

- Chọn một hoặc nhiều **Group / Component** rồi giảm số polygon trực tiếp trong SketchUp.
- Điều chỉnh mức giữ lại bằng thanh trượt từ **5% đến 100%**.
- Tùy chọn **Sai số tối đa (mm)** để giới hạn mức dịch chuyển đỉnh.
- Tùy chọn bảo toàn **biên hở và góc gãy**.
- Có thể xử lý **Group / Component lồng nhau**.
- Giữ vật liệu mặt; cố gắng phục hồi UV texture theo từng tam giác.
- Làm mềm cạnh sau khi giảm để bề mặt nhìn mượt hơn.
- Toàn bộ thao tác nằm trong một SketchUp Operation nên có thể **Undo**.
- Có toolbar icon và menu `Extensions > VADA > VADA Giảm Poly`.
- UI tiếng Việt, nền đen `#000000`, hiển thị rõ phiên bản `v1.0.0`.

## Thuật toán v1.0.0

Bản đầu dùng **vertex clustering có bảo toàn feature** viết bằng Ruby để ưu tiên cài đặt đơn giản và tương thích SketchUp 2023. Nó không dùng SDK native như Skimp, vì vậy với model hàng triệu polygon tốc độ và chất lượng decimation sẽ chưa ngang phần mềm thương mại dùng thư viện C/C++ chuyên dụng.

Thuật toán:

1. Triangulate các Face trong từng Group/Component.
2. Nhận diện biên hở và cạnh gãy lớn.
3. Tính kích thước ô gom đỉnh theo tỷ lệ polygon mục tiêu.
4. Gom các đỉnh gần nhau trong cùng shell hình học.
5. Loại tam giác suy biến / trùng.
6. Dựng lại mesh, gán vật liệu và UV khi có thể.
7. Làm mềm các cạnh có góc nhỏ.

## Lưu ý

- Với vật thể CAD/CAM cần độ chính xác cao, nên nhập `Sai số tối đa` thay vì để tự động.
- Model có texture phức tạp/projection đặc biệt cần kiểm tra lại UV sau khi giảm.
- Component được làm unique trước khi chỉnh để hạn chế ảnh hưởng tới instance nằm ngoài vùng chọn.
- Bản v1.0.0 tập trung vào **Simplify model đang có trong SketchUp**; chưa bao gồm importer FBX/OBJ/GLB.

## Cài đặt

1. Tải file `VADA_Giam_Poly_v1.0.0.rbz`.
2. Mở SketchUp.
3. Vào **Extension Manager**.
4. Chọn **Install Extension** và chọn file RBZ.
5. Sau khi cài, mở toolbar **VADA Giảm Poly** hoặc vào `Extensions > VADA > VADA Giảm Poly`.
6. Nếu toolbar/menu chưa hiện đúng sau khi cập nhật bản mới, thoát hoàn toàn SketchUp rồi mở lại.

## Thay đổi v1.0.0

- Phát hành bản đầu tiên.
- Giảm poly theo tỷ lệ.
- Hỗ trợ giới hạn sai số mm.
- Bảo toàn biên/góc gãy cơ bản.
- Xử lý cấu trúc lồng nhau.
- Giữ vật liệu và cố gắng giữ UV.
- UI VADA nền đen, icon toolbar, Undo.
