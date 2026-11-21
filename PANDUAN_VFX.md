# Panduan VFX: memasang efek untuk attack, guard, item, dan skill alteration

Tujuannya: kamu bisa membuat dan memasang efek **sendiri**. Empat efek contoh sudah terpasang untuk
Helder (cek bagian 4) supaya kamu punya patokan yang pasti jalan; sisanya jadi latihanmu.
Commit dulu proyekmu ke git sebelum menimpa file dari patch ini.

## 0. Ringkasnya
1. Salin sprite sheet dari paket PVFX ke `assets/vfx/`.
2. Buat scene efek di `scenes/vfx/` (node `AnimatedSprite2D` + frame dari sheet itu).
3. Seret scene itu ke **slot** yang sesuai di Inspector (`.tres` karakter, skill, atau item).

Tidak ada kode yang perlu kamu ubah untuk menambah efek baru.

## 1. Slot: di mana efek dipasang

| Kejadian | Slot di Inspector | Muncul di | Kapan |
|---|---|---|---|
| Serangan biasa | `data/characters/<nama>.tres` > Battle art > **Attack Vfx** | musuh yang terkena | tiap pukulan mendarat (tidak muncul kalau Dodge) |
| Guard | `data/characters/<nama>.tres` > **Guard Vfx** | karakter yang Guard | saat Guard dipakai |
| Item | `data/items/<item>.tres` > **Vfx** | target item | saat item dipakai |
| Skill alteration | `data/skills/<karakter>/<skill>.tres` > **Vfx Cast** | pemakai skill | saat skill mulai (awal spellcast) |
| Skill alteration | `data/skills/<karakter>/<skill>.tres` > **Vfx Hit** | setiap target | saat skill mendarat (setelah jeda animasi) |
| Cadangan skill | `data/characters/<nama>.tres` > **Alter Vfx** | pemakai skill | dipakai kalau skill tidak punya Vfx Cast |

* Isi Vfx Cast / Vfx Hit di properti **Skill**-nya (di luar array *Moves*), bukan di dalam Move. Semua Move milik skill itu
  otomatis ikut (Cannon punya satu Move per level Energy, jadi cukup diisi sekali). Slot di dalam Move hanya untuk
  memberi satu Move efek yang berbeda.
* Vfx Hit hanya untuk skill Alteration. Serangan biasa memakai Attack Vfx milik karakter.
* Skill yang mengenai banyak target (semua musuh, seluruh tim) memutar Vfx Hit satu kali **per target**.

## 2. Mengenal paket PVFX
* Letak sheet: `effects/<keluarga>/<efek>/<tier>/grid/sprite-sheet.png`. Contoh: `effects/impacts/hit-spark/lit/grid/sprite-sheet.png`.
* **Tier**: `lit` = warna penuh dengan cahaya dan bagian transparan lembut. `strict` = palet terbatas, tiap piksel penuh atau
  kosong (lebih "piksel keras"). Keduanya boleh; contoh di sini memakai `lit`.
* **Warna lain**: beberapa efek punya varian di `effects/<keluarga>/<efek>/variants/<warna>/lit/grid/sprite-sheet.png`
  (misal hit-spark: frost, venom, void, spirit). Ukuran, jumlah frame, dan pivotnya sama, jadi cara pasangnya sama.
* **Grid sheet**: 8 kolom, urutan frame dari kiri ke kanan lalu ke bawah. Satu sel = ukuran kanvas efek. Baris terakhir boleh punya sel kosong.
* Angka yang kamu butuhkan per efek: **ukuran**, **jumlah frame**, **ms per frame**, dan **pivot**. Semuanya ada di
  `assets/vfx/PVFX_DAFTAR.md` (daftar 253 efek, cari dengan Ctrl+F) atau di `pack.json` milik paket.
* Rumus: **FPS = 1000 / ms per frame**. **Vertical = jumlah frame / 8, dibulatkan ke atas**.
* **Pivot** = titik pada efek yang menempel ke targetnya. Kita taruh pivot itu di tengah badan target dengan **Offset**
  (bagian 3, langkah 8).
