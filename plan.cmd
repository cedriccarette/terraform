@echo off
cd /d X:\Terraform
terraform.exe plan > plan.txt
write-host "Close if all looks well..."
