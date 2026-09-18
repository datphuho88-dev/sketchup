# VADA - Quản lý Style Dim & Ghi chú

**Phiên bản:** v1.0.1

Plugin lưu và áp nhanh style kích thước/ghi chú cho mọi file SketchUp, đặc biệt khi mở file do người khác gửi.

## Chức năng chính

- Chọn đơn vị mm, cm, m, inch, feet.
- Bật/tắt hậu tố đơn vị và chỉnh độ chính xác 0–6 số lẻ.
- Đổi nhanh màu Dimension và Text/Label.
- Dimension: kiểu mũi tên, chữ theo màn hình/song song đường Dim, vị trí chữ.
- Ghi chú: màu, Leader theo View/Model, kiểu mũi tên, độ dày Leader.
- Lưu nhiều preset Style ngoài file SKP và gọi lại ở file bất kỳ.
- Áp toàn model hoặc chỉ Group/Component/đối tượng đang chọn.
- Có nút mở trực tiếp Model Info → Dimensions/Text cho các thiết lập native.

## Giới hạn SketchUp 2023

SketchUp Ruby API 2023 không cho extension thay đổi font/cỡ chữ mặc định của Dimension hoặc Text. Vì vậy plugin vẫn lưu lựa chọn font trong preset, nhưng không giả lập việc đổi font. Khi chạy trên phiên bản SketchUp có API font cho Text, plugin tự kiểm tra capability trước khi áp.

## File tải

- Cài đặt: `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.0.1.rbz`
- Source đầy đủ: `VADA_Quan_Ly_Style_Dim_Ghi_Chu_v1.0.1_source.zip`

## Cài đặt

SketchUp → Extension Manager → Install Extension → chọn file RBZ. Với lần cài mới, khởi động lại SketchUp nếu toolbar chưa xuất hiện.

## Thay đổi v1.0.1

- Hoàn thiện kiểm tra API font theo capability thực tế.
- UI tiếng Việt, nền #000000, hiển thị rõ version.
- Có toolbar/icon riêng.
- Có preset Style lưu độc lập với file SketchUp.
