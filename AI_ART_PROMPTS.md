# BỘ PROMPT AI TẠO HÌNH ẢNH TOÀN DIỆN (AI ART PROMPTS GUIDE)
**Dự án:** *The Penitent: Blood & Sin*  
**Phong cách chủ đạo:** Dark Fantasy Grimdark, Gothic Medieval, âm hưởng *Berserk* (Kentaro Miura), *Blasphemous*, *Darkest Dungeon*, ánh sáng tương phản mạnh (Chiaroscuro), sắt gỉ, máu khô, chi tiết sắc nét.

> 💡 **Mẹo sử dụng:** 
> - Bạn có thể copy trực tiếp các đoạn prompt tiếng Anh bên dưới vào **Midjourney**, **Flux.1**, **Leonardo.ai**, **DALL-E 3** hoặc **Stable Diffusion**.
> - Đối với nhân vật/quái vật, prompt đã được thêm từ khóa `isolated on dark plain background` để bạn dễ dàng dùng công cụ tách nền (Remove BG) lấy sprite đưa vào Godot.

---

## 1. STYLE GUIDE CHUNG (THÊM VÀO KHI CẦN)
* **Phong cách:** `Dark fantasy concept art, grimdark medieval gothic, inspired by Berserk and Blasphemous, gritty texture, chipped rusted steel, dried dark blood, dramatic chiaroscuro lighting, highly detailed, high contrast shadows, painterly digital art, 8k resolution`
* **Negative Prompt (Nếu dùng Stable Diffusion/Leonardo):** `anime, colorful, cute, smooth 3d, plastic, futuristic, modern, blurry, low quality, oversaturated, cheerful`

---

## 2. GÓI HÌNH ẢNH TẦNG 1: HẦM MỘ GÔNG XIỀNG (THE CATACOMBS)

### 2.1. Nhân Vật Chính: Hiệp Sĩ Khổ Hạnh (The Penitent Knight)
* **Mục đích:** Dùng làm Sprite nhân vật chính đứng trên sàn đấu 2D (Side-view Combat Idle).
* **Tỉ lệ khung hình:** `--ar 3:4` hoặc `--ar 9:16`
```text
Dark fantasy 2d character concept art, full body side view combat stance, a grim penitent knight in heavy chipped rusted black iron armor, inside of armor lined with cruel iron spikes digging into flesh, dried blood seeping from armor joints, featureless completely blind solid iron helmet with no eye openings, forearms wrapped in rusted barbed wire and thorny rosary chains, wielding a colossal heavy executioner greatsword with deep blood channels held in two hands, dark atmospheric lighting, isolated on solid dark grey background, style of Berserk and Blasphemous, painterly masterpiece, 8k --ar 3:4
```

### 2.2. Avatar / Chân Dung Hiệp Sĩ Khổ Hạnh (Player Portrait)
* **Mục đích:** Đặt cạnh thanh máu và thanh Guilt trên thanh HUD.
* **Tỉ lệ khung hình:** `--ar 1:1`
```text
Dark fantasy portrait close-up avatar of a solemn penitent knight, wearing a rusted iron blind helmet with no eye slits, surface engraved with blood drop sigil and thorns, rusted barbed wire wrapped around the neck and collar of heavy chipped steel armor, dramatic rim lighting, shadowy gothic faceplate, grimdark aesthetic, style of Darkest Dungeon and Blasphemous, 8k --ar 1:1
```

---

### 2.3. Boss Tầng 1: Kẻ Cai Ngục Khóc Máu (Sir Gervaise - The Weeping Jailer)
* **Mục đích:** Dùng làm Sprite Boss đứng đối diện người chơi trên sàn đấu.
* **Tỉ lệ khung hình:** `--ar 3:4` hoặc `--ar 9:16`
```text
Dark fantasy 2d boss concept art, full body side view, a terrifying 3-meter tall hulking monstrous prison warden, wearing tattered executioner robes and rusted spiked plate armor, wearing an iron death-mask crying continuous streams of dark crimson blood from the hollow eye sockets, carrying a massive rusted iron cage full of starving human skulls strapped to his hunched back, wielding a giant iron key flail in one hand and a brutal spiked executioner club in the other, bloodstained chains, isolated on solid dark grey background, Blasphemous and Berserk style, 8k --ar 3:4
```

### 2.4. Avatar / Chân Dung Boss Kẻ Cai Ngục (Boss Portrait)
* **Mục đích:** Đặt cạnh thanh máu và thanh Sin của Boss.
* **Tỉ lệ khung hình:** `--ar 1:1`
```text
Dark fantasy monster portrait icon, close up of a weeping iron mask crying thick black and crimson blood from hollow eye sockets, rusted barbed iron crown, gruesome executioner collar, terrifying grimdark atmosphere, dramatic cinematic shadows, 8k --ar 1:1
```

---

