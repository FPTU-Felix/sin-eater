# 📖 SỔ TAY GIẢI MÃ TOÀN BỘ CODE GAME "SIN EATER"
### (Dành riêng cho bạn - Người mới bắt đầu, không cần biết code vẫn hiểu 100%)

> **Chào bạn!** Đừng lo lắng khi nhìn thấy một đống code dài ngoằng. Bản chất của việc làm game trong Godot không phải là toán học phức tạp, mà chỉ giống như việc **chỉ đạo một vở kịch**:
> - **Sân khấu (.tscn)**: Nơi xếp đặt hình ảnh nhân vật, mặt đất, bục đá.
> - **Kịch bản (.gd)**: Tờ giấy dặn dò diễn viên: *"Khi người chơi bấm Space thì nhảy lên, khi bị kiếm chém trúng thì mất máu"*.
> 
> Cuốn sổ tay này sẽ giải thích từng dòng, từng khối code trong dự án bằng ngôn từ đời thường nhất để bạn hoàn toàn làm chủ tựa game của mình!

---

## 🗺️ 1. BẢN ĐỒ DỰ ÁN: MỖI FILE TRONG THƯ MỤC DÙNG ĐỂ LÀM GÌ?

Trong thư mục game của bạn có 2 loại file chính:
- **File `.tscn` (Scene - Hoạt Cảnh)**: Bạn mở file này trong Godot sẽ thấy **hình ảnh trực quan** (nhân vật, sàn đá, thanh máu, bục nhảy).
- **File `.gd` (GDScript - Kịch Bản Code)**: Chứa các dòng lệnh quy định luật chơi.

| Đường dẫn File | Loại | Nhiệm vụ đời thực |
| :--- | :--- | :--- |
| `scenes/levels/stage_01_catacomb.tscn` | Scene | **Màn chơi Ải 1 (Hầm Mộ Catacomb)**: Chứa sàn đất, bục đá nhảy, các bình hài cốt, kẻ địch và Hiệp Sĩ. |
| `scenes/platformer/player_knight.tscn` | Scene | **Hình thể Hiệp Sĩ**: Gồm ảnh hiệp sĩ, camera đi theo, vùng chém kiếm và vùng nhận đòn. |
| `scripts/platformer/player_knight.gd` | Script | **Não bộ Hiệp Sĩ**: Điều khiển chạy (A/D), nhảy (Space), lướt (Shift), chém kiếm (J), rạch máu (K), sám hối (L), trừng phạt (E). |
| `scenes/platformer/chained_sinner.tscn` | Scene | **Hình thể Kẻ Tử Tù Bị Xích (Quái)**: Gồm ảnh quái vật, sợi xích, thanh máu đỏ và thanh Sin vàng trên đầu. |
| `scripts/platformer/chained_sinner.gd` | Script | **Não bộ Quái Vật (AI)**: Đi tuần qua lại, thấy người chơi thì đuổi theo, quất xích, tích lũy Sin khi bị chém, choáng 2.5s và chờ bị trừng phạt. |
| `scripts/platformer/hitbox.gd` | Script | **Lưỡi Kiếm (Vùng gây sát thương)**: Quy định đòn đánh gây bao nhiêu sát thương và nhồi bao nhiêu Sin. |
| `scripts/platformer/hurtbox.gd` | Script | **Da Thịt (Vùng hứng đòn)**: Nhận biết khi nào bị kiếm của người khác chém trúng. |
| `scenes/platformer/player_hud.tscn` | Scene | **Giao diện người dùng (HUD)**: Thanh Máu đỏ, thanh Tội Lỗi (Guilt) vàng, bảng hướng dẫn nút bấm ở góc màn hình. |
| `scripts/platformer/player_hud.gd` | Script | **Dây nối HUD**: Nhận thông tin từ Hiệp Sĩ để co/giãn thanh máu và thanh tội lỗi trên màn hình. |
| `scripts/platformer/destructible_prop.gd` | Script | **Bình gốm & Bù nhìn tập chém**: Giúp bình hài cốt vỡ nát và nảy tưng tưng khi bị bạn chém. |

---

## 💡 2. TỪ ĐIỂN 8 TỪ KHÓA GODOT "XUẤT HIỆN LIÊN TỤC" TRONG CODE

Khi bạn mở bất kỳ file code nào lên, bạn sẽ thấy những từ tiếng Anh này lặp đi lặp lại. Đây là ý nghĩa của chúng:

