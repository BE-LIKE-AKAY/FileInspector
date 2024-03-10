#!/bin/bash

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ $# -ne 1 ]; then
    echo -e "${RED}Usage: $0 <filename>${NC}"
    exit 1
fi

filename=$1

if [ ! -e "$filename" ]; then
    echo -e "${RED}File $filename not found${NC}"
    exit 1
fi

echo -e "${CYAN}Metadata for file: $filename${NC}"
echo -e "${CYAN}-----------------------------${NC}"

# Check file type and extract metadata accordingly
file_type=$(file -b "$filename")

case "$file_type" in
    *"image"*)
        echo -e "${BLUE}File type: Image${NC}"
        exiftool "$filename"
        exif_output=$(exiftool "$filename")
        echo "$exif_output"
        geo_location=$(echo "$exif_output" | grep -i "GPS Position")
        if [ -n "$geo_location" ]; then
            echo -e "${YELLOW}Geo-location:${NC} $geo_location"
        else
            echo -e "${YELLOW}Geo-location:${NC} Not available"
        fi
        ;;
    *"audio"*)
        echo -e "${BLUE}File type: Audio${NC}"
        exiftool "$filename"
        ;;
    *"video"*)
        echo -e "${BLUE}File type: Video${NC}"
        ffprobe -hide_banner -show_format -show_streams "$filename"
        ;;
    *)
        echo -e "${BLUE}File type: $file_type${NC}"
        echo -e "${YELLOW}Basic metadata:${NC}"
        stat -c "${GREEN}Size: %s bytes\n${NC}${GREEN}Owner: %U\n${NC}${GREEN}Group: %G\n${NC}${GREEN}Permissions: %a\n${NC}${GREEN}Last access time: %x\n${NC}${GREEN}Last modification time: %y\n${NC}${GREEN}Last status change time: %z${NC}" "$filename"
        ;;
esac
