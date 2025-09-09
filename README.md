# ydl-menu (PowerShell) — Final Version

Menu interaktif **yt-dlp** untuk Windows, dengan fitur:
- Output dipisah otomatis (mp4/mp3/thumb + single/playlist)
- Downloader per domain (YouTube/TikTok/Bilibili → internal, Twitter/Reddit/Instagram → aria2c)
- **MP4 tidak lagi embed thumbnail** (supaya tidak spam log)
- **MP3 tetap embed thumbnail** (jadi ada cover art)
- Cookies per situs (YouTube / Bilibili / TikTok / Instagram / Reddit / Twitter/X)
- Pilihan kualitas video (best / 1080p60 / 720p60 / 480p) + subtitle (id/en/ja/none)
- Mendukung clipboard & argumen URL

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
 ├─ mp3\
 │   ├─ single\
 │   │   └─ Judul Video.mp3 (dengan cover art)
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