### 1. `var` (Variable - Biến số / Cái hộp đựng đồ)
- **Ý nghĩa**: Là một cái hộp có dán nhãn để lưu trữ một con số hoặc chữ.
- **Ví dụ**: `var current_blood: int = 100` $\rightarrow$ Tạo ra cái hộp dán nhãn "Máu hiện tại", bên trong cất số 100. Khi bị quái chém, ta lấy số trong hộp trừ đi 15.

### 2. `@export` (Đẩy ra bảng điều khiển)
- **Ý nghĩa**: Dòng này cực kỳ quan trọng cho người không biết code! Khi bạn thấy `@export var move_speed: float = 260.0`, nó có nghĩa là: *"Godot ơi, hãy mang con số 260 này ra hiển thị ở bảng Inspector bên phải giao diện"*.
- **Tác dụng**: Bạn chỉ cần dùng chuột gõ số khác vào bảng Inspector ngoài màn hình là game tự đổi tốc độ, **không bao giờ cần phải mở code ra sửa**!

### 3. `@onready` (Chuẩn bị sẵn sàng)
- **Ý nghĩa**: Khi game vừa bật lên và nhân vật vừa xuất hiện trên màn hình, dòng này sẽ đi tìm các bộ phận con (như bức ảnh Sprite, cái Camera, thanh Máu) để gán vào bộ điều khiển.

### 4. `func` (Function - Hàm / Một hành động)
- **Ý nghĩa**: Là một mệnh lệnh bảo nhân vật làm một việc gì đó.
- **Ví dụ**: `func _start_dash()` $\rightarrow$ Mệnh lệnh bắt đầu lướt né đòn. `func _execute_attack()` $\rightarrow$ Mệnh lệnh vung kiếm chém.

### 5. `delta` (Thời gian giữa 2 khung hình)
- **Ý nghĩa**: Máy tính có máy mạnh (144 FPS - 144 khung hình/giây) và máy yếu (30 FPS). Nếu nhân vật chạy theo từng khung hình thì máy mạnh sẽ chạy nhanh gấp 4 lần máy yếu!
- **Giải pháp**: Nhân vận tốc với `delta` để đảm bảo: **Dù chơi trên máy tính siêu mạnh hay laptop yếu thì tốc độ chạy của nhân vật vẫn y hệt nhau**.

### 6. `velocity` & `move_and_slide()` (Vận tốc và Di chuyển)
- **`velocity.x`**: Tốc độ chạy ngang (âm là sang trái, dương là sang phải).
- **`velocity.y`**: Tốc độ bay lên / rơi xuống (âm là bay lên trời, dương là rơi xuống đất).
- **`move_and_slide()`**: Lệnh của Godot: *"Hãy đẩy nhân vật đi theo vận tốc trên, nếu gặp sàn đá hay tường thì tự động trượt lại chứ không được đi xuyên tường!"*.

### 7. `create_tween()` (Bộ tạo hoạt ảnh mềm mại)
- **Ý nghĩa**: Thay vì làm nhân vật đổi màu hay co giãn giật cục, `Tween` giúp làm mượt mà trong tích tắc (ví dụ: làm thanh kiếm chớp đỏ rồi từ từ mờ dần trong 0.2 giây).

### 8. `State Machine` (Máy trạng thái)
- **Ý nghĩa**: Tại một thời điểm, nhân vật chỉ được ở 1 trạng thái duy nhất: Hoặc là đang **ĐỨNG YÊN (IDLE)**, hoặc đang **CHẠY (RUN)**, hoặc đang **CHÉM KIẾM (ATTACK)**, hoặc đang **CHOÁNG (STAGGER)**.
- **Tác dụng**: Ngăn chặn lỗi game (ví dụ: không thể vừa bị ăn đòn ngã lăn quay mà chân vẫn chạy bộ được).

---

## ⚔️ 3. GIẢI MÃ CHI TIẾT FILE `player_knight.gd` (HIỆP SĨ KHỔ HẠNH)

File này nằm tại: `res://scripts/platformer/player_knight.gd`. Đây là file quan trọng nhất chi phối trải nghiệm chặt chém của bạn:

### Khối 1: Các thông số tùy chỉnh (Dòng 10 - 28)
```gdscript
@export var move_speed: float = 260.0          # Tốc độ chạy của Hiệp Sĩ
@export var jump_velocity: float = -440.0      # Lực nhảy (số âm vì trục Y trong game hướng lên là âm)
@export var dash_speed: float = 550.0          # Tốc độ lao vút khi bấm Shift
@export var max_vessel: int = 100              # Máu tối đa
@export var base_attack: int = 22              # Sát thương kiếm gốc
```
👉 **Bạn làm gì ở đây?**: Không cần sửa trong code. Hãy bấm vào `PlayerKnight` trong Godot và chỉnh các số này ở bảng Inspector bên phải!

