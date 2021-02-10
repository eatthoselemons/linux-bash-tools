#!/bin/bash
trap_msg='s=${?}; echo "${0}: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}'
set -uo pipefail
trap "${trap_msg}" ERR

# Install dependencies for creating filesystem and installing bootloader
## This script is mostly system-independent, except for this part. Replace yaourt and the args with your own package manager

sudo pacman -S --noconfirm mlocate dosfstools mtools syslinux

# Plug in the flash drive, and find its device. Don't mount it.
lsblk
read -p 'Which device (e.g. /dev/sdf)? ' FLASHDEV






# Get the mount point for future use
read -p 'Where to mount (e.g. /media/flash)? ' FLASHMOUNT

echo $FLASHDEV

# Write zeros to the flash drive
#echo '[!] Writing zeros...'
#dd if=/dev/zero of=$FLASHDEV status=progress

# Write the partition table
## http://xmodulo.com/how-to-run-fdisk-in-non-interactive-batch-mode.html
echo '[!] Writing partition table...'
echo $FLASHDEV
sed -e 's/\s*\([\+0-9a-zA-z]*\).*/\1/' << EOF | fdisk $FLASHDEV
  d # delete partition
    # confirm
  d # delete parition (maybe if there is another one)
    # confirm
  p # print parition table
  n # new parition
    # default partition number 1
    # default beginning of disk
    # defualt, extend parition to end of disk
  a # toggle bootable flag for dos
  t # change parition type
  6 # set partition type to FAT16
  w # write parition table
EOF

# Make FAT16 file system
echo '[!] Making filesystem...'
lsblk
mkfs.fat ${FLASHDEV}1

# Write syslinux to flash
echo '[!] Writing syslinux...'
syslinux ${FLASHDEV}1

# Create mount point, mount!
mkdir -p $FLASHMOUNT
mount ${FLASHDEV}1 $FLASHMOUNT
mount -l | grep -i ${FLASHDEV}

# Download memtest86+ bootable binary
echo '[!] Downloading Memtest86+ and copying...'
wget http://www.memtest.org/download/5.01/memtest86+-5.01.bin.gz
gunzip memtest86+-5.01.bin.gz
cp memtest86+-5.01.bin $FLASHMOUNT/

# Find and install the MBR for syslinux to flash
echo '[!] Writing MBR...'
SYSLINUXMBR=`locate mbr.bin | grep \/mbr.bin`
dd ibs=440 count=1 if=$SYSLINUXMBR of=$FLASHDEV

# Copy modules for presenting the menu, and handling hardware detection
echo '[!] Copying modules...'
SYSLINUXMODULES=(`locate hdt.c32 | grep \/bios` `locate pci.ids` `locate menu.c32 | grep \/bios\/menu` `locate libutil.c32 | grep \/bios`)
i=0
while [ $i -le $((${#SYSLINUXMODULES[@]} - 1)) ] ; do
	cp ${SYSLINUXMODULES[$i]} ${FLASHMOUNT}/
	i=$(($i + 1))
done

# Find the flash disk's UUID for syslinux configuration and write it
echo '[!] Writing syslinux configuration...'
FLASHUUID=$(ls -l /dev/disk/by-uuid | grep `echo $FLASHDEV | cut -d/ -f3` | grep -Po '[A-F0-9]{4}-[A-F0-9]{4}')
cat << EOF > ${FLASHMOUNT}/syslinux.cfg
DEFAULT 1
PROMPT 1        # Set to 1 if you always want to display the boot: prompt
TIMEOUT 30
UI menu.c32

MENU TITLE Memtest86+
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL 1
    MENU LABEL MemTest86+
    LINUX memtest86+-5.01.bin
    APPEND root=UUID=$FLASHUUID

LABEL hdt
    MENU LABEL Hardware Info
    COM32 hdt.c32

LABEL reboot
        MENU LABEL Reboot
        COM32 reboot.c32

LABEL poweroff
        MENU LABEL Poweroff
        COM32 poweroff.c32
EOF

# Unmount flash
umount $FLASHMOUNT

# Move flash over to computer to be tested, and boot!
echo '[!] Done!'