### 2.5. Quái Thường 1: Kẻ Tử Tù Đội Mồ (The Chained Sinner)
* **Mục đích:** Quái vật thường gặp trong hầm mộ.
* **Tỉ lệ khung hình:** `--ar 3:4`
```text
Dark fantasy monster concept art, full body side view, an emaciated grotesque undead prisoner rising from stone, rotting gray flesh over bone, wrapped in torn bloody burial shrouds, both wrists bound by heavy rusted chains ending in broken iron spikes, frantic rabid expression, hollow sunken eyes, feral lunging stance, isolated on dark plain background, grimdark medieval horror, 8k --ar 3:4
```

### 2.6. Quái Thường 2: Chó Săn Hủi (The Blighted Hound)
* **Mục đích:** Quái thú nhanh nhẹn của hầm mộ.
* **Tỉ lệ khung hình:** `--ar 4:3`
```text
Dark fantasy creature concept art, a grotesque mutated hunting hound, rotting skin, bony spikes protruding along its jagged spine, jaw split into bloody fangs, rusted collar with broken chain, rabid stance, dark gothic dungeon horror, style of Bloodborne and Blasphemous, isolated on dark grey background, 8k --ar 4:3
```

---

## 3. GÓI HẬU CẢNH CHIẾN TRƯỜNG & KHÁM PHÁ (BACKGROUNDS)

### 3.1. Sàn Đấu Hầm Mộ (Catacomb Battle Arena)
* **Mục đích:** Ảnh nền chính cho màn hình giao chiến Turn-based tại Tầng 1.
* **Tỉ lệ khung hình:** `--ar 16:9`
```text
Side-view battle stage background for a 2d dark fantasy turn-based game, a grim subterranean catacomb dungeon, floor made of cracked dark stone slabs stained with old dried blood, ancient gothic stone pillars carved with weeping saints, walls lined with thousands of human skulls and skeletal remains, rusted iron cages and barbed chains hanging from the ceiling, faint cold moonlight filtering through a high iron grating, moody dim torchlight casting long flickering shadows, cinematic atmospheric depth, Blasphemous and Darkest Dungeon aesthetic, 8k --ar 16:9
```

### 3.2. Hành Lang Khám Phá (Exploration Corridor)
* **Mục đích:** Ảnh nền cho đoạn đi bộ ngang tìm đường và mở cửa ngục.
* **Tỉ lệ khung hình:** `--ar 16:9`
```text
2d side-scrolling exploration background, an endless dark gothic underground prison corridor, massive rusted iron cell doors with small barred viewports, torture racks and iron maidens along the walls, dripping moisture on ancient stone floor, ominous fog rolling along the ground, mysterious flickering candle braziers, oppressive grimdark atmosphere, painterly concept art, 8k --ar 16:9
```

---

## 4. GÓI ICON KỸ NĂNG & THÁNH TÍCH (UI SKILL ICONS - TỈ LỆ 1:1)

### 4.1. Kỹ Năng: Chém Thường (Basic Slash)
```text
Game skill icon, a chipped heavy iron greatsword slashing through the air, leaving a sharp white arc of steel against a dark gothic stone background, blood splatters, grimdark medieval UI icon, high contrast, clean square frame --ar 1:1
```

### 4.2. Kỹ Năng: Huyết Trảm (Blood Cleave)
```text
Game skill icon, a massive greatsword blade dripping with boiling crimson blood and dark unholy red aura, blood spikes bursting outward, dark fantasy skill button, painterly, dark frame, 8k --ar 1:1
```

### 4.3. Kỹ Năng: Khổ Hình Đập / Nhồi Sin (Sin Smite)
```text
Game skill icon, a heavy spiked iron mace crashing downward onto cracked stone, shattering golden divine cracks mixed with purple sin lightning, crushing impact, grimdark RPG ability icon, square frame --ar 1:1
```

### 4.4. Kỹ Năng: Sám Hối (Atonement)
```text
Game skill icon, two gauntleted iron hands cupping a glowing radiant red drop of sacred martyr blood, thorn vines wrapping around the light, holy redemption motif, dark fantasy UI icon, 8k --ar 1:1
```

### 4.5. Đòn Chí Mạng: Trừng Phạt / Phán Xét (Verdict)
```text
Game skill icon, a colossal rusted executioner sword thrust straight down into an iron skull, blinding dramatic red and gold divine judgment rays piercing through darkness, ultimate execution strike, high contrast, epic dark fantasy icon --ar 1:1
```

### 4.6. Thánh Tích: Hạt Tràng Hạt "Nước Mắt Cai Ngục" (Tear of the Weeping Jailer)
```text
Game item icon, a carved dark obsidian rosary bead shaped like a weeping iron skull shedding a ruby tear, wrapped in fine rusted wire, resting on black velvet, gothic relic item icon, 8k --ar 1:1
```
