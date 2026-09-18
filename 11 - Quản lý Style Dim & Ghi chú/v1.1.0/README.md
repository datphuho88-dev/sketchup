# VADA - Quản lý Style Dim & Ghi chú

**Phiên bản:** v1.1.0

## Thay đổi v1.1.0
- Sửa lỗi Style chỉ áp cho Dim đã có; Dim tạo mới quay về style cũ.
- Thêm cơ chế tự áp preset cho Dimension/Ghi chú mới bằng `EntitiesObserver`, không polling nền.
- Theo dõi model root và `active_entities` để Dim tạo trong Group/Component đang chỉnh sửa cũng được áp.
- Thêm lựa chọn bật/tắt riêng cho Dim mới và Ghi chú mới.
- Làm nổi bật tùy chọn **CHỮ DIM ĐẬM (Bold)**.
- Giữ nguyên toàn bộ chức năng v1.0.1.

## Lưu ý SketchUp 2023
Ruby API không cho extension đổi font/cỡ chữ/Bold của Dimension. Preset vẫn lưu lựa chọn Bold, nhưng để Dim native thật sự đậm cần đặt một lần trong **Model Info → Dimensions** của file. Các thuộc tính màu, mũi tên, vị trí chữ và đơn vị vẫn được plugin tự áp cho Dim mới.

## File
- `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.1.0.rbz`
- `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.1.0_source.zip`

## Cài đặt
SketchUp → Extension Manager → Install Extension → chọn RBZ. Sau khi cập nhật v1.1.0 nên thoát hoàn toàn SketchUp rồi mở lại để observer/loader được nạp sạch.
