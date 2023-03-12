# Update aur package by select
function paru_update() {
    paru -Qauq | fzf -m | xargs -ro paru -S
}
