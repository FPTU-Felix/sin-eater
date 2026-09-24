# TÀI LIỆU THIẾT KẾ GAME TOÀN DIỆN (COMPREHENSIVE GAME DESIGN DOCUMENT)
**Tên dự án (Working Title):** *The Penitent: Blood & Sin* (Hiệp Sĩ Khổ Hạnh)  
**Thể loại:** Dark Fantasy Turn-based RPG (Chiến thuật theo lượt tàn khốc, Sinh tồn - Rủi ro cao, Phần thưởng lớn)  
**Phong cách hình ảnh:** 2D Góc Nhìn Ngang (Side-scrolling - Kiểu *Darkest Dungeon*, *Blasphemous*)  
**Nguồn cảm hứng:** *Berserk*, *Blasphemous*, *Fear & Hunger*, *Dark Souls*.

---

## 1. BỐI CẢNH THẾ GIỚI (WORLD LORE)

### 1.1. Thánh Đô Cẩm Thạch: Sancta Aurelia
- Từng là đỉnh cao của tôn giáo và quyền lực trung cổ, được xây dựng bằng cẩm thạch trắng, mái vòm dát vàng và tháp chuông ngân vang. Người dân tôn thờ **Chân Giáo Tinh Khiết (The Pure Faith)**, bài trừ mọi lỗi lầm trần thế.
- **Thực tại suy tàn:** Đá cẩm thạch bị nhuộm đen bởi bồ hóng và máu khô. Chuông bạc nứt toác rên rỉ, tượng thiên thần nhỏ lệ nhựa đen, tro xám rơi lả tả phủ kín các bãi tha ma.

### 1.2. Thảm Họa Khởi Nguồn: "Đại Lễ Tẩy Trần" & Đấng Tội Thần
- **Nghi lễ sai lầm:** Giáo Hoàng **Innocentius V** bí mật cử hành nghi lễ cấm *"Lễ Tẩy Trần Vĩnh Hằng"* dưới đáy Thánh Điện nhằm xóa bỏ tội lỗi nhân loại để nghênh đón Thần Linh.
- **Thực thể giáng thế:** Thứ bước ra từ vết nứt hư không là **"Kẻ Mang Ngàn Tội" (The Primeval Sin / Abyssal Paragon)**.
- **Bản chất Dịch Bệnh (The Scourge of Guilt):**
  - Biến mọi tội lỗi giấu kín trong tâm trí con người thành hiện thực vật lý tàn bạo:
    - Kẻ tham lam: Thịt biến thành vàng nóng chảy nung chín nội tạng.
    - Kẻ bạo lực: Xương thịt mọc ra gai nhọn, tự xé rách da dẻ.
    - Kẻ đạo đức giả: Mặt biến thành mặt nạ đá vỡ khóc ra mủ đen.

### 1.3. Ba Phe Phái Còn Sót Lại Trong Đống Đổ Nát
1. **Giáo Triều Biến Tính (The Blighted Synod):** Những giám mục, linh mục, nữ tu cuồng tín bị biến dạng nhưng tin rằng lở loét và gai nhọn là *"Ân Sủng Thánh Hóa"*. Tiếp tục tổ chức các buổi "Thánh Lễ Máu" để cưỡng ép rửa tội người sống sót.
2. **Hội Hiệp Sĩ Rỉ Sét (The Rustbound Order):** Đội quân cấm vệ từng cố thủ trong các pháo đài. Giáp sắt nung chảy và hàn dính vĩnh viễn vào xương tủy họ, biến họ thành những "cỗ máy thịt và thép" rỗng tuếch tuần tra trong vô thức.
3. **Những Kẻ Đau Khổ (The Afflicted / Penitent Remnants):** Thường dân, thợ thủ công lẩn trốn dưới hầm ngục. Họ **tự hành xác (Self-Mortification)** mỗi ngày (quất roi, tự đâm mù mắt) để nỗi đau thể xác xua tan tội lỗi, ngăn dịch bệnh biến tính mình.

