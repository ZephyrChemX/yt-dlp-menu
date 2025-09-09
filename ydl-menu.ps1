# ydl-menu.ps1 — yt-dlp interactive menu (PowerShell 5.1/7)
# Fitur:
# - Output dipisah (mp4/mp3/thumb + single/playlist)
# - Downloader PER DOMAIN (internal vs aria2c balanced)
# - Cookies per situs (YouTube, Bilibili, TikTok, Instagram, Reddit, Twitter/X)
# - Pilihan kualitas video + subtitle
# - Clipboard & argumen -Url

param(
  [string]$Url,
  [switch]$Clipboard
)

function Get-UrlFromClipboard {
    try {
        $raw = Get-Clipboard -Raw
        if ($null -ne $raw -and $raw -match 'https?://\S+') { return $Matches[0] }
    } catch {}
    return $null
}

function Read-Choice($prompt, $choices) {
    Write-Host ""
    Write-Host $prompt
    $i = 1
    foreach ($c in $choices) { Write-Host ("  {0}. {1}" -f $i, $c); $i++ }
    do { $sel = Read-Host "Pilih [1..$($choices.Count)]" } until ($sel -as [int] -and $sel -ge 1 -and $sel -le $choices.Count)
    return [int]$sel
}

function Ensure-Tools {
    foreach ($tool in @("yt-dlp","ffmpeg")) {  # aria2c opsional (dipakai per-domain)
        $cmd  = Get-Command $tool -ErrorAction SilentlyContinue
        $path = if ($cmd) { $cmd.Source } else { $null }
        if (-not $path) {
            Write-Host "[!] $tool tidak ditemukan di PATH. Pastikan ada di C:\tools\yt-dlp\" -ForegroundColor Yellow
        }
    }
}

# ====== Helper: aktifkan aria2c bila tersedia ======
function Use-Aria2c {
    param([string]$profile = "balanced") # balanced | aggressive
    $aria = Get-Command "aria2c" -ErrorAction SilentlyContinue
    if (-not $aria) {
        Write-Host "[i] aria2c tidak ditemukan di PATH. Lanjut dengan internal downloader." -ForegroundColor DarkYellow
        return
    }
    switch ($profile) {
        "aggressive" { $args = "aria2c:-x16 -s16 -k1M --file-allocation=none" }
        default      { $args = "aria2c:-x4 -s4 -k1M --file-allocation=none" }  # balanced
    }
    $script:dlArgs += @("--downloader","aria2c","--downloader-args",$args)
    Write-Host "Downloader: aria2c ($profile)" -ForegroundColor DarkGray
}

Clear-Host
Write-Host "=== yt-dlp Menu Downloader (domain-aware) ===" -ForegroundColor Cyan
Ensure-Tools

# ====== URL input ======
if ($PSBoundParameters.ContainsKey('Url') -and $Url) {
    $url = $Url
} elseif ($Clipboard) {
    $url = Get-UrlFromClipboard
    if (-not $url) { Write-Host "Clipboard tidak berisi URL." -ForegroundColor Yellow }
} else {
    $clip = Get-UrlFromClipboard
    if ($clip) {
        Write-Host ("Ditemukan URL di clipboard: {0}" -f $clip) -ForegroundColor DarkCyan
        $use = Read-Host "Pakai URL clipboard ini? [Y/n]"
        if ($use -eq "" -or $use -match '^(y|Y)$') { $url = $clip }
    }
}
if (-not $url) { $url = Read-Host "Tempel link (YouTube/Bilibili/TikTok/Instagram/Reddit/Twitter)" }
if ([string]::IsNullOrWhiteSpace($url)) { Write-Host "URL kosong. Keluar."; exit 1 }

# ====== Base args (tanpa aria2c default) ======
$dlArgs = @(
  "--no-mtime","--embed-metadata","--windows-filenames","--no-restrict-filenames",
  "--merge-output-format","mp4"
)

# ====== Output base & pemisahan ======
$base = Join-Path $HOME "Downloads/ydl"
$null = New-Item -ItemType Directory -Force -Path "$base/mp4/single","$base/mp3/single","$base/thumb/single" -ErrorAction SilentlyContinue
$dlArgs += @(
  "-P","video:$base/mp4/%(playlist_title|single)s/",
  "-P","audio:$base/mp3/%(playlist_title|single)s/",
  "-P","thumbnail:$base/thumb/%(playlist_title|single)s/"
)

# ====== Mode ======
$modeChoice = Read-Choice "Pilih mode unduhan:" @("MP4 (video)","MP3 (audio saja)","Thumbnail saja")

