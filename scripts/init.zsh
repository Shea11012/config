# Update aur package by select
function paru_update() {
    paru -Qauq | fzf -m | xargs -ro paru -S
}

# run subconverter
function run_subconverter() {
    docker run -d --name sub -p 25500:25500 -v sub-data:/base tindy2013/subconverter:latest
}
