# VADA - Quản lý Style Dim & Ghi chú

**Phiên bản:** v1.2.0

## Thay đổi v1.2.0

- Giao diện mới dạng thư viện Style, nền đen VADA, tối ưu thao tác nhanh.
- Tạo Style mới, nhân bản, đổi tên, xóa và lưu thay đổi với tên riêng.
- Các bộ Style được lưu ngoài file SKP để dùng lại với file khác.
- Cải thiện bắt Dimension native do plugin khác tạo bằng snapshot persistent_id sau transaction.
- Theo dõi Dimension/Text mới và Dimension mới bị plugin nguồn chỉnh sửa sau khi tạo.
- Thêm công cụ kiểm tra đối tượng đang chọn để biết Dimension là native hay Line/Text/Overlay riêng.
- Giữ áp toàn model / vùng chọn, đơn vị, màu, kiểu mũi tên, vị trí chữ, ghi chú và tự áp.

## Chữ đậm trên SketchUp 2023

SketchUp Ruby API 2023 không cung cấp thuộc tính font/cỡ/Bold cho Dimension, nên plugin không hiển thị một checkbox giả rồi không có tác dụng. Style vẫn có thể nhớ yêu cầu Đậm, nhưng cần đặt Bold native một lần trong **Model Info → Dimensions**. Nếu plugin Dim bên ngoài tự vẽ Line/Text/Overlay thay vì tạo `DimensionLinear` / `DimensionRadial`, Style Dimension native không thể điều khiển trực tiếp và cần tích hợp riêng với plugin đó.

## File cài

- `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.2.0.rbz`
- `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.2.0_source.zip`

## Cài đặt

SketchUp → Extension Manager → Install Extension → chọn RBZ. Sau khi cập nhật từ v1.1.x, thoát hoàn toàn SketchUp và mở lại để nạp sạch observer và UI mới.
