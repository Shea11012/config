# Update aur package by select
function paru_update() {
    paru -Qauq | fzf -m | xargs -ro paru -S
}

# Clean unused package
function paru_clean() {
    paru -Qdtq | paru -Rns -
    paru -Qqd | paru -Rsu -
    sudo paccache -rk3
}

function update_mirrors() {
    rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist
    rate-mirrors archlinuxcn | sudo tee /etc/pacman.d/archlinuxcn-mirrorlist
}

function lt() {
    local depth=${1:-2}
    lsd -a --tree --depth $depth $2
}
