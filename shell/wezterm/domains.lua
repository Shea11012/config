return {
    ssh_domains = {
        {
            multiplexing = 'None',
            name = 'SSH:arch',
            remote_address = '192.168.32.16',
            username = 'mxy',
            ssh_option = {
                identityfile = "C:\\Users\\18723\\.ssh\\id_ecdsa"
            }
        }
    },
    wsl_domains = {
        {
            name = "WSL:Arch",
            distribution = 'Arch',
            username = 'mxy',
        }
    }
}
