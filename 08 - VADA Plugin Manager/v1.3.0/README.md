# VADA Plugin Manager v1.3.0

## Thay đổi chính
- Plugin trên GitHub nhưng chưa cài trong SketchUp được đưa lên đầu danh sách.
- Có nút **Cài mới** cho plugin chưa cài nhưng đã có RBZ.
- Tự phát hiện plugin mới từ các thư mục đánh số có phiên bản `vX.Y.Z`, kể cả khi manifest chưa kịp bổ sung.
- Giữ cơ chế ưu tiên đọc phiên bản từ SketchUp Extensions, fallback quét file `.rb`.
- Tách rõ nhóm: Plugin mới chưa cài / Có bản cập nhật / Đã cài mới nhất / Chưa nhận diện.
- Hỗ trợ reload core bằng `reload_candidates`.
- `Tạo mặt cắt và góc nhìn` reload trực tiếp `vada_mat_cat_view/main.rb`, tránh yêu cầu restart khi cập nhật logic.

## Cài đặt
Cài `VADA_Plugin_Manager_v1.3.0.rbz` bằng SketchUp Extension Manager.

Sau khi nâng chính Plugin Manager từ v1.2.0 lên v1.3.0, nên mở lại SketchUp một lần để Manager nạp đầy đủ code mới.