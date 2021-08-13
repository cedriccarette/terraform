@echo off
terraform.exe init
timeout /t 2
terraform.exe refresh
exit