---

## 2. HỆ THỐNG CHIẾN ĐẤU CỐT LÕI: ĐỐI XỨNG TỘI LỖI (THE DUALITY OF SIN)

Cả hai phe (Người chơi và Kẻ địch) đều vận hành xoay quanh hai cực: **MÁU (SINH MỆNH VẬT LÝ)** và **TỘI LỖI (SỨC NẶNG LINH HỒN)**:

```
[ PHE TA: HIỆP SĨ KHỔ HẠNH ]                [ PHE ĐỊCH: QUÁI VẬT DỊ GIÁO ]
        Dung Tích Sinh Mệnh                            Thanh Sinh Mệnh
┌──────────────────────────────┐              ┌──────────────────────────────┐
│  MÁU (BLOOD) │ GUILT (TỘI)   │              │          MÁU (HP)            │
└──────────────────────────────┘              └──────────────────────────────┘
 ◄── Ăn đòn        Sám Hối ──►                 ◄── Đòn đánh chém mất máu ──►
     Tội dâng      Đổi Tội->Máu               
                                              ┌──────────────────────────────┐
                                              │   THANH NGHIỆP TỘI (SIN)     │
                                              └──────────────────────────────┘
                                               ◄── Hiệp sĩ nhồi Nghiệp Tội ──►
                                                   Đầy 100% -> CHOÁNG (STUN)
                                                   -> Kích hoạt [ TRỪNG PHẠT ]
```

### 2.1. Phe Ta: Bình Thông Nhau "Blood & Guilt"
1. **Khởi đầu:** `Máu (Blood)` = 100%, `Tội Lỗi (Guilt)` = 0.
2. **Nỗi Đau Biến Thành Sức Mạnh:** 
   - Bị quái đánh hoặc chủ động dùng kỹ năng tự rạch máu $\rightarrow$ Máu mất đi biến thành **Điểm Guilt**.
   - Guilt càng cao $\rightarrow$ Sát thương xuất chiêu tăng vọt (+20% đến +100%), tỉ lệ bạo kích và lượng Nghiệp Tội nhồi vào quái tăng gấp bội.
3. **Hành Động: SÁM HỐI (Atonement):**
   - Tiêu thụ toàn bộ điểm **Guilt** tích lũy để đổ ngược lại thành **Máu (Blood)**.
   - *Áp lực tâm lý:* Sám hối quá sớm thì yếu sát thương, sám hối quá muộn thì quái vung đòn kết liễu trước khi kịp xá tội!

### 2.2. Phe Địch: Thanh Nghiệp Tội & Đòn Trừng Phạt (Sin & Verdict)
1. **Thanh Nghiệp Tội (Sin Burden / Iniquity - 0 đến 100):**
   - Mọi đòn đánh của phe ta vừa gây sát thương máu, vừa **nhồi điểm Nghiệp Tội** vào linh hồn quái vật.
2. **Trạng Thái Đè Bẹp Bởi Tội Lỗi (Overwhelmed by Sin):**
   - Khi thanh Nghiệp Tội chạm đỉnh **100%**:
     - Quái vật không chịu nổi sức nặng tội nợ $\rightarrow$ **Bị CHOÁNG (Stunned / Khụy gối)** và **MẤT LƯỢT ĐI KẾ TIẾP**.
3. **Đòn Chí Mạng: TRỪNG PHẠT / PHÁN XÉT (Verdict / Retribution):**
   - Khi quái bị Choáng, xuất hiện nút lệnh tối thượng: **[ TRỪNG PHẠT ]**.
   - Giáng một đòn Bạo Kích (Critical) khổng lồ xé xác kẻ thù, đồng thời xả sạch thanh Nghiệp Tội của nó để bắt đầu chu kỳ mới.

---

## 3. CẤU TRÚC KỊCH BẢN: ĐÍCH ĐẾN CHUNG & 4 KẾT CỤC RIÊNG

