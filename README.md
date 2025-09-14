# ydl-menu (PowerShell) — Final Version

Menu interaktif **yt-dlp** untuk Windows, dengan fitur:
- Output dipisah otomatis (mp4/webm/mp3/m4a/thumb + single/playlist)
- Downloader per domain (YouTube/TikTok/Bilibili/Facebook/Twitch → internal, Twitter/Reddit/Instagram/SoundCloud → aria2c)
- **MP4/WebM tidak lagi embed thumbnail** (supaya tidak spam log)
- **MP3/M4A tetap embed thumbnail** (jadi ada cover art)
- Cookies per situs (YouTube / Bilibili / TikTok / Instagram / Reddit / Twitter/X / SoundCloud / Facebook / Twitch)
- Pilihan format & kualitas video (MP4/WebM: best / 1080p60 / 720p60 / 480p) + subtitle (id/en/ja/none)
- Mendukung clipboard & argumen URL
- Video <1 menit (single) otomatis kualitas terbaik
- Opsi thumbnail: ambil thumbnail bawaan atau frame video pada waktu tertentu (ffmpeg)


---

## ✨ Prasyarat
- `yt-dlp.exe`, `ffmpeg.exe`, `aria2c.exe` berada di `C:\tools\yt-dlp\` dan sudah masuk PATH.
- (Opsional) cookies di `C:\tools\yt-dlp\cookies\`:
  - `youtube.txt`
  - `bilibili.txt`
  - `tiktok.txt`
  - `instagram.txt`
  - `reddit.txt`
  - `twitter.txt`
  - `soundcloud.txt`
  - `facebook.txt`
  - `twitch.txt`

---

## 📦 Instalasi
1. Salin `ydl-menu.ps1` dan `ydl-clip.cmd` ke `C:\tools\yt-dlp\`.
2. Sekali saja jalankan:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

---

## 🚀 Cara Pakai
- **Klik dua kali** `ydl-clip.cmd` → otomatis ambil URL dari clipboard.
- **Manual**:
  ```powershell
  pwsh -File C:\tools\yt-dlp\ydl-menu.ps1
  ```
- **Dengan argumen**:
  ```powershell
  pwsh -File C:\tools\yt-dlp\ydl-menu.ps1 -Url "https://youtu.be/xxxx"
  pwsh -File C:\tools\yt-dlp\ydl-menu.ps1 -Clipboard
  ```

---

## 📂 Struktur Output
Contoh hasil unduhan:

```
Downloads\ydl\
 ├─ mp4\
 │   ├─ single\
 │   │   └─ Judul Video.mp4
 │   └─ Nama Playlist\
 │       ├─ Video1.mp4
 │       └─ Video2.mp4
 ├─ webm\
 │   ├─ single\
 │   │   └─ Judul Video.webm
 │   └─ Nama Playlist\
 │       ├─ Video1.webm
 │       └─ Video2.webm
 ├─ mp3\
 │   ├─ single\
 │   │   └─ Judul Video.mp3 (dengan cover art)
 │   └─ Nama Playlist\
 │       └─ ...
 ├─ m4a\
 │   ├─ single\
 │   │   └─ Judul Video.m4a (dengan cover art)
 │   └─ Nama Playlist\
 │       └─ ...
 └─ thumb\
    ├─ single\
    │   └─ Judul Video.jpg
    └─ Nama Playlist\
        └─ ...
```

---

## 🔧 Kustomisasi
- **Folder output** → ubah variabel `$base` di script (`~/Downloads/ydl` default).
- **Nama file** → ubah pola `-o "%(title)s [%(uploader)s] [%(id)s].%(ext)s"`.
- **Codec H.264 prioritas** → ganti `$fmt` jadi `bv*[vcodec^=avc1]+ba/b[ext=mp4]`.
- **Cookies** → export cookies dari browser, simpan ke `C:\tools\yt-dlp\cookies\`.

---

## 🛠 Troubleshooting
- **Permission denied** → jangan jalankan dari `C:\Windows\System32`.
- **Judul Jepang jadi acak** → jangan pakai `--restrict-filenames`.
- **Video age-gate / login** → pastikan cookies sesuai situs tersedia.

---

## 🔄 Update ke GitHub
```powershell
cd C:\Projects\yt-dlp-menu
copy /Y C:\tools\yt-dlp\ydl-menu.ps1 .
copy /Y C:\tools\yt-dlp\ydl-clip.cmd .
copy /Y C:\tools\yt-dlp\README.md .
git add .
git commit -m "Final: hapus embed thumbnail untuk MP4 (anti spam log)"
git push origin main
```

---

## 📜 Lisensi
MIT