switch ($modeChoice) {
    1 { # MP4
    $qualityChoice = Read-Choice "Pilih kualitas MP4:" @(
        "1) Kualitas terbaik (audio+video)",
        "2) 1080p 60fps prioritaskan",
        "3) 720p 60fps prioritaskan",
        "4) 480p"
    )
    switch ($qualityChoice) {
        1 { $fmt = 'bv*+ba/b' }
        2 { $fmt = 'bv*[height=1080][fps>=50]+ba/bv*[height=1080]+ba/b' }
        3 { $fmt = 'bv*[height=720][fps>=50]+ba/bv*[height=720]+ba/b' }
        4 { $fmt = 'bv*[height<=480]+ba/b[height<=480]' }
    }
    # Tidak lagi embed thumbnail untuk MP4
    $dlArgs += @("-f",$fmt)

    $subChoice = Read-Choice "Pilih bahasa subtitle untuk di-embed:" @("Indonesia","English","Japanese","No language")
    switch ($subChoice) {
        1 { $dlArgs += @("--sub-langs","id","--embed-subs","--sub-format","ass/srt/best") }
        2 { $dlArgs += @("--sub-langs","en","--embed-subs","--sub-format","ass/srt/best") }
        3 { $dlArgs += @("--sub-langs","ja","--embed-subs","--sub-format","ass/srt/best") }
        4 { $dlArgs += @("--no-write-subs") }
    }
}

    2 { # MP3
        $dlArgs += @("--extract-audio","--audio-format","mp3","--audio-quality","0","--embed-thumbnail","--add-metadata","--no-write-subs")
    }
    3 { # Thumbnail only
        $dlArgs += @("--skip-download","--write-thumbnail","--no-write-subs")
    }
}

# ====== Template nama file ======
$dlArgs += @("-o","%(title)s [%(uploader)s] [%(id)s].%(ext)s")

# ====== Cookies otomatis ======
$cookiesDir = "C:\tools\yt-dlp\cookies"
if (Test-Path $cookiesDir) {
    if     ($url -match "youtube\.com|youtu\.be") { $cookie = "youtube.txt" }
    elseif ($url -match "bilibili\.com")          { $cookie = "bilibili.txt" }
    elseif ($url -match "tiktok\.com")            { $cookie = "tiktok.txt" }
    elseif ($url -match "instagram\.com")         { $cookie = "instagram.txt" }
    elseif ($url -match "reddit\.com")            { $cookie = "reddit.txt" }
    elseif ($url -match "twitter\.com|x\.com")    { $cookie = "twitter.txt" }
    if ($cookie) {
        $cookiePath = Join-Path $cookiesDir $cookie
        if (Test-Path $cookiePath) {
            $dlArgs += @("--cookies", $cookiePath)
            Write-Host "Menggunakan cookies: $cookiePath" -ForegroundColor DarkGray
        } else {
            Write-Host "[i] File cookies tidak ditemukan: $cookiePath (lanjut tanpa cookies)" -ForegroundColor DarkYellow
        }
    }
}

# ====== Pilih downloader berdasarkan domain ======
$domain = $url.ToLower()

if ($domain -match "twitter\.com|x\.com|reddit\.com|instagram\.com") {
    # File tunggal cenderung cocok aria2c
    Use-Aria2c -profile "balanced"     # -x4 -s4 -k1M
}
elseif ($domain -match "youtube\.com|youtu\.be|tiktok\.com|bilibili\.com") {
    # Segmented (DASH/HLS): internal biasanya lebih cepat/stabil
    $dlArgs += @("--concurrent-fragments","10")
    Write-Host "Downloader: internal (concurrent fragments 10)" -ForegroundColor DarkGray
}
else {
    # Default: internal
    $dlArgs += @("--concurrent-fragments","10")
    Write-Host "Downloader: internal (default)" -ForegroundColor DarkGray
}

# ====== Eksekusi ======
Write-Host "`n> Menjalankan yt-dlp dengan opsi berikut:" -ForegroundColor Cyan
$pretty = ($dlArgs + @($url) | ForEach-Object { if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ } }) -join ' '
Write-Host ("yt-dlp " + $pretty)

& yt-dlp @dlArgs $url
$ec = $LASTEXITCODE
Write-Host "`nSelesai. ExitCode: $ec"
if ($ec -ne 0) { Write-Host "Ada error. Coba tambahkan --verbose untuk detail." -ForegroundColor Yellow }
