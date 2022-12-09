#!/usr/bin/env bash

set -e


if [ -z "$1" ]; then
    echo 'Warning: Petalinux output folder path is not set, use default $PWD/images/linux'
    PATH2IMAGE=$PWD/images/linux
else
    PATH2IMAGE=$1
fi


if [ "$EUID" -ne 0 ]
  then echo "ERROR: Please run as root all over sudo"
  exit
fi

TEMP_PATH="/tmp/sdimage"
# Input params.
partition_file_1=$TEMP_PATH/part1.vfat
partition_file_2=$TEMP_PATH/part2.ext4
partition_size_1_megs=128
partition_size_2_megs=2048
img_file=$PATH2IMAGE/sdimage.img
block_size=512

rm -f $img_file
# Calculated params.
mega="$(echo '2^20' | bc)"
partition_size_1=$(($partition_size_1_megs * $mega))
partition_size_2=$(($partition_size_2_megs * $mega))

# Create a test directory to convert to ext2.
mkdir -p "$TEMP_PATH/rootfs"
sudo tar -zxvf $PATH2IMAGE/rootfs.tar.gz -C $TEMP_PATH/rootfs
# Create the 2 raw ext2 images.
rm -f "$partition_file_1"
mkfs.vfat \
  -F 32 \
  -n "BOOT" \
  "$partition_file_1" \
  -C $((${partition_size_1_megs}*$mega/$block_size)) \
;
mcopy -i $partition_file_1  $PATH2IMAGE/BOOT.BIN ::BOOT.BIN
mcopy -i $partition_file_1  $PATH2IMAGE/boot.scr ::boot.scr
mcopy -i $partition_file_1  $PATH2IMAGE/image.ub ::image.ub

rm -f "$partition_file_2"
mke2fs \
  -d "$TEMP_PATH/rootfs" \
  -t ext4 \
  -r 1 \
  -N 0 \
  -m 5 \
  -L 'rootfs' \
  -O ^64bit \
  "$partition_file_2" \
  "${partition_size_2_megs}M" \
;

# Default offset according to
part_table_offset=$((2**20))
cur_offset=0
bs=1024
dd if=/dev/zero of="$img_file" bs="$bs" count=$((($part_table_offset + $partition_size_1 + $partition_size_2)/$bs)) skip="$(($cur_offset/$bs))"
printf "
type=c, size=$(($partition_size_1/$block_size))
type=83, size=$(($partition_size_2/$block_size))
" | sfdisk "$img_file"

cur_offset=$(($cur_offset + $part_table_offset))
# TODO: can we prevent this and use mke2fs directly on the image at an offset?
# Tried -E offset= but could not get it to work.
dd if="$partition_file_1" of="$img_file" bs="$bs" seek="$(($cur_offset/$bs))"
cur_offset=$(($cur_offset + $partition_size_1))
rm "$partition_file_1"
dd if="$partition_file_2" of="$img_file" bs="$bs" seek="$(($cur_offset/$bs))"
cur_offset=$(($cur_offset + $partition_size_2))
rm "$partition_file_2"
