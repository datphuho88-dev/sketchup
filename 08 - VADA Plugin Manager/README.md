# VADA Plugin Manager

**Phiên bản mới nhất: v1.3.2**

Plugin quản lý chung cho bộ plugin SketchUp VADA.

## Chức năng
- Quét phiên bản mới trực tiếp từ GitHub.
- Nhận diện phiên bản đang cài từ SketchUp Extensions, fallback quét file Ruby.
- Plugin chưa cài nhưng có trên GitHub được đưa lên đầu danh sách để **Cài mới**.
- Cập nhật từng plugin hoặc cập nhật tất cả.
- Reload plugin an toàn khi có cấu hình reload core.
- Tự kiểm tra GitHub khi mở cửa sổ.

## Mới ở v1.3.2
- Sửa lỗi đóng cửa sổ rồi mở lại bị trắng.
- Hủy HtmlDialog cũ khi đóng và tạo dialog mới ở lần mở tiếp theo.
- Chỉ gửi dữ liệu sang HTML sau khi giao diện báo đã sẵn sàng.
- Danh mục offline có đầy đủ plugin 01-10, gồm **Tạo phòng nhanh** và **VADA Workspace Manager**.
- Tạo phòng nhanh hiện ngay khi mở Manager; sau đó hệ thống tự quét GitHub để lấy phiên bản mới nhất.

## Gói cài
`VADA_Plugin_Manager_v1.3.2.rbz`

Cài bằng **SketchUp Extension Manager**. Sau khi nâng chính Plugin Manager, mở lại SketchUp một lần.