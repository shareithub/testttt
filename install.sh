#!/bin/bash
clear
# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

EXPIRY_DATE="2025-03-31"  # Set the expiration date (YYYY-MM-DD)

# Get current date
current_date=$(date +%Y-%m-%d)

if [[ "$current_date" > "$EXPIRY_DATE" ]]; then
    echo -e "${RED}The script has expired. Please contact the administrator.${NC}"
    exit 1
fi

expiry_seconds=$(date -d "$EXPIRY_DATE" +%s)
current_seconds=$(date +%s)
remaining_seconds=$((expiry_seconds - current_seconds))
remaining_days=$((remaining_seconds / 86400))

echo -e "${MAGENTA} ┌────────────────────────────────────────────────────────────────────────────────────────┐ ${NC}"
echo -e "${MAGENTA} │${NC}              ${YELLOW}Server Information${NC}                ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} ├────────────────────────────────────────────────────────────────────────────────────────┤ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Version       : 1.0 WD${NC}                            ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Creator       : Warkop Digital${NC}                   ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Client Name   : Windows RDP${NC}                      ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Provider      : DigitalOcean${NC}                     ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} │${NC} ${CYAN}Expiry In     : ${remaining_days} days remaining${NC}               ${MAGENTA}│ ${NC}"
echo -e "${MAGENTA} └────────────────────────────────────────────────────────────────────────────────────────┘ ${NC}"

# Langsung memilih Windows Server 2022
PILIHOS="https://sourceforge.net/projects/shareithub/files/shareithub/windows2022.gz"
echo -e "${CYAN}Memulai instalasi Windows 2022...${NC}"

# Menggunakan kata sandi default untuk akun Administrator
PASSWORD="Nixpoin.com123!"
echo -e "${CYAN}Menggunakan kata sandi default: $PASSWORD${NC}"

# Mengambil IP publik dan gateway
IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# Membuat file net.bat untuk pengaturan IP dan DNS secara otomatis
cat >/tmp/net.bat<<EOF
@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)
net user Administrator $PASSWORD

netsh -c interface ip set address name="Ethernet" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="Ethernet" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="Ethernet" address=8.8.4.4 index=2 validate=no

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit
EOF

# Mengunduh dan menginstall image OS Windows 2022
echo "Mendownload file $PILIHOS..."
wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

# Mount partisi dan menyiapkan file setup
mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
wget https://nixpoin.com/ChromeSetup.exe
cp -f /tmp/net.bat net.bat

# Shutdown
echo -e "${RED}Your server will turn off in 3 seconds...${NC}"
sleep 3
poweroff
