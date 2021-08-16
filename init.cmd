@echo off
cd /d X:\Terraform
terraform.exe init
timeout /t 2
terraform.exe refresh
exit
