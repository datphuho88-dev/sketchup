# VADA Plugin Manager

**Phiên bản mới nhất: v1.4.0**

Plugin trung tâm của VADA để quản lý cài mới, cập nhật, reload và đồng bộ plugin SketchUp giữa nhiều máy.

## Mới ở v1.4.0

- Thêm tab **KHO PLUGIN NGOÀI** để quét các extension đang cài nhưng không thuộc bộ plugin VADA.
- Có thể lưu **metadata** của plugin ngoài lên GitHub: tên, phiên bản, tác giả, link nguồn.
- Với plugin mà người dùng có quyền sao lưu/phân phối, có thể **đóng gói lại RBZ từ loader `.rb` + thư mục hỗ trợ cùng tên** rồi tải lên GitHub.
- Mỗi plugin ngoài được lưu theo version riêng trong `90 - Kho plugin ngoài`, không ghi đè version cũ.
- Tạo `external_plugins_manifest.json` để máy khác đọc kho plugin đã lưu.
- Trên PC khác, mở VADA Plugin Manager → **KHO PLUGIN NGOÀI** → **CÀI NHANH** để tải RBZ và cài bằng SketchUp.
- Kiểm tra SHA-256 trước khi cài plugin ngoài đã lưu.
- GitHub token chỉ giữ **trong RAM của phiên SketchUp**, không ghi xuống file cấu hình.
- Plugin có file mã hóa `.rbe/.rbs` không được đưa RBZ lên repo công khai; chỉ cho lưu metadata/link nguồn.
- Giới hạn gói backup công khai 25 MB để tránh thao tác nặng trong SketchUp.
- Giữ nguyên các chức năng cũ: kiểm tra update trực tiếp GitHub, cài mới, cập nhật từng plugin/tất cả, reload plugin an toàn, nhận diện version cài trong máy.

## Cách dùng kho plugin ngoài

1. Mở **VADA Plugin Manager**.
2. Chọn tab **KHO PLUGIN NGOÀI**.
3. Plugin tự quét extension ngoài đang cài trong SketchUp.
4. Để ghi dữ liệu lên GitHub, nhập **fine-grained GitHub token** có quyền `Contents: Read and write` cho repo `datphuho88-dev/sketchup`.
5. Với plugin không được phép phân phối công khai, dùng **LƯU THÔNG TIN** và điền link nguồn gốc.
6. Với plugin bạn có quyền sao lưu/phân phối, dùng **ĐÓNG GÓI + LƯU GITHUB**.
7. Trên máy khác, cài VADA Plugin Manager rồi vào tab này và bấm **CÀI NHANH**.

> Không dán GitHub token vào chat. Token chỉ cần nhập trực tiếp trong giao diện plugin và bị xóa khỏi bộ nhớ khi đóng cửa sổ.

## File cài đặt

`VADA_Plugin_Manager_v1.4.0.rbz`

Cài bằng **SketchUp Extension Manager**. Sau khi nâng từ bản cũ, nên thoát hoàn toàn SketchUp rồi mở lại.