* Lisensi paket: CC0, bebas dipakai. Lihat `assets/vfx/CREDITS_VFX.txt`.

## 3. Latihan 1: membuat scene efek (contoh: `punch-hit` untuk serangan Radik)
Angka dari tabel bagian 5: ukuran 48x40, 11 frame, 16.7 FPS, Vertical 2, Scale 2, Offset (7, -1).

1. **Salin sheet.** Dari zip PVFX ambil `effects/impacts/punch-hit/lit/grid/sprite-sheet.png`, taruh di `assets/vfx/`
   dan ganti namanya jadi `punch_hit.png`. Buka Godot dan tunggu import selesai (bar kecil di kanan bawah).
2. **Buat scene.** Scene > New Scene > **Other Node**, cari `AnimatedSprite2D`, Create. Klik node itu, tekan F2, namai `PunchHit`.
   Ctrl+S dan simpan di `scenes/vfx/punch_hit.tscn`.
3. **Sprite Frames.** Di Inspector, kotak **Sprite Frames** > `<empty>` > **New SpriteFrames**. Klik SpriteFrames yang baru itu
   supaya panel **SpriteFrames** terbuka di bagian bawah layar.
4. **Isi frame.** Biarkan nama animasinya `default` (game memutar animasi yang aktif). Klik ikon **Add frames from Sprite Sheet**
   (ikon kotak-kotak), pilih `punch_hit.png`.
5. **Potong sheet.** Di dialog isi **Horizontal = 8** dan **Vertical = 2**. Klik frame pertama, lalu **Shift+klik** frame ke-11
   (sisa sel kosong jangan ikut). Tekan **Add 11 Frame(s)**.
6. **Kecepatan.** Di panel SpriteFrames isi **FPS = 16.7**. Pastikan tombol **Loop** (panah melingkar) **mati**.
7. **Tampilan piksel.** Klik node `PunchHit`. Di Inspector: CanvasItem > Texture > **Filter = Nearest**
   (supaya piksel tidak buram), dan Node2D > Transform > **Scale = (2, 2)**. Pakai angka bulat (1, 2, 3) supaya piksel rata.
8. **Posisi.** AnimatedSprite2D > **Offset = (7, -1)**. Rumusnya: `Offset.x = lebar / 2 - pivot.x`, `Offset.y = tinggi / 2 - pivot.y`.
   Efek yang pivotnya di tengah cukup (0, 0).
   **Efek "tanah"** (pivot di dekat bawah, seperti bunga yang tumbuh atau pilar cahaya): tambahkan `45 / Scale` ke Offset.y
   supaya efek menapak di kaki target, bukan di perutnya. Tabel di bawah sudah menghitungnya dan menandainya.
9. Ctrl+S. Selesai. Kamu bisa melihat animasinya dengan tombol Play di panel SpriteFrames.

Untuk melihat contoh yang sudah jadi, buka `scenes/vfx/hit_spark.tscn`, `block_guard.tscn`, `heal_plus.tscn`, `bloom_heal.tscn`
dan bandingkan Inspector-nya dengan langkah di atas.

## 4. Latihan 2: memasang efek ke slot
Cara umum: klik dua kali file `.tres` di FileSystem, cari slot di Inspector, lalu **seret** scene dari FileSystem ke slot itu
(atau klik `<empty>` > **Quick Load**). Tekan Ctrl+S.

Sudah terpasang sebagai contoh (Helder dan item penyembuh):
* `data/characters/helder.tres`: **Attack Vfx** = `hit_spark.tscn`, **Guard Vfx** = `block_guard.tscn`.
* `data/skills/helder/h_rejuvenate.tres`: **Vfx Hit** = `bloom_heal.tscn`.
* `data/items/med_njus.tres` dan `evvac_emk.tres`: **Vfx** = `heal_plus.tscn`.

Latihanmu:
* **Attack Radik**: `data/characters/radik.tres` > Battle art > Attack Vfx = `punch_hit.tscn` (dari Latihan 1).
* **Guard**: slot **Guard Vfx** di `.tres` tiap karakter.
* **Item**: slot **Vfx** di tiap file di `data/items/`.
* **Skill**: slot **Vfx Cast** dan **Vfx Hit** di file skill. Slot ini ada tepat di bawah *Sort Order*, di luar array *Moves*.

