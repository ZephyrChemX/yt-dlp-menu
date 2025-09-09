# ydl-menu (PowerShell) — versi dengan Clipboard

Script PowerShell sederhana untuk mengunduh video/audio/thumbnail menggunakan **yt-dlp**.  
Mendukung pilihan kualitas (best/1080p60/720p60/480p) dan bahasa subtitle (Indonesia/English/Japanese/None).  
Sekarang sudah bisa **ambil URL langsung dari clipboard** 🎉

## ✨ Fitur
- MP4: audio+video digabung, metadata & thumbnail ter-embed.
- MP3: ekstrak audio kualitas terbaik (`--audio-quality 0`), cover dari thumbnail.
- Thumbnail saja: simpan gambar asli (jpg/png/webp).
- Subtitle: bisa embed id, en, ja, atau none.
- Playlist YouTube: deteksi otomatis, pilih semua item atau satu video.
- Clipboard: copy link lalu jalankan `ydl-clip.cmd`.

## 📦 Instalasi
1. Taruh `yt-dlp.exe` & `ffmpeg.exe` di folder `C:\tools\yt-dlp\` dan tambahkan ke PATH.
2. Ekstrak file repo ini ke folder yang sama.
3. (Sekali saja) izinkan eksekusi PowerShell script:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

## 🚀 Cara Pakai
- Klik dua kali `ydl-clip.cmd` → langsung ambil link dari clipboard.
- Manual lewat PowerShell:
  ```powershell
  pwsh -File C:\tools\yt-dlp\ydl-menu.ps1
  ```
- Dengan argumen:
  ```powershell
  pwsh -File C:\tools\yt-dlp\ydl-menu.ps1 -Url "https://youtu.be/xxxx"
  pwsh -File C:\tools\yt-dlp\ydl-menu.ps1 -Clipboard
  ```

## 🔧 Kustomisasi
- Folder output → ubah `$dest` di script (default: `~/Downloads/ydl`).
- Nama file → ubah pola `-o` di script.
- Cookies Chrome → uncomment baris `--cookies-from-browser chrome`.

## 🛠 Troubleshooting
- Error *Permission denied* → jangan jalankan dari `C:\Windows\System32`.
- Judul Jepang jadi acak → jangan pakai `--restrict-filenames`.

## 📜 Lisensi
MIT