---

### Khối 2: Bắt phím bấm của người chơi (Dòng 100 - 135)
Hàm `_unhandled_input(event)` lắng nghe từng cú gõ phím từ ngón tay bạn:
- **Bấm `Space` hoặc `W`**: Kích hoạt đệm nhảy (`jump_buffer_timer = 0.15`).
- **Bấm `Shift` hoặc `Chuột Phải`**: Gọi hàm `_start_dash()` để lướt né đòn.
- **Bấm `J` hoặc `Chuột Trái`**: Gọi hàm `_execute_attack()` để chém kiếm.
- **Bấm `K`**: Gọi hàm `_sacrifice_blood()` để rạch máu tăng Cuồng Tội.
- **Bấm `L`**: Gọi hàm `_start_atonement()` để quỳ sám hối hồi máu.
- **Bấm `E`**: Gọi hàm `_try_verdict()` để tung đòn Trừng Phạt kết liễu.

---

### Khối 3: Cơ chế Nhảy thông minh (Game Feel) (Dòng 145 - 170)
Tại sao nhảy trong game này lại có cảm giác mượt như *Hollow Knight*? Nhờ 2 cơ chế ẩn:
1. **Coyote Time (0.1 giây)**: Khi bạn chạy qua mép bục đá và đã hụt chân ra ngoài không trung, game vẫn cho phép bạn bấm phím Nhảy trong vòng 0.1s đó để cứu mạng không bị rơi xuống vực!
2. **Jump Buffer (0.15 giây)**: Khi bạn đang rơi từ trên cao xuống và bấm phím Nhảy hơi sớm một chút trước khi chạm đất, game sẽ "ghi nhớ" lệnh đó và ngay khi chân vừa chạm đất, Hiệp Sĩ sẽ tự động bật nhảy lên ngay lập tức!

---

### Khối 4: Combo 3 Nhát Kiếm (Dòng 280 - 325)
Đoạn code này quản lý chuỗi chém 1 $\rightarrow$ 2 $\rightarrow$ 3:
- **Nhát 1**: Chém ngang nhanh nhẹn $\rightarrow$ Gây 18 sát thương, nhồi +15 điểm Sin cho địch.
- **Nhát 2**: Chém chéo hất ngược lên $\rightarrow$ Gây 24 sát thương, nhồi +20 điểm Sin cho địch.
- **Nhát 3 (Finisher)**: Nhảy bổ nện kiếm xuống đất xé toạc đá $\rightarrow$ Gây 42 sát thương, nhồi +35 điểm Sin cho địch, vung bụi đất mù mịt!
- **Hệ thống cửa sổ thời gian**: Sau khi chém nhát 1, bạn có **0.55 giây** để bấm tiếp nhát 2. Nếu quá 0.55 giây mà bạn không bấm, chuỗi combo sẽ tự động quay về lại nhát 1!

---

### Khối 5: Cơ chế Bình Thông Nhau - Máu & Tội Lỗi (Dòng 420 - 460)
```gdscript
func _on_hurtbox_hit_received(incoming_hitbox: Hitbox) -> void:
    var dmg = incoming_hitbox.damage
    current_blood = max(0, current_blood - dmg)  # Máu bị trừ đi
    current_guilt = min(max_vessel - current_blood, current_guilt + dmg) # Máu mất chuyển hóa thành Guilt!
```
- Khi máu tụt xuống, thanh Tội Lỗi (Guilt) dâng lên.
- Hàm `get_guilt_multiplier()` tính toán: Cứ mỗi điểm Guilt tích tụ sẽ nhân thêm sức mạnh cho kiếm của bạn (tối đa đánh đau gấp **2.2 lần** bình thường).

---

### Khối 6: Đòn Trừng Phạt Chí Mạng [E] (Verdict) (Dòng 248 - 295)
Đây là đòn đánh đã mắt nhất game:
1. Khi bạn bấm phím **E**, game quét xem có con quái nào trong bán kính 200 pixel đang đầy 100 Sin không.
2. Nếu có, Hiệp Sĩ lập tức **lướt vút áp sát trước mặt nó**.
3. **`Engine.time_scale = 0.1`**: Game ngưng đọng thời gian (slow-motion) trong 0.12s. Mọi chuyển động chậm lại như phim siêu anh hùng.
4. Camera rung giật dữ dội, một nhát chém chữ X màu đỏ huyết rực lửa quét ngang qua màn hình.
5. Quái vật bị giáng **140 ~ 300 sát thương chí mạng**, thanh Sin của nó bị thanh tẩy trở về 0, và Hiệp Sĩ được thưởng ngay +25 Guilt!

