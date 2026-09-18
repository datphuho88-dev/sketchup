# VADA Workspace Manager v1.0.3

Plugin quản lý và dọn toolbar SketchUp, tối ưu cho SketchUp 2023.

## Mới ở v1.0.3

- Sửa trường hợp vừa **DỌN NHANH PLUGIN** xong nhưng một số toolbar/icon lại tự xuất hiện.
- Khi người dùng thao tác thủ công, plugin hủy ngay các lượt **startup cleanup** còn chờ để chúng không áp profile cũ và mở lại toolbar.
- Sau khi dọn, plugin kiểm tra lại theo các lượt ngắn `0.15 / 0.5 / 1.2 / 2.5 / 4 giây` để bắt toolbar do extension khác tự bật trễ.
- Không polling nền liên tục.
- Thêm **CHỌN TẤT CẢ KẾT QUẢ** và **BỎ CHỌN TẤT CẢ** ngay cạnh phần tìm kiếm/lọc.
- Thêm **ẨN ĐÃ CHỌN** và **HIỆN ĐÃ CHỌN** để thao tác hàng loạt.
- Chọn tất cả chỉ áp dụng cho danh sách đang lọc/tìm kiếm.
- Tách rõ hai khái niệm: ô đầu dòng = **CHỌN** để thao tác hàng loạt; ô **GIỮ** = không bị ẩn khi dùng Dọn nhanh.
- Toolbar đang hiện vẫn luôn được đưa lên đầu danh sách.

## Chức năng chính

- Tìm kiếm và lọc toolbar/plugin.
- Ẩn/hiện từng toolbar ngay lập tức.
- Ẩn/hiện hàng loạt theo lựa chọn.
- Dọn nhanh plugin, trừ các toolbar đánh dấu **GIỮ**.
- Lưu và áp dụng nhiều profile workspace.
- Hoàn tác lần thao tác gần nhất.
- Tự dọn khi mở SketchUp.
- Chỉ điều khiển toolbar, không uninstall/disable extension.

## Cài đặt

Cài file `VADA_Workspace_Manager_v1.0.3.rbz` bằng **SketchUp Extension Manager**.

Sau khi cập nhật từ bản cũ, nên thoát hoàn toàn SketchUp rồi mở lại.
