# 08 - VADA Plugin Manager

**Phiên bản mới nhất:** v1.2.0

Plugin quản lý và kiểm tra cập nhật các plugin VADA từ GitHub.

## v1.2.0

### Cập nhật
- Cải thiện nhận diện plugin đang cài trên máy.
- Ưu tiên lấy phiên bản từ SketchUp Extensions.
- Fallback sang nhận diện loader/file khi không lấy được từ Extensions.
- Đồng bộ Plugin Manager về đúng thư mục số 08.
- Giữ cơ chế quét Git tree để tìm phiên bản `vX.Y.Z` cao nhất.

### Sửa lỗi
- Sửa trường hợp GitHub đã có bản mới nhưng Plugin Manager không nhận diện đúng bản đang cài.
- Sửa trường hợp phiên bản máy bị trống hoặc nhận sai.
- Sửa đường dẫn phát hành của chính VADA Plugin Manager.

## v1.1.0

- Quét Git tree của repository bằng một request.
- Tự tìm thư mục phiên bản `vX.Y.Z` cao nhất của từng plugin.
- Tự tìm file RBZ của phiên bản mới nhất.
- Không phụ thuộc hoàn toàn vào `latest_version` trong manifest.
- Chỉ bật nút cập nhật khi GitHub có bản mới hơn máy.
- Hiển thị thời điểm quét và số plugin có cập nhật.
- Hỗ trợ hot reload với plugin phù hợp; plugin khác sẽ báo cần khởi động lại SketchUp.

## File phát hành

- `v1.2.0/VADA_Plugin_Manager_v1.2.0.rbz`
- Source nằm trong `v1.2.0/source/`.
