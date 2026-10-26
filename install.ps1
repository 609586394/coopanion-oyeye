<#
.SYNOPSIS
  Coopanion party patch — 「欧耶耶」 plays a song and squashes the pet on the beat.

.DESCRIPTION
  Patches the desktop-pet World shipped with Coopanion:
    * typing 「欧耶耶」 (or 「哦耶耶」/「欧耶」) plays web/party/friends-wine.mp3 and
      squashes the figure on every beat of the song;
    * typing 「停停」 (or 「别唱了」) stops it; the song also stops when it ends.
  The song is copyrighted, so it is NOT shipped with this repository. Pass -Audio
  with your own mp3, or -SongUrl to fetch it with yt-dlp. Without either, the
  animation still works and the pet stays silent.

  Every change is backed up to <Coopanion>\backup-party; -Uninstall restores it.
  Re-running is safe: a file that already carries the patch is left alone.

.PARAMETER Root
  The Coopanion folder (the one containing Coopanion.exe). Found automatically
  from the running process and the usual install paths when omitted.

.PARAMETER Audio
  Path to an mp3 to install as the song.

.PARAMETER SongUrl
  A page URL (Bilibili, YouTube, …) to extract the song from with yt-dlp.

.PARAMETER Restart
  Restart Coopanion after patching (and after restoring on -Uninstall).

