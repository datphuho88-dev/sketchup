# VADA Bool Dễ Dùng

**Phiên bản mới nhất: v1.0.2**  
Mục tiêu tương thích: **SketchUp 2023+ / Windows**

## Chức năng chính

- **Gộp khối** — Union.
- **Trừ khối** — A là khối giữ lại, B là khối dùng để cắt.
- **Cắt giữ dao** — cắt A nhưng vẫn giữ B.
- **Lấy phần giao** — Intersection.
- **Chia khối** — Split.
- Hướng dẫn trực tiếp theo từng bước chọn A/B.
- Đánh dấu A/B trực quan trong viewport.
- Kiểm tra Group/Component có phải Solid trước khi chạy.
- Giao diện tiếng Việt, nền `#000000`, có icon toolbar và hiển thị version.

## Thay đổi v1.0.2

- Tối giản loader để tăng khả năng tương thích với SketchUp 2023.
- RBZ chỉ có `vada_bool_de_dung.rb` và thư mục `vada_bool_de_dung/` ở root.
- Giữ nguyên các phép Boolean và hướng dẫn chọn A/B của các bản trước.
- Plugin chưa ký số; nếu SketchUp dùng `Identified Extensions Only` thì cần đổi Extension Loading Policy để cho phép extension chưa ký.

## File cài đặt

`VADA_Bool_De_Dung_v1.0.2.rbz`

## Cài đặt

1. Mở **SketchUp > Extension Manager**.
2. Chọn **Install Extension**.
3. Chọn file `VADA_Bool_De_Dung_v1.0.2.rbz`.
4. Nếu SketchUp chặn extension chưa ký, vào **Extension Manager > Settings > Extension Loading Policy** và chọn chế độ cho phép extension chưa xác định.
5. Thoát hoàn toàn SketchUp rồi mở lại nếu toolbar chưa xuất hiện.

## Lưu ý

Hai đối tượng Boolean phải là Group/Component Solid kín. Các thay đổi loader/toolbar không nên hot reload; nên khởi động lại SketchUp sau khi cập nhật.