## 5. Daftar efek yang kusarankan (kamu yang membuatnya)
Kolom **Scale** dan **Offset** adalah titik awal, silakan disetel sesuai selera.

### Attack
| Untuk | Slot | Efek (id di PVFX) | Ukuran | Frame | Vertical | FPS | Scale | Offset | Catatan |
|---|---|---|---|---|---|---|---|---|---|
| Helder | Attack Vfx | `impacts/hit-spark` | 64x64 | 8 | 1 | 12.5 | 2 | (0, 0) | SUDAH TERPASANG (contoh) |
| Radik | Attack Vfx | `impacts/punch-hit` | 48x40 | 11 | 2 | 16.7 | 2 | (7, -1) | atau melee/dagger-slash |
| Dean | Attack Vfx | `impacts/metal-clang` | 58x44 | 13 | 2 | 16.7 | 2 | (5, -4) | bunyi rantai dan logam |
| WYG-01 | Attack Vfx | `scifi/laser-impact` | 80x56 | 18 | 3 | 16.7 | 2 | (-24, -2) | atau scifi/plasma-impact |

### Guard
| Untuk | Slot | Efek (id di PVFX) | Ukuran | Frame | Vertical | FPS | Scale | Offset | Catatan |
|---|---|---|---|---|---|---|---|---|---|
| Helder | Guard Vfx | `impacts/block-guard` | 48x60 | 10 | 2 | 16.7 | 3 | (2, 4) | SUDAH TERPASANG (contoh) |
| Radik | Guard Vfx | `holy/barrier-block` | 40x56 | 16 | 2 | 18.2 | 2 | (20, 28) |  |
| Dean | Guard Vfx | `arcane/mana-shield` | 80x76 | 20 | 3 | 14.3 | 2 | (0, -5.5) | efek loop, diputar sekali saja; efek tanah (kaki) |
| WYG-01 | Guard Vfx | `scifi/energy-shield` | 88x64 | 16 | 2 | 13.3 | 2 | (0, -2.5) | ada varian warna; efek tanah (kaki); loop, diputar sekali |

