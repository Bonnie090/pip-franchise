# Builds the Episode 1 animatic video from the storyboard frames.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File build-animatic.ps1
# Frames that do not exist yet are drawn as labeled placeholder cards, so the video always runs the full script length.
# Re-run after adding frames to Visuals\Episode 1 animatic\.

$ErrorActionPreference = "Stop"
$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$frames = Join-Path (Split-Path -Parent $root) "Visuals\Episode 1 animatic"
$work   = Join-Path $root "work"
New-Item -ItemType Directory -Force $work | Out-Null

$ff = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if (-not $ff) { throw "ffmpeg not found. Install with: winget install Gyan.FFmpeg" }

# start, end (seconds, from the script timing), frame file or $null, placeholder description
$segs = @(
 @(0,   8,   "Frame 01 - Sunny over Daisy Dell.png", ""),
 @(8,   15,  "Frame 02 - Pip bursts out the door.png", ""),
 @(15,  26,  "Frame 03 - Mama and Dot at the door v2.png", ""),
 @(26,  31,  "Frame 04 - title card.png", ""),
 @(31,  42,  "Frame 05 - Papa at the park gate.png", ""),
 @(42,  51,  "Frame 06 - the race.png", ""),
 @(51,  60,  "Frame 07 - the puddle splash.png", ""),
 @(60,  72,  "Frame 08 - Skye spots something.png", ""),
 @(72,  84,  "Frame 09 - the strange egg.png", ""),
 @(84,  96,  "Frame 10 - the puff-up.png", ""),
 @(96,  106, "Frame 11 - Tuck, it's an egg.png", ""),
 @(106, 135, "Frame 12 - Pip's plan face.png", ""),
 @(135, 152, "Frame 13 - Plan Vision steps 1 to 3 v2.png", ""),
 @(152, 170, "Frame 14 - Plan Vision step 5, no step 4 v2.png", ""),
 @(170, 182, "Frame 15 - Tuck, what about step four.png", ""),
 @(182, 190, "Frame 16 - Skye and the feather.png", ""),
 @(190, 205, "Frame 17 - egg in the scarf on the wagon.png", ""),
 @(205, 220, "Frame 18 - the runaway wagon.png", ""),
 @(220, 235, "Frame 19 - Poppy curls up.png", ""),
 @(235, 255, "Frame 20 - FWUMP into the leaves.png", "Frame 20: FWUMP! The wagon plows into a pile of leaves and the egg bounces back onto the scarf."),
 @(255, 285, "Frame 21 - the ducks, not ours.png", ""),
 @(285, 310, $null, "Frame 22: The droop. Pip's ears fold back and his tail drops to the ground."),
 @(310, 335, $null, "Frame 23: The perk back up. Skye shows the feather; Pip's ears lift one at a time."),
 @(335, 355, $null, "Frame 24: Back to the green dot. A trail of feathers leads away like a dotted line."),
 @(355, 375, $null, "Frame 25: Skye flutters up higher than ever: 'I can see it from up here!'"),
 @(375, 393, $null, "Frame 26: Mrs. Honkaby finds her egg, and the gosling hatches."),
 @(393, 405, $null, "Frame 27: Everyone cheers: Pip-pip-HOORAY!"),
 @(405, 420, $null, "Frame 28: The tag. Pip adds step four to the Plan Wall: LISTEN to Skye.")
)

