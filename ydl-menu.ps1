# ydl-menu.ps1 — yt-dlp interactive menu (PowerShell 5.1/7)
# Fitur:
# - Output dipisah (mp4/webm/mp3/m4a/thumb + single/playlist)
# - Downloader PER DOMAIN (internal vs aria2c balanced)
# - Cookies per situs (YouTube, Bilibili, TikTok, Instagram, Reddit, Twitter/X, SoundCloud, Facebook, Twitch)
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
if (-not $url) { $url = Read-Host "Tempel link (YouTube/Bilibili/TikTok/Instagram/Reddit/Twitter/SoundCloud/Facebook/Twitch)" }
if ([string]::IsNullOrWhiteSpace($url)) { Write-Host "URL kosong. Keluar."; exit 1 }

# ====== Base args (tanpa aria2c default) ======
$dlArgs = @(
  "--no-mtime","--embed-metadata","--windows-filenames","--no-restrict-filenames"
)

$thumbFrame = $null

# ====== Output base & pemisahan ======
$base = Join-Path $HOME "Downloads/ydl"
$null = New-Item -ItemType Directory -Force -Path "$base/mp4/single","$base/webm/single","$base/mp3/single","$base/m4a/single","$base/thumb/single" -ErrorAction SilentlyContinue
$dlArgs += @(
  "-P","thumbnail:$base/thumb/%(playlist_title|single)s/"
)

# ====== Mode ======
$outputOverride = $null
$modeChoice = Read-Choice "Pilih mode unduhan:" @("MP4 (video)","WEBM (video)","MP3 (audio saja)","M4A (audio saja)","Thumbnail saja")

switch ($modeChoice) {
    1 { # MP4
        $dlArgs += @("--merge-output-format","mp4","-P","video:$base/mp4/%(playlist_title|single)s/")
        $autoBest = $false
        try {
            $infoJson = yt-dlp --dump-single-json --no-warnings $url 2>$null
            $info = $infoJson | ConvertFrom-Json
            if ($info._type -eq 'video' -and $info.duration -lt 60) {
                $autoBest = $true
                $fmt = 'bv*+ba/b'
                Write-Host "Durasi < 60 detik, memakai kualitas terbaik otomatis." -ForegroundColor DarkGray
            }
        } catch {}
        if (-not $autoBest) {
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
        }
        $dlArgs += @("-f",$fmt)

        $subChoice = Read-Choice "Pilih bahasa subtitle untuk di-embed:" @("Indonesia","English","Japanese","No language")
        switch ($subChoice) {
            1 { $dlArgs += @("--sub-langs","id","--embed-subs","--sub-format","ass/srt/best") }
            2 { $dlArgs += @("--sub-langs","en","--embed-subs","--sub-format","ass/srt/best") }
            3 { $dlArgs += @("--sub-langs","ja","--embed-subs","--sub-format","ass/srt/best") }
            4 { $dlArgs += @("--no-write-subs") }
        }
    }

    2 { # WEBM
        $dlArgs += @("--merge-output-format","webm","-P","video:$base/webm/%(playlist_title|single)s/")
        $autoBest = $false
        try {
            $infoJson = yt-dlp --dump-single-json --no-warnings $url 2>$null
            $info = $infoJson | ConvertFrom-Json
            if ($info._type -eq 'video' -and $info.duration -lt 60) {
                $autoBest = $true
                $fmt = 'bv*[ext=webm]+ba[ext=webm]/b[ext=webm]'
                Write-Host "Durasi < 60 detik, memakai kualitas terbaik otomatis." -ForegroundColor DarkGray
            }
        } catch {}
        if (-not $autoBest) {
            $qualityChoice = Read-Choice "Pilih kualitas WEBM:" @(
                "1) Kualitas terbaik (audio+video)",
                "2) 1080p 60fps prioritaskan",
                "3) 720p 60fps prioritaskan",
                "4) 480p"
            )
            switch ($qualityChoice) {
                1 { $fmt = 'bv*[ext=webm]+ba[ext=webm]/b[ext=webm]' }
                2 { $fmt = 'bv*[height=1080][fps>=50][ext=webm]+ba[ext=webm]/bv*[height=1080][ext=webm]+ba[ext=webm]/b[height=1080][ext=webm]' }
                3 { $fmt = 'bv*[height=720][fps>=50][ext=webm]+ba[ext=webm]/bv*[height=720][ext=webm]+ba[ext=webm]/b[height=720][ext=webm]' }
                4 { $fmt = 'bv*[height<=480][ext=webm]+ba[ext=webm]/b[height<=480][ext=webm]' }
            }
        }
        $dlArgs += @("-f",$fmt)

        $subChoice = Read-Choice "Pilih bahasa subtitle untuk di-embed:" @("Indonesia","English","Japanese","No language")
        switch ($subChoice) {
            1 { $dlArgs += @("--sub-langs","id","--embed-subs","--sub-format","ass/srt/best") }
            2 { $dlArgs += @("--sub-langs","en","--embed-subs","--sub-format","ass/srt/best") }
            3 { $dlArgs += @("--sub-langs","ja","--embed-subs","--sub-format","ass/srt/best") }
            4 { $dlArgs += @("--no-write-subs") }
        }
    }

    3 { # MP3
        $dlArgs += @(
            "--extract-audio","--audio-format","mp3","--audio-quality","0",
            "--embed-thumbnail","--add-metadata","--no-write-subs",
            "-P","audio:$base/mp3/%(playlist_title|single)s/"
        )
    }
    4 { # M4A
        $dlArgs += @(
            "--extract-audio","--audio-format","m4a","--audio-quality","0",
            "--embed-thumbnail","--add-metadata","--no-write-subs",
            "-P","audio:$base/m4a/%(playlist_title|single)s/"
        )
    }
    5 { # Thumbnail only
        $thumbChoice = Read-Choice "Pilih jenis thumbnail:" @("Thumbnail default","Thumbnail dari durasi tertentu")
        switch ($thumbChoice) {
            1 {
                $dlArgs += @("--skip-download","--write-thumbnail","--no-write-subs")
            }
            2 {
                $time = Read-Host "Masukkan waktu (detik atau mm:ss)"
                $execCmd = "ffmpeg -ss $time -i \"%(filepath)s\" -frames:v 1 \"%(filepath)s.jpg\" && ren \"%(filepath)s.jpg\" \"%(filename)s.jpg\" && del \"%(filepath)s\""
                $outputOverride = "$base/thumb/%(playlist_title|single)s/%(title)s [%(uploader)s] [%(id)s].%(ext)s"
                $dlArgs += @("--merge-output-format","mp4","--no-write-subs","-f","bv*+ba/b","--exec",$execCmd)
            }
        }
    }
}

