# Steganography Checker

A shell script for detecting steganography in various file types such as images (JPEG, PNG), audio (WAV, MP3), PDFs, and archive files. This tool utilizes multiple forensic tools to scan files for hidden data and potential steganography.

## Features
- Detect hidden messages in **image files** (JPEG, PNG).
- Analyze **audio files** (WAV, MP3) for hidden data.
- Inspect **PDF files** for potential embedded objects.
- Check **compressed archive files** (ZIP, RAR) for hidden files.
- Runs various forensic and steganography detection tools including `binwalk`, `steghide`, `exiftool`, and more.

## Requirements
This script depends on the following tools, which are automatically installed if missing:
- `file`
- `binwalk`
- `steghide`
- `strings`
- `foremost`
- `exiftool`
- `zsteg`
- `outguess`
- `xxd`
- `pngcheck`
- `jpeginfo`
- `ffmpeg`
- `sox`
- `pdf-parser`
- `tar`

Ensure you have `sudo` access on the system for tool installation.

## Usage

Run the script with the following command:
```bash
./steg-checker.sh <file> [password]