# start, end, caption text
$caps = @(
 @(0.5, 7.5,   "[Sunny the Sun yawns over Daisy Dell]"),
 @(9,   14.5,  "PIP: Park day! Park day! PARK DAAAY!"),
 @(15.5, 20.5, "MAMA: Stay with your friends, and stay where Papa can see you."),
 @(20.5, 24,   "PIP: I will! I'm five-and-a-little-bit!"),
 @(24,   26,   "DOT: Pip! Plan!"),
 @(26,   31,   "[MAIN TITLE]  Pip Has a Plan!"),
 @(32,   38,   "PAPA: Morning, park patrol! I'll be right here at the mailbox."),
 @(43,   46,   "POPPY: Race you to the willow tree!"),
 @(46,   48,   "PIP: You're ON!"),
 @(48,   51,   "TUCK: Park rule number one: no running near the... puddles."),
 @(52,   55,   "POPPY: Ha! Winner!"),
 @(55,   60,   "PIP: I was going for wettest. I won that one!"),
 @(61,   68,   "SKYE: Um... everyone? There's something under the bush."),
 @(73,   78,   "PIP: Whoa. It's... it's... what IS it?"),
 @(78,   84,   "POPPY: It's a ball! A giant spotty ball! I'm gonna kick it!"),
 @(84.5, 89,   "TUCK: Don't kick it! We don't know what it is!"),
 @(91,   96,   "PIP: I'm not scared!"),
 @(97,   103,  "TUCK: It's an EGG. A great big egg. Eggs need to stay warm, with their mama."),
 @(103,  106,  "SKYE: But where's its mama?"),
 @(106.5, 114, "PIP: Ooh! I have a PLAN! The Super-Speedy Get-the-Egg-Home Plan!"),
 @(114,  118,  "POPPY: Ooh, super-speedy. I like it already."),
 @(118,  135,  "PIP: Eggs live in nests. Nests are near water. So this egg lives at Circle Pond!"),
 @(135.5, 141, "PIP (V.O.): Step ONE: Pip finds a wagon!"),
 @(141,  147,  "Step TWO: Pip lifts the egg, super gently, onto his cozy scarf!"),
 @(147,  152,  "Step THREE: Pip rolls it to Circle Pond, ZOOM!"),
 @(153,  170,  "PIP (V.O.): Step FIVE: the egg is HOME! And the crowd goes WILD!"),
 @(170.5, 175, "TUCK: Um, Pip? What about step four?"),
 @(175,  178,  "PIP: There IS no step four!"),
 @(178,  182,  "TUCK: ...That's what I mean."),
 @(182.5, 186.5, "SKYE: Pip, I saw something next to the egg, it was a--"),
 @(186.5, 190, "PIP: STEP ONE! Found a wagon!"),
 @(190.5, 196, "PIP: There. Nice and cozy."),
 @(196,  205,  "PIP: STEP THREE! Roll it to Circle Pond! Super-speedy!"),
 @(205,  207.5, "PIP: Uh-oh."),
 @(207.5, 210, "EVERYONE: UH-OHHH!"),
 @(210,  220,  "PIP: And the wagon is getting away, folks! This is NOT part of the plan!"),
 @(220.5, 228, "TUCK: Poppy, NO! Spiky plus egg equals BAD!"),
 @(228,  235,  "POPPY: Oops! Right! Not spiky! Not spiky!"),
 @(236,  242,  "[FWUMP!]"),
 @(242,  246,  "PIP: Okay... Plan B."),
 @(246,  250,  "TUCK: Plan B is: we walk. Slowly."),
 @(250,  255,  "PIP: ...Plan B is: we walk slowly."),
 @(255.5, 262, "PIP: Step FIVE! Ta-da! We found your egg!"),
 @(262,  268,  "DUCK: Oh, sweetie, that's not ours."),
 @(268,  278,  "DUCK: Our eggs are THIS big. That egg is... THAT big."),
 @(278,  285,  "[tap... tap...]"),
 @(286,  298,  "PIP: I just wanted to help it get home. And now it's even farther away."),
 @(310.5, 325, "SKYE: Pip? I tried to tell you before. I found THIS. It's a feather. A really big one."),
 @(325,  334,  "PIP: Skye. You were trying to tell me the most important step. I'm sorry."),
 @(335.5, 341, "PIP: Step four: find out WHOSE egg it is! We have to go back to where we started."),
 @(341,  345,  "TUCK: Back to the green dot."),
 @(345,  354,  "PIP: It's a dotted path! A feather path!"),
 @(355.5, 370, "SKYE: I can see it from up here! There's a big nest, and a big white goose!"),
 @(375.5, 382, "MRS. HONKABY: My egg! Oh, my baby egg!"),
 @(382,  389,  "PIP: Wait for it... wait for it..."),
 @(390,  393,  "GOSLING: Peep!"),
 @(393.5, 397, "PIP: He said my NAME!"),
 @(397,  401,  "TUCK: Did you know baby geese say peep?"),
 @(401,  405,  "EVERYONE: Pip-pip-HOORAY!"),
 @(405.5, 412, "PIP: Step four... LISTEN to Skye."),
 @(412,  419,  "PIP: See you tomorrow, little buddy!")
)