### Item
| Untuk | Slot | Efek (id di PVFX) | Ukuran | Frame | Vertical | FPS | Scale | Offset | Catatan |
|---|---|---|---|---|---|---|---|---|---|
| EVVAC-EMK, Med-Njus (Heal) | Vfx | `ui/heal-plus` | 46x48 | 13 | 2 | 14.3 | 2 | (0, 8.5) | SUDAH TERPASANG (contoh); efek tanah (kaki) |
| M.E.G-P3K, M.E.G-R3V (Revive) | Vfx | `holy/resurrect` | 48x80 | 21 | 3 | 14.3 | 2 | (0, -9.5) | ; efek tanah (kaki) |
| Bir Pletok, Kratingden (Booster) | Vfx | `ui/buff-arrow` | 40x48 | 13 | 2 | 16.7 | 2 | (0, 4.5) | ; efek tanah (kaki) |
| Inj-CQB, Inj-ACB (Admin's Special) | Vfx | `status/power-up-aura` | 56x56 | 14 | 2 | 14.3 | 2 | (0, 0.5) | ada varian warna; efek tanah (kaki); loop, diputar sekali |

### Skill alteration
| Untuk | Slot | Efek (id di PVFX) | Ukuran | Frame | Vertical | FPS | Scale | Offset | Catatan |
|---|---|---|---|---|---|---|---|---|---|
| Helder - Absorption | Vfx Hit | `holy/holy-nova` | 128x108 | 25 | 4 | 14.3 | 1 | (0, 6) | ledakan cahaya ke semua musuh |
| Helder - Condemn | Vfx Hit | `holy/holy-smite` | 80x120 | 14 | 2 | 12.5 | 1 | (0, -3) | hantaman cahaya ke satu musuh; efek tanah (kaki) |
| Helder - Flicking | Vfx Hit | `impacts/magic-hit` | 48x48 | 14 | 2 | 16.7 | 2 | (0, 0) | percikan kecil |
| Helder - Rejuvenate | Vfx Hit | `nature/bloom-heal` | 56x64 | 22 | 3 | 14.3 | 2 | (0, -0.5) | SUDAH TERPASANG (contoh); efek tanah (kaki) |
| Helder - Strengthen | Vfx Hit | `status/power-up-aura` | 56x56 | 14 | 2 | 14.3 | 2 | (0, 0.5) | menyelimuti Helder; efek tanah (kaki); loop, diputar sekali |
| Radik - "Berandalan" | Vfx Cast | `smoke/dash-dust` | 68x32 | 13 | 2 | 16.7 | 2 | (10, 10.5) | debu saat menerjang; efek tanah (kaki) |
| Radik - "Berandalan" | Vfx Hit | `impacts/crit-hit` | 96x80 | 11 | 2 | 14.3 | 2 | (0, 0) | hantaman keras |
| Radik - Stance "Heroik" | Vfx Hit | `holy/barrier-block` | 40x56 | 16 | 2 | 18.2 | 2 | (20, 28) | sikap bertahan |
| Radik - Stance "Kilau" | Vfx Hit | `status/haste` | 72x52 | 16 | 2 | 16.7 | 2 | (-12, 1.5) | lebih cepat; efek tanah (kaki); loop, diputar sekali |
| Radik - One-Two | Vfx Hit | `melee/quickdraw-slash` | 104x64 | 11 | 2 | 14.3 | 1 | (0, 0) | dua tebasan (muncul sekali per pakai) |
| Radik - Ravaging | Vfx Hit | `melee/spin-slash` | 120x72 | 14 | 2 | 16.7 | 1 | (0, 2) | menyapu semua musuh |
| Dean - Enchain | Vfx Hit | `melee/whip-crack` | 96x40 | 8 | 1 | 16.7 | 2 | (43, -2) | rantai melecut |
| Dean - Encompass | Vfx Hit | `arcane/magic-circle` | 96x64 | 20 | 3 | 12.5 | 2 | (0, 7.5) | rantai melingkar ke semua musuh; efek tanah (kaki) |
| Dean - Eruption | Vfx Hit | `impacts/ground-slam` | 128x64 | 19 | 3 | 14.3 | 1 | (0, -12) | ledakan dari tanah |
| Dean - Onslaught | Vfx Hit | `melee/whip-crack` | 96x40 | 8 | 1 | 16.7 | 2 | (43, -2) | cambukan beruntun |
| Dean - Overcome | Vfx Hit | `status/stun-stars` | 48x32 | 16 | 2 | 13.3 | 2 | (0, 0) | musuh terkena Stun; loop, diputar sekali |
| WYG-01 - Booster | Vfx Hit | `ui/mana-pickup` | 44x44 | 13 | 2 | 16.7 | 2 | (0, 0) | energi ke seluruh tim |
| WYG-01 - Cannon | Vfx Cast | `scifi/muzzle-flash` | 40x28 | 10 | 2 | 16.7 | 3 | (17, -1) | moncong meriam |
| WYG-01 - Cannon | Vfx Hit | `scifi/plasma-impact` | 88x64 | 18 | 3 | 16.7 | 2 | (-10, 0) | ledakan plasma |
| WYG-01 - Field Heal | Vfx Hit | `holy/regen-aura` | 48x64 | 16 | 2 | 12.5 | 2 | (0, -2.5) | nanobot penyembuh; efek tanah (kaki); loop, diputar sekali |
| WYG-01 - Firecracker | Vfx Hit | `explosions/cluster-bomb` | 176x136 | 31 | 4 | 14.3 | 1 | (0, 5) | hujan roket kluster; efek tanah (kaki) |
| WYG-01 - Javelin | Vfx Hit | `projectiles/arrow-impact` | 64x32 | 17 | 3 | 16.7 | 2 | (-18, -1) | lembing menancap |

Mau warna lain? Pakai varian di folder `variants/<warna>/` (daftar varian ada di `PVFX_DAFTAR.md`), caranya sama persis.

## 6. Menyetel hasilnya
* **Terlalu kecil atau besar**: ubah Scale (1, 2, atau 3).
* **Posisinya geser**: ubah Offset. Efek tanah butuh tambahan `45 / Scale` pada Offset.y.
* **Terlalu cepat atau lambat**: ubah FPS di panel SpriteFrames.
* **Efek bertipe loop** (aura, perisai) dimainkan **sekali saja** oleh game, lalu dihapus.
* Paling banyak **12 efek** berjalan sekaligus, dan tiap efek dihapus paling lama setelah 3 detik.
* Skill dengan banyak target memutar satu efek per target, jadi pilih efek yang tidak terlalu besar untuk skill "semua musuh".

## 7. Kalau efeknya tidak muncul
1. Slotnya masih `<empty>`? Cek lagi di Inspector dan pastikan sudah Ctrl+S.
2. PNG belum ter-import? Buka Godot dan tunggu import selesai. Efek yang PNG-nya hilang tampil kosong tapi tetap berjalan.
3. Animasi di SpriteFrames bukan `default`, atau Sprite Frames node kosong.
4. Serangan biasa **tidak** memutar Attack Vfx kalau serangannya Dodge.
5. Skill: pastikan kamu mengisi file skill yang benar (`data/skills/<karakter>/...`), dan Move di dalamnya tidak punya Vfx sendiri yang menimpa slot Skill.
6. Muncul error soal `vfx_hit` atau `guard_vfx`? Berarti file skrip dari patch ini belum tertimpa semuanya.
7. Jalankan `godot --headless --path . --script res://tests/vfx_test.gd`. Hasil akhirnya harus **ALL PASSED**. Kalau ada FAIL, kirim lognya.

## 8. Cara kerja kodenya (untuk kamu pahami dan tulis ulang)
1. `BattleManager._execute_action` memancarkan tiga sinyal berurutan: `action_announced` (siapa pakai apa), `action_targeted`
   (siapa sasarannya), lalu, setelah jeda animasi (kalau ada), **`action_landed(user, targets, source)`**. `source` adalah
   Move, Item, atau `null` untuk Guard.
2. `BattleStage._on_action_announced`: untuk Alteration memutar **Vfx Cast** milik skill, atau **Alter Vfx** karakter kalau skill tidak punya.
3. `BattleStage._on_action_landed`: Guard memutar **Guard Vfx**; Alteration memutar **Vfx Hit** di tiap target; Item memutar **Vfx** item di targetnya.
4. `BattleStage._show_hit` (sudah ada sejak awal): serangan biasa memutar **Attack Vfx** di target yang kena.
5. `Skill.build_moves()` menyalin Vfx Cast / Vfx Hit dari Skill ke tiap Move, jadi slot di Skill berlaku untuk semuanya.
6. `VfxPlayer.play(scene, parent, posisi)` memunculkan scene itu, memutar animasinya sekali, lalu menghapusnya.

## 9. Yang belum ada
* Efek yang **menetap** selama kondisi berlangsung (misalnya gelembung Guard sampai ronde berikutnya).
* Efek **proyektil** yang terbang dari penyerang ke target (Cannon, Javelin). Sekarang hanya efek saat kena.
* Efek untuk musuh selain Attack Vfx yang sudah ada.

## 10. File yang berubah
* Baru: `scenes/vfx/` (hit_spark, block_guard, heal_plus, bloom_heal), `assets/vfx/` (4 PNG, `PVFX_DAFTAR.md`, `CREDITS_VFX.txt`),
  `tests/vfx_test.gd`, `PANDUAN_VFX.md`.
* Diubah (kode): `scripts/battle/battle_manager.gd`, `scripts/ui/battle_stage.gd`, `scripts/ui/unit_visual.gd`,
  `scripts/data/character_template.gd`, `scripts/data/skill.gd`, `scripts/data/move.gd`, `scripts/data/item.gd`, `ASSET_RULES.md`.
* Diubah (data contoh): `data/characters/helder.tres`, `data/skills/helder/h_rejuvenate.tres`, `data/items/med_njus.tres`, `data/items/evvac_emk.tres`.
