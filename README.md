# ydl-menu (PowerShell) — Enhanced Version

Menu interaktif **yt-dlp** untuk Windows, dengan fitur:
- Output dipisah otomatis (mp4/webm/mp3/m4a/thumb + single/playlist)
- Downloader per domain (YouTube/TikTok/Bilibili/Facebook/Twitch → internal, Twitter/Reddit/Instagram/SoundCloud → aria2c)
- **Quick Download Mode** (Opsi 6 untuk unduh kilat MP4 kualitas terbaik tanpa menu tambahan)
- **Auto-Update yt-dlp** via parameter `-Update`
- **Auto Cleanup** (Pembersihan file `.part` sisa unduhan >1 hari)
- **MP3/M4A embed thumbnail PNG** (cover art)
- Cookies per situs (YouTube / Bilibili / TikTok / Instagram / Reddit / Twitter/X / SoundCloud / Facebook / Twitch)
- Pilihan format & kualitas video + subtitle (id/en/ja/none)
- Mendukung clipboard & argumen URL

---

## ✨ Prasyarat
- `yt-dlp.exe`, `ffmpeg.exe`, `aria2c.exe` berada di `C:\tools\yt-dlp\` dan sudah masuk PATH.
- (Opsional) cookies di `C:\tools\yt-dlp\cookies\`.

---

## 📦 Instalasi
1. Salin `ydl-menu.ps1` ke direktori kerja.
2. Sekali saja jalankan:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

---

## 🚀 Cara Pakai
- **Manual**:
  ```powershell
  pwsh -File ydl-menu.ps1
  ```
- **Dengan argumen URL / Clipboard**:
  ```powershell
  pwsh -File ydl-menu.ps1 -Url "https://youtu.be/xxxx"
  pwsh -File ydl-menu.ps1 -Clipboard
  ```
- **Memperbarui yt-dlp**:
  ```powershell
  pwsh -File ydl-menu.ps1 -Update
  ```

---

## 📂 Struktur Output
Unduhan tersimpan rapi di `~/Downloads/ydl/` dipisahkan berdasarkan format (`mp4`, `webm`, `mp3`, `m4a`, `thumb`).

---

## 📜 Lisensi
MIT
