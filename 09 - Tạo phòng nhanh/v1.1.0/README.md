# VADA Tạo Phòng Nhanh v1.1.0

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
- Cao là từ mặt sàn hoàn thiện tới mặt dưới trần.
- Tường phát triển ra ngoài kích thước lòng nhà.
- Sàn nằm dưới cao độ 0 và khối trần nằm trên cao độ chiều cao lòng nhà.
- Phòng được tạo thành một Group cha, bên trong có các Group `Sàn`, `Tường`, `Trần`.

## Màu mặc định

- **Sàn:** nâu.
- **Tường:** kem sáng.
- **Trần:** trắng.

## Phiên bản

- v1.1.0: Tự động tô màu sàn, tường và trần ngay sau khi tạo phòng; đổi group `Mái` thành `Trần`.
- v1.0.0: Bản đầu tiên.

## Cài đặt

Cài file `VADA_Tao_Phong_Nhanh_v1.1.0.rbz` bằng **SketchUp Extension Manager**. Nếu SketchUp đang mở và cập nhật từ bản cũ, nên khởi động lại nếu giao diện hoặc toolbar chưa nhận bản mới.
