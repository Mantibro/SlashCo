These are all the original .wav files before they were converted to mono .mp3 files.

NOTE: slashco/music files were NOT converted to .mp3 as their quality change is noticable.

Powershell script using FFMPEG:
```
Get-ChildItem -Recurse -Filter *.wav | ForEach-Object {
	$output = Join-Path $_.Directory.FullName ($_.BaseName + ".mp3")
	ffmpeg -i $_.FullName -ac 1 -ar 44100 -b:a 320k -acodec libmp3lame $output
}
```