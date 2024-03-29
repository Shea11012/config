# Update aur package by select
function paru_update() {
    paru -Qauq | fzf -m | xargs -ro paru -S
}

function mount_share() {
    sudo mount --mkdir -t cifs //192.168.32.100/share /mnt/share -o username=smbuser,password=123,iocharset=utf8,uid=1000,gid=1000
}

function update_archlinuxcn_mirrors() {
    tmpFile=$(mktemp)
    rate-mirrors --save=$tmpFile archlinuxcn
    sudo mv $tmpFile /etc/pacman.d/archlinuxcn-mirrorlist
    paru -Sc --aur --noconfirm
}