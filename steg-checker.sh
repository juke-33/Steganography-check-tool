#!/bin/bash

# install missing tools
install_tools() {
  local tools=("file" "binwalk" "steghide" "strings" "foremost" "exiftool" "zsteg" "outguess" "xxd" "pngcheck" "jpeginfo" "ffmpeg" "pdf-parser" "tar")
  for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      echo -e "\n[ \e[34mℹ\e[0m ] Installing $tool..."
      sudo apt-get install -y "$tool" || { echo -e "\n[ \e[31m✗\e[0m ] Failed to install $tool. Exiting."; exit 1; }
    fi
  done
}

clear

# Check for file argument
if [ -z "$1" ]; then
  echo -e "\n[ \e[34mℹ\e[0m ] Usage: $0 <file> [password]"
  exit 1
fi

FILE="$1"
PASSWORD="${2:-}"

# Check if file exists
if [ ! -f "$FILE" ]; then
  echo -e "\n[ \e[31m✗\e[0m ] File not found!"
  exit 1
fi

# Run tool check and install missing ones
echo "----------------------------------------------------"
echo -e "\n[ - ] Checking and installing necessary tools..."
install_tools
echo -e "\n[ \e[32m✔\e[0m ] All required tools are installed."
echo -e "\n----------------------------------------------------"

echo -e "\n[ - ] Running steganography checks on $FILE with password: '${PASSWORD}'"
echo -e "\n----------------------------------------------------"

# File Type Detection
FILE_TYPE=$(file --mime-type -b "$FILE")

# Common tools for all files
echo -e "\n[ 1 ] file\n"
file "$FILE"
echo -e "\n----------------------------------------------------"

echo -e "\n[ 2 ] exiftool\n"
exiftool "$FILE"
echo -e "\n----------------------------------------------------"

echo -e "\n[ 3 ] binwalk"
binwalk -e "$FILE"
echo -e "\n----------------------------------------------------"

# Image File (JPEG, PNG) specific commands
if [[ "$FILE_TYPE" == "image/jpeg" || "$FILE_TYPE" == "image/png" ]]; then
  echo -e "\n[ 4 ] zsteg\n"
  zsteg "$FILE"
  echo -e "\n----------------------------------------------------"

  if [[ "$FILE_TYPE" == "image/jpeg" ]]; then
    echo -e "\n[ 5 ] steghide\n"
    steghide extract -sf "$FILE" -p "$PASSWORD"
    echo -e "\n----------------------------------------------------"

    echo -e "\n[ 6 ] outguess\n"
    outguess -r "$FILE" output.txt
    if [ -f outguess_output.txt ]; then
      echo -e "\n[ \e[32m✔\e[0m ] Outguess output saved to 'output.txt'."
    else
      echo -e "\n[ \e[31m✗\e[0m ] Outguess failed to extract any data."
    fi
    echo -e "\n----------------------------------------------------"
  fi

  if [[ "$FILE_TYPE" == "image/png" ]]; then
    echo -e "\n[ 7 ] pngcheck\n"
    pngcheck -v "$FILE"
  elif [[ "$FILE_TYPE" == "image/jpeg" ]]; then
    echo -e "\n[ 7 ] jpeginfo\n"
    jpeginfo -c "$FILE"
  fi
  echo -e "\n----------------------------------------------------"
fi

# Audio File (WAV, MP3) specific commands
if [[ "$FILE_TYPE" == "audio/x-wav" || "$FILE_TYPE" == "audio/mpeg" ]]; then
  echo -e "\n[ 8 ] ffmpeg\n"
  ffmpeg -i "$FILE"
  echo -e "\n----------------------------------------------------"

  echo -e "\n[ 9 ] sox\n"
  sox "$FILE" -n stat
  echo -e "\n----------------------------------------------------"

  echo -e "\n[ 11 ] spectrogram\n"
  sox "$FILE" -n spectrogram -o spectrogram.png
  if [ -f spectrogram.png ]; then
    echo -e "\n[ \e[32m✔\e[0m ] Spectrogram image successfully exported."
  else
    echo -e "\n[ \e[31m✗\e[0m ] Failed to export spectrogram image."
  fi
  echo -e "\n----------------------------------------------------"
fi

# PDF or Document File specific commands
if [[ "$FILE_TYPE" == "application/pdf" ]]; then
  echo -e "\n[ 11 ] pdfinfo\n"
  pdfinfo "$FILE"
  echo -e "\n----------------------------------------------------"

  echo -e "\n[ 12 ] pdf-parser\n"
  pdf-parser -s 10 "$FILE" | head -n 40
  echo -e "\n----------------------------------------------------"
fi

# Compressed File (ZIP, RAR) specific commands
if [[ "$FILE_TYPE" == "application/zip" || "$FILE_TYPE" == "application/x-rar-compressed" ]]; then
  echo -e "\n[ 14 ] unzip\n"
  unzip "$FILE" -l
  echo -e "\n----------------------------------------------------"

  echo -e "\n[ 15 ] 7z\n"
  7z l "$FILE"
  echo -e "\n----------------------------------------------------"

  echo -e "\n[ 16 ] tar\n"
  tar -tvf "$FILE"
  echo -e "\n----------------------------------------------------"
fi

# General checks
echo -e "\n[ 17 ] strings\n"
strings "$FILE" | head -n 20
echo -e "\n----------------------------------------------------"

echo -e "\n[ 18 ] xxd\n"
xxd "$FILE" | head -n 20
echo -e "\n----------------------------------------------------"

echo -e "\n[ \e[32m✔\e[0m ] Steganography scan completed."
