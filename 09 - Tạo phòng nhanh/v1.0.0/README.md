# VADA Tạo Phòng Nhanh v1.0.0

Plugin tạo nhanh một phòng chữ nhật trong SketchUp theo 6 thông số:

- Chiều rộng lòng nhà (cm)
- Chiều dài lòng nhà (cm)
- Chiều cao lòng nhà (cm)
- Độ dày tường (cm)
- Độ dày sàn (cm)
- Độ dày mái (cm)

## Cách dùng

1. Bấm icon **Tạo phòng nhanh** trên toolbar `VADA - Tạo Phòng Nhanh`.
2. Nhập thông số.
3. Bấm **Tạo phòng**.
4. Click một điểm trong model để đặt **góc trong phía dưới** của phòng.

## Quy ước hình học

- Kích thước rộng × dài là kích thước thông thủy/lòng nhà.
- Cao là từ mặt sàn hoàn thiện tới mặt dưới mái.
- Tường phát triển ra ngoài kích thước lòng nhà.
- Sàn nằm dưới cao độ 0 và mái nằm trên cao độ chiều cao lòng nhà.
- Phòng được tạo thành một Group cha, bên trong có các Group `Sàn`, `Tường`, `Mái`.

## Phiên bản

- v1.0.0: Bản đầu tiên.