---

## ⛓️ 4. GIẢI MÃ CHI TIẾT FILE `chained_sinner.gd` (QUÁI VẬT XÍCH SẮT)

File này nằm tại: `res://scripts/platformer/chained_sinner.gd`. Đây là trí tuệ nhân tạo (AI) của kẻ địch:

### 1. Đi tuần tra (State.PATROL - Dòng 135 - 150)
- Quái tự động đi bộ qua lại quanh điểm xuất phát với khoảng cách 140 pixel. Khi đi hết tầm, nó tự quay đầu đổi hướng.

### 2. Phát hiện & Đuổi theo (State.CHASE - Dòng 152 - 175)
- Khi Hiệp Sĩ bước vào tầm mắt của nó (bán kính 260 pixel), quái chuyển trạng thái sang **CHASE (Truy Đuổi)**. Nó quay mặt về phía bạn và sải bước đuổi theo.

### 3. Vung xích tấn công (State.ATTACK - Dòng 185 - 235)
- Khi áp sát bạn dưới 65 pixel, nó dừng lại.
- **Báo hiệu đỏ (Wind-up)**: Nó giơ sợi xích lên và chớp đỏ người trong 0.45s. Đây là lúc **bạn cần bấm Shift để lướt né**!
- **Quất xích (Swing)**: Sau 0.45s, nó quất mạnh sợi xích tới trước, bật Hitbox gây 14 sát thương.

### 4. Tích Sin, Bị Choáng 2.5s và Khóa 100 Sin (Dòng 280 - 325)
Đúng theo yêu cầu thiết kế của bạn:
```gdscript
# Khi bị chém trúng:
current_sin = min(max_sin, current_sin + sin_gain)

# Khi chạm mốc 100 Sin:
if current_sin >= max_sin and not is_verdict_ready:
    _trigger_stagger() # Choáng váng trong 2.5s!
```
- Khi Sin đầy 100, quái vào trạng thái `STAGGER`: Nó đứng im lắc lư chóng mặt trong 2.5 giây, trên đầu hiện dòng chữ nhấp nháy vàng: `⚡ [E] TRỪNG PHẠT!`.
- **ĐIỂM ĐẶC BIỆT**: Hết 2.5 giây choáng, hàm `_process_stagger` cho phép nó tỉnh lại và tiếp tục truy đuổi tấn công bạn, **nhưng biến `is_verdict_ready` vẫn giữ nguyên là TRUE và thanh Sin vẫn giữ nguyên 100/100**! Dòng chữ `[E] TRỪNG PHẠT!` vẫn chờ sẵn trên đầu cho đến khi bạn quyết định tung chiêu E!

---

## 🛠️ 5. BẠN CẦN LÀM GÌ KHI MUỐN THAY ĐỔI THEO Ý THÍCH?

Dưới đây là cẩm nang nhanh khi bạn muốn tinh chỉnh game:

| Muốn thay đổi điều gì? | Cách làm trực tiếp trên giao diện Godot (Không cần code) |
| :--- | :--- |
| **Muốn Hiệp Sĩ chạy nhanh như chớp** | Bấm vào node `PlayerKnight` $\rightarrow$ Nhìn bảng Inspector $\rightarrow$ Đổi `Move Speed` từ 260 lên 350. |
| **Muốn Hiệp Sĩ nhảy cao gấp đôi** | Bấm vào node `PlayerKnight` $\rightarrow$ Đổi `Jump Velocity` từ -440 thành -600. |
| **Muốn quái vật trâu máu hơn** | Bấm vào node `ChainedSinner1` $\rightarrow$ Đổi `Max Health` từ 80 lên 200. |
| **Muốn quái bị choáng lâu hơn khi đầy Sin** | Bấm vào node `ChainedSinner1` $\rightarrow$ Đổi `Stagger Duration` từ 2.5 lên 4.0 (choáng 4 giây). |
| **Muốn chiêu E Trừng Phạt sát thương cực khủng** | Bấm vào node `ChainedSinner1` $\rightarrow$ Đổi `Verdict Damage Taken` từ 140 lên 500 (chém phát chết luôn). |
| **Muốn đặt thêm 1 con quái mới vào bản đồ** | Kéo file `chained_sinner.tscn` từ ô FileSystem thả thẳng vào màn hình bản đồ ở vị trí bạn thích! |

---

> 🎯 **Lời khuyên**: Hãy mở file tài liệu này bất cứ khi nào bạn thấy băn khoăn về một tính năng nào đó. Dự án này được xây dựng hoàn toàn mạch lạc để bạn vừa học, vừa chơi, vừa làm chủ tựa game của chính mình!