# ====== Template nama file ======
if ($outputOverride) {
    $dlArgs += @("-o",$outputOverride)
} else {
    $dlArgs += @("-o","%(title)s [%(uploader)s] [%(id)s].%(ext)s")
}

# ====== Cookies otomatis ======
$cookiesDir = "C:\tools\yt-dlp\cookies"
if (Test-Path $cookiesDir) {
    if     ($url -match "youtube\.com|youtu\.be") { $cookie = "youtube.txt" }
    elseif ($url -match "bilibili\.com")          { $cookie = "bilibili.txt" }
    elseif ($url -match "tiktok\.com")            { $cookie = "tiktok.txt" }
    elseif ($url -match "instagram\.com")         { $cookie = "instagram.txt" }
    elseif ($url -match "reddit\.com")            { $cookie = "reddit.txt" }
    elseif ($url -match "twitter\.com|x\.com")    { $cookie = "twitter.txt" }
    elseif ($url -match "soundcloud\.com")        { $cookie = "soundcloud.txt" }
    elseif ($url -match "facebook\.com|fb\.watch") { $cookie = "facebook.txt" }
    elseif ($url -match "twitch\.tv")             { $cookie = "twitch.txt" }
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

if ($domain -match "twitter\.com|x\.com|reddit\.com|instagram\.com|soundcloud\.com") {
    # File tunggal cenderung cocok aria2c
    Use-Aria2c -profile "balanced"     # -x4 -s4 -k1M
}
elseif ($domain -match "youtube\.com|youtu\.be|tiktok\.com|bilibili\.com|facebook\.com|fb\.watch|twitch\.tv") {
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
if ($thumbFrame) {
    Write-Host "`n> Mengambil thumbnail dari durasi $thumbFrame" -ForegroundColor Cyan
    $tmpBase   = [IO.Path]::GetTempFileName()
    $manualArgs = $dlArgs + @("-f","bestvideo","-o",$tmpBase + ".%(ext)s")
    $pretty = ($manualArgs + @($url) | ForEach-Object { if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ } }) -join ' '
    Write-Host ("yt-dlp " + $pretty)
    & yt-dlp @manualArgs $url
    $videoFile = Get-ChildItem ($tmpBase + ".*") | Select-Object -First 1 -ExpandProperty FullName
    $infoJson = yt-dlp --dump-single-json --no-warnings $url 2>$null
    $info     = $infoJson | ConvertFrom-Json
    $folder   = if ($info.playlist_title) { $info.playlist_title } else { "single" }
    $name     = "{0} [{1}] [{2}]" -f $info.title, $info.uploader, $info.id
    $outDir   = Join-Path $base "thumb/$folder"
    $null     = New-Item -ItemType Directory -Force -Path $outDir
    $outFile  = Join-Path $outDir ($name + ".jpg")
    ffmpeg -ss $thumbFrame -i $videoFile -vframes 1 $outFile
    $ec = $LASTEXITCODE
    Remove-Item ($tmpBase + ".*") -Force
    Write-Host "`nSelesai. ExitCode: $ec"
    if ($ec -ne 0) { Write-Host "Ada error. Coba tambahkan --verbose untuk detail." -ForegroundColor Yellow }
} else {
    Write-Host "`n> Menjalankan yt-dlp dengan opsi berikut:" -ForegroundColor Cyan
    $pretty = ($dlArgs + @($url) | ForEach-Object { if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ } }) -join ' '
    Write-Host ("yt-dlp " + $pretty)
    & yt-dlp @dlArgs $url
    $ec = $LASTEXITCODE
    Write-Host "`nSelesai. ExitCode: $ec"
    if ($ec -ne 0) { Write-Host "Ada error. Coba tambahkan --verbose untuk detail." -ForegroundColor Yellow }
}
