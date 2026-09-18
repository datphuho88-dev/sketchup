# VADA Plugin Manager

**Phiên bản mới nhất: v1.3.3**

Plugin quản lý chung cho bộ plugin SketchUp VADA.

## Chức năng
- Quét phiên bản mới trực tiếp từ GitHub.
- Nhận diện phiên bản đang cài từ SketchUp Extensions, fallback quét file Ruby.
- Plugin chưa cài nhưng có trên GitHub được đưa lên đầu danh sách để **Cài mới**.
- Cập nhật từng plugin hoặc cập nhật tất cả.
- Reload plugin an toàn khi có cấu hình reload core.
- Tự kiểm tra GitHub khi mở cửa sổ.

## Mới ở v1.3.3
- Sửa lỗi đọc v1.6.0 thành v1.0.3.
- Ưu tiên khớp đúng SketchUp Extension trước nhận diện gần đúng.
- Đối chiếu phiên bản Extension + loader + core/reload và lấy phiên bản cao nhất hợp lệ.
- Giữ sửa lỗi cửa sổ trắng của v1.3.2.

## Gói cài
`VADA_Plugin_Manager_v1.3.3.rbz`

Cài bằng **SketchUp Extension Manager**. Sau khi nâng chính Plugin Manager, mở lại SketchUp một lần.