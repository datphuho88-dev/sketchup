# Changelog

## v1.4.0
- Thêm Kho plugin ngoài.
- Quét extension ngoài đã cài từ SketchUp Extensions.
- Đóng gói plugin chuẩn từ outer `.rb` + support folder cùng tên.
- Upload RBZ lên GitHub khi người dùng xác nhận có quyền sao lưu/phân phối.
- Token GitHub chỉ giữ trong RAM, không lưu xuống máy.
- Thêm `external_plugins_manifest.json` để đồng bộ giữa nhiều PC.
- Cài nhanh plugin đã backup bằng cơ chế cài archive của SketchUp.
- Kiểm tra SHA-256 trước khi cài.
- Chặn upload RBZ có `.rbe/.rbs` lên repo công khai; hỗ trợ lưu metadata/link nguồn thay thế.
- Giữ nguyên toàn bộ chức năng cài/cập nhật/reload của v1.3.3.

## v1.3.3
- Sửa nhận diện version cài trong máy.
- Sửa cửa sổ trắng sau khi đóng/mở lại.
- Cải thiện kiểm tra GitHub, cài mới và hot reload.
