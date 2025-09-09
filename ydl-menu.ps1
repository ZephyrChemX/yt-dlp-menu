# ydl-menu.ps1 — yt-dlp interactive menu with clipboard support

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

function Is-YouTubePlaylist($url) {
    if ($url -match "(^https?://)?(www\.)?youtube\.com/playlist\?list=") { return $true }
    if ($url -match "(^https?://)?(www\.)?youtube\.com/watch\?.*?(\?|&)list=") { return $true }
    return $false
}

function Build-SubtitleArgs($choice) {
    switch ($choice) {
        1 { return @("--sub-langs","id","--embed-subs","--sub-format","ass/srt/best") }
        2 { return @("--sub-langs","en","--embed-subs","--sub-format","ass/srt/best") }
        3 { return @("--sub-langs","ja","--embed-subs","--sub-format","ass/srt/best") }
        default { return @("--no-write-subs") }
    }
}

function Ensure-Tools {
    foreach ($tool in @("yt-dlp","ffmpeg")) {
        $cmd  = Get-Command $tool -ErrorAction SilentlyContinue
        $path = if ($cmd) { $cmd.Source } else { $null }
        if (-not $path) {
            Write-Host "`n[!] $tool tidak ditemukan di PATH. Pastikan C:\tools\yt-dlp\ berisi $tool.exe dan sudah masuk PATH." -ForegroundColor Yellow
        }
    }
}

Clear-Host
Write-Host "=== yt-dlp Menu Downloader ===" -ForegroundColor Cyan

Ensure-Tools

# 1) URL
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
if (-not $url) { $url = Read-Host "Tempel link (YouTube/Instagram/Twitter/X)" }
if ([string]::IsNullOrWhiteSpace($url)) { Write-Host "URL kosong. Keluar."; exit 1 }

# 2) Mode
$modeChoice = Read-Choice "Pilih mode unduhan:" @("MP4 (video)","MP3 (audio saja)","Thumbnail saja")

# 3) Playlist handling
$playlistArg = @()
if (Is-YouTubePlaylist $url) {
    Write-Host "`nTerdeteksi parameter playlist YouTube (list=)." -ForegroundColor Yellow
    $plChoice = Read-Choice "Proses sebagai playlist?" @("Ya (semua item)","Tidak (video ini saja)")
    if ($plChoice -eq 1) { $playlistArg = @("--yes-playlist") } else { $playlistArg = @("--no-playlist") }
} else {
    $playlistArg = @("--no-playlist")
}

# 4) Opsi dasar
$dlArgs = @("--no-mtime","--embed-metadata","--merge-output-format","mp4","--windows-filenames","--no-restrict-filenames")
$dest = Join-Path $HOME "Downloads\ydl"
if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
$dlArgs += @("-P", $dest)

switch ($modeChoice) {
    1 {
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
        $dlArgs += @("-f",$fmt,"--embed-thumbnail")
        $subChoice = Read-Choice "Pilih bahasa subtitle untuk di-embed:" @("Indonesia","English","Japanese","No language")
        $dlArgs += (Build-SubtitleArgs $subChoice)
    }
    2 {
        $dlArgs += @("--extract-audio","--audio-format","mp3","--audio-quality","0","--embed-thumbnail","--add-metadata","--no-write-subs")
    }
    3 {
        $dlArgs += @("--skip-download","--write-thumbnail","--no-write-subs")
    }
}

# 5) Template output
$dlArgs += @("-o","%(title)s [%(uploader)s] [%(id)s].%(ext)s")

Write-Host "`n> Menjalankan yt-dlp dengan opsi berikut:" -ForegroundColor Cyan
$pretty = ($playlistArg + $dlArgs + @($url) | ForEach-Object { if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ } }) -join ' '
Write-Host ("yt-dlp " + $pretty)

& yt-dlp @playlistArg @dlArgs $url
$ec = $LASTEXITCODE
Write-Host "`nSelesai. ExitCode: $ec"
if ($ec -ne 0) { Write-Host "Ada error. Tambahkan --verbose untuk detail." -ForegroundColor Yellow }
