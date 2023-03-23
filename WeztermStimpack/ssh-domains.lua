return {
    {
        -- The name of this specific domain.  Must be unique amongst
        -- all types of domain in the configuration file.
        name = 'device.MQTTBroker',
        -- identifies the host:port pair of the remote server
        -- Can be a DNS name or an IP address with an optional
        -- ":port" on the end.
        remote_address = '192.168.100.35',
        -- The username to use for authenticating with the remote host
        username = 'jgarner',
        -- Set to 'None' for ssh hosts that do not have wezterm available
        -- multiplexing = 'None',
        -- Only set the default_prog if using 'None'
        -- default_prog = { 'bash' },
        multiplexing = 'WezTerm',
        -- connect_automatically = true,
    },
    {
        name = 'homeserver.Proxmox1',
        remote_address = '192.168.1.57',
        username = 'root',
        multiplexing = 'WezTerm',
        -- connect_automatically = true,
    },
    {
        name = 'homeserver.Proxmox2',
        remote_address = '192.168.1.60',
        username = 'root',
        multiplexing = 'WezTerm',
        -- connect_automatically = true,
    },
}
