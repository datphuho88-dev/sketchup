# VADA Bool Dễ Dùng

**Phiên bản mới nhất: v1.0.0**  
Tương thích mục tiêu: **SketchUp 2023+ / Windows**

## Chức năng chính

Plugin Boolean Solid theo quy trình 2 bước, tập trung vào việc tránh nhầm thứ tự vật thể:

- **Gộp khối** — Union.
- **Trừ khối** — A là khối giữ lại, B là khối dùng để cắt.
- **Cắt giữ dao** — Trim A nhưng vẫn giữ B.
- **Lấy phần giao** — Intersection.
- **Chia khối** — Split.
- Hướng dẫn trực tiếp khi chọn: `Bước 1/2` và `Bước 2/2`.
- Đánh dấu **A màu xanh**, **B màu đỏ** ngay trong viewport.
- Rê chuột lên vật thể để biết có phải **Solid** hay không.
- Không cho chạy khi Group/Component không phải Solid kín.
- Giao diện tiếng Việt, nền `#000000`.
- Có Toolbar + menu `Extensions > VADA`.
- Hiển thị version ngay trên cửa sổ plugin.

## Thay đổi v1.0.0

- Phát hành đầu tiên.
- Thêm 5 phép Boolean cơ bản.
- Thêm hướng dẫn chọn A/B trực quan để tránh nhầm thứ tự.
- Giữ lại tên, Tag và vật liệu container của A khi API SketchUp trả về đối tượng kết quả cho phép.

## Cài đặt

File cần cài: **`VADA_Bool_De_Dung_v1.0.0.rbz`**

1. Mở SketchUp.
2. Vào **Extension Manager**.
3. Chọn **Install Extension**.
4. Chọn file `.RBZ`.
5. Nếu toolbar chưa hiện, vào **View > Toolbars > VADA Bool Dễ Dùng**.

## Lưu ý

- Hai đối tượng Boolean phải là **Solid Group** hoặc **Solid Component** kín.
- Phiên bản v1.0.0 dùng Boolean API chính thức của SketchUp Pro; độ ổn định với hình học rất nhỏ/phức tạp phụ thuộc engine hình học của SketchUp.
- Nếu thay đổi plugin ở các bản sau liên quan loader/toolbar, nên thoát hoàn toàn SketchUp rồi mở lại.
