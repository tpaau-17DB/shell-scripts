<h1 align="center">
m3uexp
</h1>

This script is designed to make exporting `cmus` playlists to M3U format
easy. It is capable of exporting the entire `cmus` library, **including the
audio files**. It can also be used to create an M3U playlist from a list of
paths.

### Examples
Create an M3U playlist from a list of paths provided in `stdin`:
```
ls /path/to/dir | m3uexp create
```

Export all the `cmus` playlists with the audio files:
```
m3uexp export cmus:all
```
This will create a `.tar.gz` archive in the current directory.
