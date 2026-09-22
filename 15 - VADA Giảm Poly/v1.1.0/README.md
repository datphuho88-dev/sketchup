# VADA Giảm Poly

**Phiên bản mới nhất:** v1.1.0  
**Tương thích mục tiêu:** SketchUp 2023+  
**Đơn vị phát triển:** Công ty TNHH VADA

## Chức năng chính

- Chọn một hoặc nhiều **Group / Component** rồi giảm số polygon trực tiếp trong SketchUp.
- Điều chỉnh mức giữ lại từ **5% đến 100%**.
- Tùy chọn **Sai số tối đa (mm)**.
- Bảo toàn **biên hở, góc gãy và ranh giới vật liệu**.
- Xử lý **Group / Component lồng nhau**.
- Giữ material; ở chế độ thường vẫn cố gắng giữ UV texture theo từng tam giác.
- Làm mềm cạnh sau khi giảm.
- Toàn bộ thay đổi nằm trong một SketchUp Operation để có thể **Undo**.
- Toolbar icon, menu `Extensions > VADA > VADA Giảm Poly`.
- UI tiếng Việt, nền đen `#000000`, hiển thị version rõ ràng.

## Tối ưu hiệu năng v1.1.0

Bản v1.1.0 tập trung giảm hiện tượng SketchUp bị đứng khi xử lý mesh lớn:

1. Thay khóa tọa độ dạng chuỗi bằng khóa số học để giảm cấp phát bộ nhớ và GC.
2. Dùng chỉ số đỉnh integer xuyên suốt thuật toán thay vì lặp lại tọa độ/chuỗi trong mỗi tam giác.
3. Giảm số vòng tìm kiếm kích thước cluster từ 15 xuống 9; **Turbo** chỉ dùng 6 vòng.
4. Dừng đếm sớm ngay khi số tam giác đã vượt mục tiêu.
5. Chỉ loại tam giác trùng ở bước dựng kết quả cuối, không tạo Hash lớn ở mọi vòng tìm kiếm.
6. Không yêu cầu PolygonMesh normals từ `Face#mesh` vì normal đã lấy trực tiếp từ Face.
7. Chế độ **Turbo cho model lớn** tự kích hoạt từ khoảng 50.000 tam giác: bỏ đọc UV chi tiết nhưng vẫn giữ material.
8. Tái sử dụng danh sách cạnh nguồn khi xóa geometry, tránh quét cạnh lại.
9. Chỉ làm mềm cạnh mới tạo thay vì quét toàn bộ `Entities`.
10. Chỉ `make_unique` Component khi definition thực sự có nhiều instance.
11. Thống kê UI chạy theo từng time-slice nhỏ để cửa sổ vẫn phản hồi trên model lớn.

## Chế độ Turbo

Mặc định bật **Turbo cho model lớn**.

- Dưới khoảng 50.000 tam giác: plugin vẫn giữ UV texture như trước.
- Từ khoảng 50.000 tam giác: ưu tiên tốc độ, không đọc UV chi tiết; material vẫn được giữ.
- Nếu model cần giữ texture chính xác, tắt `Turbo cho model lớn` trước khi chạy.

## Giới hạn

SketchUp Ruby API và thao tác dựng/xóa geometry vẫn chạy trên luồng chính của SketchUp. Vì vậy model hàng trăm nghìn đến hàng triệu tam giác vẫn có thể chậm ở giai đoạn dựng lại hình học. Bản v1.1.0 giảm đáng kể phần xử lý Ruby nhưng không thể đạt hiệu năng native C/C++ giống các engine decimation thương mại.

## Cài đặt

1. Tải `VADA_Giam_Poly_v1.1.0.rbz`.
2. Mở SketchUp → **Extension Manager**.
3. Chọn **Install Extension** và chọn file RBZ.
4. Đóng hoàn toàn SketchUp rồi mở lại để chắc chắn code v1.1.0 được nạp thay cho v1.0.0.
5. Mở toolbar **VADA Giảm Poly** hoặc `Extensions > VADA > VADA Giảm Poly`.

## Thay đổi v1.1.0

- Tối ưu mạnh thuật toán cho mesh lớn.
- Thêm **Turbo cho model lớn**.
- Giảm tải đọc UV khi model lớn.
- Giảm số vòng quét mesh.
- Dừng sớm khi đã vượt mục tiêu polygon.
- Tối ưu bộ nhớ của vertex/triangle key.
- Tối ưu xóa và làm mềm geometry.
- Thống kê UI theo từng lô để giảm treo cửa sổ.
- Giữ nguyên các chức năng của v1.0.0.

## Lịch sử

- `v1.0.0`: bản đầu, vertex clustering, bảo toàn feature, vật liệu, UV cơ bản.
- `v1.1.0`: tối ưu hiệu năng cho model poly lớn và thêm Turbo.