# ---- placeholder cards for frames not made yet ----
Add-Type -AssemblyName System.Drawing
function New-Placeholder($text, $path) {
  $bmp = New-Object System.Drawing.Bitmap 2000, 1125
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAlias'
  $g.Clear([System.Drawing.ColorTranslator]::FromHtml("#FFF3DE"))
  $brown = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml("#4A2410"))
  $orange = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml("#E8641B"))
  $green = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml("#6CC24A"))
  $g.FillEllipse($green, 120, 500, 80, 80)
  $pen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml("#9A8A78")), 8
  $pen.DashStyle = 'Dash'
  $g.DrawLine($pen, 230, 540, 1850, 540)
  $f1 = New-Object System.Drawing.Font "Segoe UI", 44, ([System.Drawing.FontStyle]::Bold)
  $f2 = New-Object System.Drawing.Font "Segoe UI", 40
  $g.DrawString("STORYBOARD FRAME STILL TO COME", $f1, $orange, 120, 250)
  $rect = New-Object System.Drawing.RectangleF 120, 620, 1760, 380
  $g.DrawString($text, $f2, $brown, $rect)
  $g.Dispose(); $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}

# ---- one clip per frame, with a slow pan/zoom ----
$fps = 25; $i = 0; $list = @()
foreach ($s in $segs) {
  $i++
  $dur = $s[1] - $s[0]; $n = [int]($dur * $fps)
  $img = $null
  if ($s[2]) { $cand = Join-Path $frames $s[2]; if (Test-Path $cand) { $img = $cand } }
  if (-not $img) { $img = Join-Path $work ("placeholder{0:00}.png" -f $i); New-Placeholder $s[3] $img }
  $inc = [math]::Round(0.09 / $n, 7)
  switch ($i % 3) {
    0 { $z = "z='1.0+on*$inc':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" }
    1 { $z = "z='1.09-on*$inc':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'" }
    2 { $z = "z='1.06':x='(iw-iw/zoom)*on/$n':y='ih/2-(ih/zoom/2)'" }
  }
  $seg = Join-Path $work ("seg{0:00}.mp4" -f $i)
  $vf = "scale=2000:-2,zoompan=$z" + ":d=$n" + ":s=1280x720:fps=$fps,format=yuv420p"
  & $ff -y -loglevel error -i $img -vf $vf -frames:v $n -c:v libx264 -preset veryfast -crf 20 $seg
  if ($LASTEXITCODE -ne 0) { throw "segment $i failed" }
  $list += "file 'seg{0:00}.mp4'" -f $i
}
Set-Content -Path (Join-Path $work "list.txt") -Value $list -Encoding ASCII

# ---- captions ----
function T($t) { $ms = [int][math]::Round($t * 1000); "{0:00}:{1:00}:{2:00},{3:000}" -f [math]::Floor($ms/3600000), ([math]::Floor($ms/60000) % 60), ([math]::Floor($ms/1000) % 60), ($ms % 1000) }
$srt = ""; $k = 0
foreach ($c in $caps) { $k++; $srt += "$k`r`n$(T $c[0]) --> $(T $c[1])`r`n$($c[2])`r`n`r`n" }
[IO.File]::WriteAllText((Join-Path $root "captions.srt"), $srt, (New-Object Text.UTF8Encoding($false)))

# ---- final video with burned-in captions ----
$out = "Pip Has a Plan - Episode 1 animatic.mp4"
Push-Location $root
$style = "FontName=Segoe UI,FontSize=11,Bold=1,Outline=2,Shadow=0,MarginV=22,Alignment=2"
& $ff -y -loglevel error -f concat -safe 0 -i "work/list.txt" -vf "subtitles=captions.srt:force_style='$style'" -c:v libx264 -preset medium -crf 27 -pix_fmt yuv420p -movflags +faststart -an $out
$ok = $LASTEXITCODE
Pop-Location
if ($ok -ne 0) { throw "final encode failed" }
"Built: " + (Join-Path $root $out) + "  (" + [math]::Round((Get-Item (Join-Path $root $out)).Length / 1MB, 1) + " MB)"