### 3.1. Đích Đến Tối Cao Chung (The Grand Convergence)
- Mọi nhân vật đều bị thôi thúc tiến về **Thánh Điện Tối Cao (The Grand Sanctum / Abyssal Cradle)** ở trung tâm vương quốc để đối mặt với **Giáo Hoàng Innocentius V** và **Thực Thể Kẻ Mang Ngàn Tội**.

### 3.2. Dàn 4 Nhân Vật Khởi Đầu (Sinners Roster)
1. 🗡️ **The Penitent Knight (Hiệp Sĩ Khổ Hạnh) – [Đại Kiếm]**
   - *Tội lỗi:* Sự Hèn Nhát & Phản Bội (Từng bỏ rơi huynh đệ trong Hội Hiệp Sĩ Rỉ Sét).
   - *Động lực:* Tìm sự xá tội và tự tay giải thoát cho anh em cũ.
   - *Kết cục riêng (The Absolution):* Chém đầu Giáo Hoàng, lần đầu cởi bỏ chiếc mũ sắt vô diện dưới ánh bình minh và ngã xuống thanh thản giữa đống gai nhọn rụng rời.
2. 📿 **The Chained Nun (Nữ Tu Mù Gông Xiềng) – [Roi Gai & Thánh Tích Máu]**
   - *Tội lỗi:* Sự Cuồng Tín Mù Quáng (Từng giao nộp chính gia đình lên giàn thiêu).
   - *Động lực:* Tìm lại đức tin, chất vấn sự giả tạo của Giáo Hoàng.
   - *Kết cục riêng (The False Saint):* Nhận ra Thần linh không tồn tại, tự mình hấp thụ tàn tích thực thể để trở thành "Thánh Mẫu Dị Giáo Mới".
3. 🪓 **The Condemned Headsman (Đao Phủ Bị Đày Ải) – [Đại Rìu / Chùy Gai]**
   - *Tội lỗi:* Sự Tàn Bạo & Khát Máu (Nghiện sát sinh, bị Giáo triều vứt bỏ xuống hầm ngục).
   - *Động lực:* Báo thù Giáo triều.
   - *Kết cục riêng (The Eternal Slaughter):* Chặt nát đầu Giáo Hoàng, đầu hàng hoàn toàn trước bản tính thú dữ, trở thành quái vật đao phủ mới canh giữ tàn tích.
4. 🧪 **The Heretic Apothecary (Thầy Thuốc Dị Giáo) – [Dao Mổ & Độc Dược]**
   - *Tội lỗi:* Lòng Kiêu Ngạo Của Kẻ Tìm Kiếm Tri Thức (Thử nghiệm vô nhân đạo trên người sống).
   - *Động lực:* Giải phẫu thực thể để tìm thuốc kiểm soát dịch bệnh.
   - *Kết cục riêng (The Flesh Transmutation):* Chiết xuất thành công huyết thanh bất tử từ tim thực thể, nhưng biến dị thành sinh vật nửa người nửa quái vật sống cô độc vĩnh viễn.

---

## 4. CẤU TRÚC MÀN CHƠI: BÁN PHI TUYẾN TÍNH (THE HUB & SPOKE)

```
                  [ TẦNG 1: HẦM MỘ GÔNG XIỀNG ]
                   (Tuyến tính - Dạy luật chơi)
                                 │
                                 ▼
                     [ ĐỀN THỜ HOANG PHẾ (HUB) ]
                   (Nơi nghỉ chân, nâng cấp đồ)
                                 │
         ┌───────────────────────┼───────────────────────┐
         ▼                       ▼                       ▼
  [ NHÁNH A: KHU PHỐ ]   [ NHÁNH B: TU VIỆN ]   [ NHÁNH C: ĐẦM LẦY ]
  - Gặp Hiệp Sĩ Rỉ Sét   - Gặp Giáo Triều        - Gặp Quái Dị Giáo
  - Nhặt Chùy & Khiên    - Nhặt Roi Gai          - Nhặt Dao Mổ
  - Cứu Đao Phủ          - Cứu Nữ Tu             - Cứu Thầy Thuốc
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                 [ TẦNG CUỐI: ĐẠI THÁNH ĐIỆN ]
               (Mở khóa khi hạ đủ 3 Boss nhánh)
```

