# Panduan: mengisi spritesheet battle (contoh: Helder)

Ini ringkasan apa yang sudah dipasang untuk **Helder** dan cara mengulanginya untuk karakter lain.

## 1. Isi zip LPC-mu dan dipakai untuk apa

| File di zip | Jadi animasi | Bagian yang dipakai |
|---|---|---|
| `standard/combat.png` | `idle` (berulang) | baris 3 (kanan), frame 0-1 |
| `standard/jump.png` | `jump` | baris 3, frame 0-4 |
| `custom/slash_reverse_oversize.png` | `attack` dan `guard` | baris 3, frame 0-5 (kotak 192x192) |
| `standard/spellcast.png` | `alter` | baris 3, frame 0-6 |
| `standard/hurt.png` | `hurt` dan `defeat` | baris 0 (cuma satu baris), frame 1-2 / 0-5 |
| walk, run, thrust, dll | belum dipakai | |

## 2. Cara membaca sheet LPC
* Satu frame = 64x64 piksel. Urutan baris: 0 atas, 1 kiri, 2 bawah, **3 kanan**. Battle memakai baris kanan karena party berdiri di kiri dan menghadap ke kanan.
* Tiap sheet lebarnya 13 kolom; kolom kosong di kanan itu normal (animasinya cuma memakai sebagian).
* `hurt.png` hanya punya satu baris, menghadap ke depan.
* **Tongkat (club) hanya ada di sheet oversize.** Generator LPC hanya menggambar club pada animasi itu, jadi di `idle`, `jump`, dan `spellcast` tangan Helder kosong. Kalau mau club kelihatan terus, di generator pilih senjata yang mendukung animasi combat/jump lalu export ulang.

## 3. Cara membuat SpriteFrames sendiri di editor (untuk Radik, Dean, WYG-01)
1. Salin PNG ke `assets/characters/<nama>/`.
2. FileSystem -> klik kanan -> **New Resource** -> **SpriteFrames** -> simpan sebagai `<nama>_frames.tres`.
3. Klik dua kali file itu: panel **SpriteFrames** muncul di bawah. Ganti nama animasi `default` jadi `idle`, lalu **Add Animation** untuk `attack`, `alter`, `hurt`, `defeat`, `jump`, `guard`.
4. Pada tiap animasi: tombol **Add frames from Sprite Sheet** -> pilih PNG -> isi *Horizontal 13, Vertical 4* (sheet oversize: *Horizontal 6, Vertical 4*) -> klik frame di **baris kanan** berurutan -> **Add Frame(s)**.
5. Atur **FPS** dan **Loop**: hanya `idle` yang Loop. Angka yang kupakai: idle 3, attack 14, alter 10, hurt 10, defeat 8, jump 16, guard 6.
6. Buka `data/characters/<nama>.tres` -> *Battle art* -> **Sprite Frames** -> seret file frames tadi.

`helder_frames.tres` bisa dibuka dengan cara yang sama untuk melihat/ubah frame dan kecepatannya.

## 4. Cara kerjanya saat battle
1. Pemain memilih Drabo + target. `BattleManager` memberi tahu dua hal: `action_announced` (siapa pakai apa) dan `action_targeted` (siapa targetnya).
2. `BattleStage._on_action_targeted` memanggil `UnitVisual.play_lunge(posisi di depan musuh)`: **lompat (jump) -> kibas club (attack) -> lompat balik**.
3. Stage meminta `BattleManager` menunggu (`visual_lead_in`) sampai club kena, jadi HP, angka damage, dan animasi hurt musuh muncul **tepat saat pukulan mendarat**.
4. Setelah itu `visual_follow_through` menahan giliran sampai Helder kembali ke tempat, baru giliran berikutnya mulai.
5. **Alteration**: memutar `alter` (spellcast) di tempat, damage/efeknya muncul saat tangan terjulur (frame 4).
6. Giliran musuh tidak berubah. Karakter tanpa `Sprite Frames` juga tidak berubah (tetap stick figure atau gambar tunggal).

## 5. Tombol untuk menyetel (Inspector pada node root `scenes/battle/unit_visual.tscn`)
| Pengaturan | Fungsi |
|---|---|
| Anim Size | ukuran karakter relatif ke stick figure (1.6 = hampir sama tinggi) |
| Anim Feet Y | posisi telapak kaki di dalam frame 64 px (LPC: 58) |
| Lunge Distance | jarak mendarat dari musuh; naikkan kalau club tidak sampai |
| Lunge Jump Seconds / Height | lama dan tinggi lompatan |
| Lunge Hold Seconds | jeda setelah kibasan sebelum lompat balik |
| Attack Impact Frame | frame `attack` saat club kena (damage muncul di sini), mulai dari 0 |
| Alter Impact Frame | frame `alter` saat sihir keluar, mulai dari 0 |

## 6. Catatan penting
* **Kodenya belum sempat kujalankan di Godot** (tidak ada di sandbox-ku). Buka proyek di editor sekali supaya PNG ter-import, lalu jalankan:
  `godot --headless --path . --script res://tests/anim_test.gd` dan `.../art_test.gd` (keduanya harus berakhir *ALL PASSED*). Kalau ada yang FAIL, kirim lognya.
* LPC mewajibkan **kredit**: simpan `assets/characters/helder/credits/credits.txt` dan tampilkan di layar credits game.
* Item (pakai barang) belum punya animasi; `show_pose` otomatis tetap di `idle`. Tambah animasi `item` nanti kalau sudah ada frame yang cocok.

## 7. File yang berubah
* Baru: `assets/characters/helder/` (5 PNG, `helder_frames.tres`, `credits/`), `tests/anim_test.gd`, `PANDUAN_SPRITESHEET.md`.
* Diubah: `scripts/ui/unit_visual.gd` (ditulis ulang), `scripts/ui/battle_stage.gd`, `scripts/battle/battle_manager.gd`, `scripts/data/character_template.gd`, `scenes/battle/unit_visual.tscn`, `data/characters/helder.tres`, `tests/art_test.gd` (1 baris), `ASSET_RULES.md`.
