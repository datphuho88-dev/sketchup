# Dọn Plugin VADA

Plugin SketchUp dùng để tìm, kiểm tra, tắt và cách ly nhanh các plugin/extension không cần thiết.

**Bản hiện tại:** `v1.3.0`

## v1.3.0

- Giao diện nền đen, tiếng Việt, hiển thị rõ mã phiên bản.
- Quét cả Extension Manager và thư mục `Plugins`.
- Tìm kiếm + lọc theo lỗi nạp, đang tắt, không quản lý, thư viện phụ thuộc và mục cần kiểm tra.
- Có sắp xếp theo tên, ngày sửa gần nhất và mức nghi ngờ.
- Có chọn nhiều plugin, tắt khi khởi động, chuyển vào vùng Cách ly và khôi phục.
- Giảm nguy cơ gỡ nhầm các thư viện như LibFredo, TT_Lib, AMS_Lib.
- Tương thích SketchUp 2023 và đã sửa callback `UI::HtmlDialog` từ bản v1.2.1.

## File phát hành

- `v1.3.0/VADA_Don_Plugin_v1.3.0.rbz`
- `v1.3.0/VADA_Don_Plugin_v1.3.0_source.zip`

## Lịch sử gần nhất

- `v1.0.0` — bản đầu.
- `v1.1.0` — cải thiện khả năng tìm plugin.
- `v1.2.0` — sửa luồng quét/hiển thị.
- `v1.2.1` — sửa lỗi callback `UI::ActionCallbackContext`.
- `v1.3.0` — tối ưu giao diện, lọc, sắp xếp, cách ly và nhận diện thư viện phụ thuộc.