.PARAMETER Uninstall
  Restore the three files backed up by an earlier run and remove the patch.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File install.ps1 -Restart

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File install.ps1 -Audio D:\music\friends-wine.mp3 -Restart
#>
[CmdletBinding()]
param(
  [string]$Root,
  [string]$Audio,
  [string]$SongUrl,
  [switch]$Restart,
  [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

function Info($m) { Write-Host "[*] $m" }
function Ok($m) { Write-Host "[ok] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[!] $m" -ForegroundColor Yellow }
function Fail($m) { Write-Host "[x] $m" -ForegroundColor Red; exit 1 }

function Find-Root {
  if ($Root) {
    if (-not (Test-Path $Root)) { Fail "找不到目录：$Root" }
    return (Resolve-Path $Root).Path
  }
  $cands = @()
  try {
    $p = Get-Process Coopanion -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($p -and $p.Path) { $cands += (Split-Path $p.Path) }
  } catch { }
  $cands += @(
    (Join-Path $env:LOCALAPPDATA 'Programs\Coopanion'),
    (Join-Path $env:USERPROFILE 'Coopanion'),
    'D:\Coopanion',
    'C:\Coopanion'
  )
  foreach ($c in $cands) {
    if (-not $c) { continue }
    if (Test-Path (Join-Path $c 'resources\app\app\main.cjs')) { return $c }
  }
  return $null
}

function Read-Text($p) { [System.IO.File]::ReadAllText($p) }
function Write-Text($p, $t) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($p, $t, $enc)
}

# Replace the one occurrence of $old with $new. $marker is looked for first so a
# patched file is reported instead of patched twice.
function Patch-File($path, $old, $new, $marker, $label) {
  $t = Read-Text $path
  if ($t.Contains($marker)) { Ok "$label — 已经是打好的状态"; return }
  $i = $t.IndexOf($old)
  if ($i -lt 0) { Fail "$label — 锚点不匹配，这个版本可能改过这段代码：$path" }
  $t = $t.Substring(0, $i) + $new + $t.Substring($i + $old.Length)
  Write-Text $path $t
  Ok "$label — 已打补丁"
}

function Restore-Backup($backup) {
  if (-not (Test-Path $backup)) { Warn "没有备份可还原：$backup"; return }
  $pairs = @(
    @{ src = 'main.cjs'; dst = 'resources\app\app\main.cjs' },
    @{ src = 'pet-app.js'; dst = 'resources\app\node_modules\cortico-world-desktop-pet\web\pet-app.js' },
    @{ src = 'pet.css'; dst = 'resources\app\node_modules\cortico-world-desktop-pet\web\pet.css' }
  )
  foreach ($p in $pairs) {
    $from = Join-Path $backup $p.src
    if (-not (Test-Path $from)) { continue }
    Copy-Item $from (Join-Path $root $p.dst) -Force
    Ok "已还原 $($p.dst)"
  }
}

$root = Find-Root
if (-not $root) {
  Fail '没找到 Coopanion。装过的话用 -Root 指定（例如 -Root "D:\Coopanion"）。'
}
Ok "Coopanion：$root"

$main = Join-Path $root 'resources\app\app\main.cjs'
$world = Join-Path $root 'resources\app\node_modules\cortico-world-desktop-pet'
$app = Join-Path $world 'web\pet-app.js'
$css = Join-Path $world 'web\pet.css'
$backup = Join-Path $root 'backup-party'

foreach ($f in @($main, $app, $css)) {
  if (-not (Test-Path $f)) { Fail "缺少文件（版本不支持？）：$f" }
}

if ($Uninstall) {
  Restore-Backup $backup
  if ($Restart) {
    Get-Process Coopanion -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 3
    Remove-Item Env:ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
    Start-Process (Join-Path $root 'Coopanion.exe') -WorkingDirectory $root
    Ok '已重启 Coopanion'
  }
  Ok '卸载完成'
  exit 0
}

# ---- backup once, before the first change -------------------------------------
if (-not (Test-Path $backup)) {
  New-Item -ItemType Directory -Force -Path $backup | Out-Null
  Copy-Item $main (Join-Path $backup 'main.cjs') -Force
  Copy-Item $app (Join-Path $backup 'pet-app.js') -Force
  Copy-Item $css (Join-Path $backup 'pet.css') -Force
  Ok "原文件已备份到 $backup"
} else {
  Info "备份已存在：$backup"
}

# ---- 1) autoplay: the message comes from another window, so the pet page has no
#         gesture of its own to unlock audio with ------------------------------
$oldMain = "app.commandLine.appendSwitch('enable-unsafe-swiftshader');"
$newMain = @'
app.commandLine.appendSwitch('enable-unsafe-swiftshader');
// The pet plays a song when the person sends 「欧耶耶」; that message comes from
// another window, so the page has no gesture of its own to unlock audio with.
app.commandLine.appendSwitch('autoplay-policy', 'no-user-gesture-required');
'@
Patch-File $main $oldMain $newMain "autoplay-policy" '开启音频自动播放'

# ---- 2) the party itself (audio + beat-synced squash) -----------------------
$partyBlock = @'
/** 「欧耶耶」plays 朋友的酒 and jellies the body; 「停停」stops it. */
const PARTY_SONG = '/web/party/friends-wine.mp3';
const PARTY_START_WORDS = ['欧耶耶', '哦耶耶', '欧耶'];
const PARTY_STOP_WORDS = ['停停', '别唱了'];
let partyAudio = null;
function partyLayer() { return document.getElementById('figureLayer'); }
/** 朋友的酒 DJ: measured at 129.2 BPM, one beat ≈ 0.4644 s. */
const PARTY_BEAT = 60 / 129.2;
/** One beat of squash as a damped wave: no segment edges, so the beat flows instead of snapping. */
function partyScaleY(p) {
  return 1 - .567 * Math.exp(-3 * p) * Math.sin(2 * Math.PI * p);
}
/** The song's lines, shown in the speech bubble while it plays (the pet does not sing). */
let lyricRows = null, lyricNow = '';
async function loadLyrics() {
  if (lyricRows) return;
  try { lyricRows = await (await fetch('/web/party/lyrics.json')).json(); } catch { lyricRows = []; }
}
function lyricAt(t) {
  if (!lyricRows?.length) return null;
  let lo = 0, hi = lyricRows.length - 1, found = -1;
  while (lo <= hi) { const mid = (lo + hi) >> 1; if (lyricRows[mid].t <= t) { found = mid; lo = mid + 1; } else hi = mid - 1; }
  return found >= 0 ? lyricRows[found] : null;
}
function showLyric(text) {
  if (!text || text === lyricNow) return;
  lyricNow = text;
  bubble.className = 'bubble say';
  bubble.dataset.lyric = '1';
  bubble.innerHTML = '<p class="b-text"></p>';
  bubble.querySelector('.b-text').textContent = text;
  bubble.hidden = false;
  void bubble.offsetWidth;
  bubble.classList.add('pop');
}
function clearLyric() {
  if (bubble.dataset.lyric !== '1') { lyricNow = ''; return; }
  bubble.hidden = true;
  bubble.innerHTML = '';
  delete bubble.dataset.lyric;
  lyricNow = '';
}
let partyRaf = 0, partySy = 1, partyLast = 0;
function partyStep(now) {
  partyRaf = 0;
  const layer = partyLayer();
  if (!partyAudio || partyAudio.paused || !layer) { partyLast = 0; return; }
  const dt = partyLast ? Math.min(.05, (now - partyLast) / 1000) : .016;
  partyLast = now;
  const p = (partyAudio.currentTime / PARTY_BEAT) % 1;
  const target = partyScaleY(p);
  // follow the curve with a little inertia so the beat does not snap
  partySy += (target - partySy) * Math.min(1, dt * 26);
  const sy = partySy, sx = 1 / Math.sqrt(sy);
  const l = at();
  if (l) layer.style.transformOrigin = `${l.x}px 100%`;
  layer.style.transform = `scale(${sx.toFixed(4)}, ${sy.toFixed(4)})`;
  const row = lyricAt(partyAudio.currentTime);
  if (row) showLyric(row.text);
  partyRaf = requestAnimationFrame(partyStep);
}
function startPartyRaf() { if (!partyRaf) partyRaf = requestAnimationFrame(partyStep); }
function startParty() {
  if (!partyAudio) {
    partyAudio = new Audio(PARTY_SONG);
    partyAudio.volume = .85;
    partyAudio.addEventListener('ended', stopParty);
    partyAudio.addEventListener('playing', startPartyRaf);
  }
  try { partyAudio.currentTime = 0; } catch (e) { /* not loaded yet */ }
  partySy = 1; partyLast = 0; lyricNow = '';
  loadLyrics();
  partyAudio.play().catch(() => {});
  partyLayer()?.classList.add('party');
  startPartyRaf();
}
function stopParty() {
  if (partyAudio) {
    partyAudio.pause();
    try { partyAudio.currentTime = 0; } catch (e) { /* ignore */ }
  }
  if (partyRaf) { cancelAnimationFrame(partyRaf); partyRaf = 0; }
  partySy = 1; partyLast = 0;
  const layer = partyLayer();
  layer?.classList.remove('party');
  layer?.style.removeProperty('transform');
  layer?.style.removeProperty('transform-origin');
  clearLyric();
}
function partyCheck(text) {
  if (typeof text !== 'string' || text === '') return;
  if (PARTY_STOP_WORDS.some((w) => text.includes(w))) { stopParty(); return; }
  if (PARTY_START_WORDS.some((w) => text.includes(w))) startParty();
}

'@
Patch-File $app 'function addLine(src, text, live = false, extra = {}) {' ($partyBlock + 'function addLine(src, text, live = false, extra = {}) {') 'PARTY_SONG' '加入触发与播放逻辑'

Patch-File $app "    case 'said': if (prefs.saidBubbles) addLine('chat'," "    case 'said': partyCheck(typeof m.text === 'string' ? m.text : ''); if (prefs.saidBubbles) addLine('chat'," 'partyCheck(typeof m.text' '对话页消息触发'

Patch-File $app "    if (prefs.saidBubbles) addLine('type', v);" "    partyCheck(v);`r`n    if (prefs.saidBubbles) addLine('type', v);" 'partyCheck(v);' '气泡输入触发'

Patch-File $app 'function settleLine(line, text) {' "function settleLine(line, text) {`r`n  partyCheck(text);" 'partyCheck(text);' '语音输入触发'

# ---- 3) the squash style ----------------------------------------------------
$partyCss = @'

/* party: 「欧耶耶」—— the beat drives the squash from pet-app.js (129.2 BPM) */
.figure-layer.party{transform-origin:50% 100%; will-change:transform}
'@
$cssText = Read-Text $css
if ($cssText.Contains('figure-layer.party')) {
  Ok '动画样式 — 已经存在'
} else {
  Write-Text $css ($cssText + $partyCss)
  Ok '动画样式 — 已追加'
}

# ---- 4) the song: -Audio, -SongUrl, the repo's assets, or the bundled URL ---
$partyDir = Join-Path $world 'web\party'
New-Item -ItemType Directory -Force -Path $partyDir | Out-Null
$song = Join-Path $partyDir 'friends-wine.mp3'
$BundledAudio = 'https://raw.githubusercontent.com/609586394/coopanion-oyeye/main/assets/friends-wine.mp3'

if ($Audio) {
  if (-not (Test-Path $Audio)) { Fail "找不到音频：$Audio" }
  Copy-Item $Audio $song -Force
  Ok "音频已安装：$Audio"
} elseif ($SongUrl) {
  $py = Get-Command python -ErrorAction SilentlyContinue
  if (-not $py) { Fail '用 -SongUrl 需要 python + yt-dlp（pip install yt-dlp）' }
  $ff = Get-Command ffmpeg -ErrorAction SilentlyContinue
  $args = @('-m', 'yt_dlp', '--no-playlist', '-f', 'bestaudio/best', '-x', '--audio-format', 'mp3', '--audio-quality', '0')
  if ($ff) { $args += @('--ffmpeg-location', (Split-Path $ff.Source)) }
  $args += @('-o', ($song + '.tmp.%(ext)s'), $SongUrl)
  & $py.Source @args
  if ($LASTEXITCODE -ne 0) { Fail '下载失败，检查链接或手动用 -Audio 指定 mp3' }
  Move-Item ($song + '.tmp.mp3') $song -Force
  Ok '音频已下载'
} elseif (-not (Test-Path $song)) {
  $local = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'assets\friends-wine.mp3' } else { '' }
  if ($local -and (Test-Path $local)) {
    Copy-Item $local $song -Force
    Ok '音频已从仓库复制'
  } else {
    Info '下载内置音频：《朋友的酒》DJ 完整版（B 站 BV1hXbN6VEKV，UP 主：活跃黑江乐）…'
    try {
      Invoke-WebRequest $BundledAudio -OutFile $song -UseBasicParsing -TimeoutSec 300
      Ok '音频已下载'
    } catch {
      Warn '音频下载失败：动画能用但不会出声。用 -Audio <mp3> 提供。'
    }
  }
}

