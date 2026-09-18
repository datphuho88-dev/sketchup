# Dọn Plugin VADA v1.4.1

## File phát hành

- `VADA_Don_Plugin_v1.4.1.rbz` — file cài bằng SketchUp Extension Manager.
- `VADA_Don_Plugin_v1.4.1_source.zip` — source tương ứng v1.4.1.

## Sửa lỗi v1.4.1

- Sửa **Thử hiển thị** cho extension đã đăng ký bằng `SketchupExtension#check`.
- Nếu extension vốn đang tắt khi khởi động, trả trạng thái lưu về tắt bằng `uncheck` sau khi thử.
- Plugin cài thủ công chỉ thử nạp loader phù hợp, không chạy bừa toàn bộ file Ruby.
- Hiển thị lỗi nạp trực tiếp để dễ kiểm tra.
- Giữ nguyên Gỡ hẳn, Cách ly, Khôi phục, tìm kiếm và bộ lọc của v1.4.0.

## Cài đặt

SketchUp → Extension Manager → Install Extension → chọn `VADA_Don_Plugin_v1.4.1.rbz`.

Nên thoát hoàn toàn SketchUp và mở lại sau khi cập nhật.