### 4.1. Con Boss Đầu Tiên: Kẻ Cai Ngục Khóc Máu (Sir Gervaise)
- **Ngoại hình:** Khổng lồ 3m, cõng lồng sắt chứa đầy đầu lâu người chết đói, mặt nạ sắt chảy máu ròng ròng từ hốc mắt. Tay cầm chùm chìa khóa gai nhọn và thanh thiết bổng đóng đinh.
- **Vai trò:** Dạy người chơi cảm giác sinh tử của cơ chế: Ăn đòn nặng tích Guilt $\rightarrow$ Phản đòn nhồi Sin $\rightarrow$ Stun Boss để Phán Xét $\rightarrow$ Sám Hối hồi đầy máu.

---

## 5. THIẾT KẾ TRỰC QUAN & VẬN HÀNH (VISUAL & GAMEPLAY PACING)

### 5.1. Phong Cách 2D Góc Nhìn Ngang (Side-scrolling)
- **Hành lang khám phá:** Nhân vật bước đi ngang qua các hành lang Gothic u tối (bước chân nặng nề, kéo lê cự kiếm trên sàn đá). Đến cửa bấm tương tác để sang phòng mới.
- **Tiết kiệm Asset:** Nhân vật di chuyển ngoài bản đồ và nhân vật khi vào trận giao chiến **dùng chung 1 góc nhìn ngang**, tối ưu 50% chi phí vẽ sprite.

### 5.2. Nhịp Độ Chơi: Vượt Ải Sinh Tồn (Không Cày Level Ảo)
- Quái vật hiện rõ trên đường đi (không có random encounter). Người chơi có thể chọn giao chiến hoặc tìm đường né tránh nếu kiệt sức.
- Tiêu diệt quái rơi ra **Máu Tội Lỗi (Sin Remnants)** để dùng tại Bàn Thờ Khổ Hạnh:
  - Mở khóa chiêu thức mới trên Cây Vũ Khí.
  - Mở thêm ô gắn Chuỗi Tràng Hạt (Rosary Slots).
  - Nâng cấp bình máu/thánh tích.

---

## 6. PROMPTS CONCEPT ART (DÀNH CHO HỌA SĨ / AI GENERATION)

### 6.1. Nhân Vật Chính (The Penitent Knight)
> `Dark fantasy concept art, full body, a solemn penitent knight standing in heavy rusted black iron armor, the interior of the armor is lined with cruel iron thorns digging into flesh, dried blood dripping from joints, a completely featureless blind iron helmet with no eye slits, wrapped with rusted barbed wire and thorn rosary beads, wielding a massive colossal chipped executioner greatsword with blood channels, dark grim atmosphere, style of Berserk Kentaro Miura, Blasphemous, Darkest Dungeon, cinematic lighting, gothic, grimdark, highly detailed, 8k --ar 9:16`

### 6.2. Kẻ Cai Ngục Khóc Máu (The Weeping Jailer)
> `Dark fantasy boss concept art, a grotesque hulking 3-meter tall prison warden, rusted armor, wearing a weeping iron mask crying streams of dark red blood, carrying a large rusted iron cage full of starving human skulls on his back, wielding a giant key flail and a spiked rusted iron club, dark medieval dungeon background, horrific atmosphere, style of Berserk and Blasphemous, 8k --ar 9:16`

### 6.3. Bối Cảnh Chiến Trường (Gothic Cathedral Corridor)
> `Side-view battle stage background for a turn-based dark fantasy RPG, a ruined desecrated gothic cathedral corridor, shattered stained glass windows with faint moonlight shining through, blood-soaked stone floor, hanging rusted cages and chains, crumbling stone pillars with thorny vines, grim and oppressive atmosphere, Blasphemous aesthetic, painterly dark fantasy concept art --ar 16:9`