# the lyrics the bubble shows while it plays: from the video's burned-in subtitles
$lyrics = Join-Path $partyDir 'lyrics.json'
if (-not (Test-Path $lyrics)) {
  $localLyrics = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'assets\lyrics.json' } else { '' }
  if ($localLyrics -and (Test-Path $localLyrics)) {
    Copy-Item $localLyrics $lyrics -Force
    Ok '歌词已从仓库复制'
  } else {
    try {
      Invoke-WebRequest 'https://raw.githubusercontent.com/609586394/coopanion-oyeye/main/assets/lyrics.json' -OutFile $lyrics -UseBasicParsing -TimeoutSec 60
      Ok '歌词已下载'
    } catch {
      Warn '歌词下载失败：歌照放，只是没有歌词'
    }
  }
}

# ---- 5) syntax check --------------------------------------------------------
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
  $tmp = Join-Path $env:TEMP ('coopanion-party-check-' + [guid]::NewGuid().ToString('N') + '.mjs')
  Copy-Item $app $tmp -Force
  & $node.Source --check $tmp 2>&1 | Out-Null
  $code = $LASTEXITCODE
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  if ($code -ne 0) { Fail 'JS 语法检查失败，已保留备份，可用 -Uninstall 还原' }
  Ok 'JS 语法检查通过'
} else {
  Warn '没有 node，跳过语法检查'
}

# ---- 6) restart -------------------------------------------------------------
if ($Restart) {
  Get-Process Coopanion -ErrorAction SilentlyContinue | Stop-Process -Force
  Start-Sleep -Seconds 3
  Remove-Item Env:ELECTRON_RUN_AS_NODE -ErrorAction SilentlyContinue
  Start-Process (Join-Path $root 'Coopanion.exe') -WorkingDirectory $root
  Ok '已重启 Coopanion'
}

Write-Host ''
Ok '完成。对它说「欧耶耶」，说「停停」停下。'
