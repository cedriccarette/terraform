@echo off
imdisk -a -s 512M -m X: -p "/fs:ntfs /v:RAMDISK /q /c /y"
exit