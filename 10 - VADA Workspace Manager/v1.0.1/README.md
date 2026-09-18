# VADA Workspace Manager v1.0.1

Bản sửa lỗi điều khiển toolbar trực tiếp trong SketchUp.

## Sửa chính ở v1.0.1
- Giữ **strong-reference** tới đúng object `UI::Toolbar` đã phát hiện, thay vì mỗi lần thao tác lại phụ thuộc hoàn toàn vào một lượt `ObjectSpace` mới.
- `ẨN NGAY / HIỆN` điều khiển toolbar ngay lập tức.
- `DỌN NHANH PLUGIN` dùng trực tiếp các ô **GIỮ** đang tick trên giao diện và chỉ hide những toolbar còn lại.
- `DỌN THEO PROFILE` vừa hide toolbar ngoài profile vừa show lại toolbar cần giữ, đưa trạng thái về đúng profile đã lưu.
- `Hoàn tác` lưu trực tiếp reference tới object toolbar trong session, nên có thể show lại đúng các toolbar vừa bị ẩn.
- `Tự dọn khi mở SketchUp` chạy nhiều lượt ngắn sau khi extension load để xử lý plugin tự show toolbar bằng timer.
- Thêm số lượng object `UI::Toolbar` thực tế đang được manager giữ trong giao diện để dễ kiểm tra.
- Chỉ ẩn/hiện toolbar; không uninstall hoặc disable extension.

## Cách dùng nhanh
1. Cài `VADA_Workspace_Manager_v1.0.1.rbz` bằng Extension Manager.
2. Sắp toolbar theo ý rồi bấm **LƯU MÀN HÌNH HIỆN TẠI**.
3. Tick **GIỮ** cho toolbar muốn giữ khi dọn nhanh.
4. Bấm **DỌN NHANH PLUGIN** để ẩn toàn bộ toolbar plugin khác.
5. Bấm **Hoàn tác** để quay lại trạng thái trước lần dọn gần nhất.

## Lưu ý API
SketchUp Ruby API không có một collection chính thức liệt kê toàn bộ Ruby toolbar. Plugin quét các object `UI::Toolbar` đang sống bằng `ObjectSpace`, sau đó giữ reference của chúng trong registry của VADA để các lần hide/show/undo dùng đúng object đã phát hiện.
