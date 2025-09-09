# ydl-menu (PowerShell)
Menu interaktif untuk `yt-dlp` di Windows. Memilih MP4/MP3/Thumbnail, preset kualitas (best/1080p60/720p60/480p), dan bahasa subtitle (ID/EN/JA/None). Kompatibel PowerShell 5.1 & 7.

## Fitur
- Deteksi playlist YouTube (pilih proses semua atau satu video).
- MP4: embed metadata + thumbnail; MP3: extract audio terbaik + cover dari thumbnail.
- Output diarahkan ke `~/Downloads/ydl` agar aman dari permission.
- Menjaga nama file non‑ASCII (Jepang, dll) dengan `--windows-filenames` & `--no-restrict-filenames`.
- Template nama file: `%(title)s [%(uploader)s] [%(id)s].%(ext)s`.

## Prasyarat
- `yt-dlp.exe` & `ffmpeg.exe` di PATH (contoh: `C:\tools\yt-dlp\`).  
- PowerShell 7 **atau** Windows PowerShell 5.1.

## Instalasi Ringkas
1. Simpan `ydl-menu.ps1` ke `C:\tools\yt-dlp\`
2. Buka PowerShell:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   pwsh -File C:\tools\yt-dlp\ydl-menu.ps1   # atau .\ydl-menu.ps1 di PS 5.1
   ```

## Opsi Tambahan
- Cookies Chrome (untuk video yang butuh login/bot check): buka file dan uncomment baris `--cookies-from-browser chrome`.
- Ganti folder output: ubah variabel `$dest` di script.

## Troubleshooting
- `Permission denied` saat embed thumbnail → pastikan tidak menjalankan dari `C:\Windows\System32`; script ini sudah mengalihkan ke `~/Downloads/ydl`.
- Judul Jepang jadi acak → jangan pakai `--restrict-filenames` di config global; script sudah menimpa ke `--no-restrict-filenames`.

## Lisensi
MIT
