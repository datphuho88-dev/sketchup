# VADA - Quản lý Style Dim & Ghi chú

**Phiên bản:** v1.1.1

## Sửa lỗi v1.1.1

- Dimension do plugin khác tạo giờ được bắt cả khi nằm trong Component/Group definition.
- Theo dõi `model.entities`, `active_entities` và toàn bộ `model.definitions`.
- Có `DefinitionsObserver` để bắt definition mới.
- Dimension/Text mới được gom theo batch và chỉ áp Style sau khi operation/transaction nguồn kết thúc.
- Không polling, không quét model liên tục.

## Giới hạn SketchUp 2023

Ruby API 2023 không cho đổi trực tiếp font/cỡ/Bold của Dimension. Màu, mũi tên, vị trí chữ và đơn vị vẫn được tự áp. Bold cần đặt một lần trong **Model Info → Dimensions**.

## File

- `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.1.1.rbz`
- `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.1.1_source.zip`

## Cài đặt

SketchUp → Extension Manager → Install Extension → chọn RBZ. Sau khi cập nhật nên thoát hoàn toàn SketchUp rồi mở lại vì v1.1.1 thay đổi hệ observer.
