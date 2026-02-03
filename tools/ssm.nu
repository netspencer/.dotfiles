# ~/.dotfiles/tools/ssm.nu
# AWS SSM Session Manager shortcuts
#
# Usage:
#   ssm <name>           Start a saved connection
#   ssm list             List all connections
#   ssm add              Add new connection (interactive)
#   ssm edit             Edit config file
#   ssm help             Show help

const SSM_CONFIG = "~/.config/ssm/connections.json"

# Initialize config if needed
def ssm-init [] {
    let config_path = ($SSM_CONFIG | path expand)
    let config_dir = ($config_path | path dirname)

    if not ($config_path | path exists) {
        mkdir $config_dir

        let default_config = {
            connections: {
                staging-db: {
                    type: "port-forward"
                    target: "i-08cb6f5a5d70d4451"
                    host: "delphi-staging-aurora-cluster.cluster-c0t5xvscn3cc.us-east-1.rds.amazonaws.com"
                    remote_port: "5432"
                    local_port: "5434"
                    region: "us-east-1"
                    description: "Staging Aurora PostgreSQL"
                }
            }
        }

        $default_config | to json | save $config_path
        print $"Created SSM config: ($config_path)"
    }
}

# Main ssm command
def ssm [cmd?: string] {
    ssm-init

    let command = ($cmd | default "help")

    match $command {
        "list" | "ls" => { ssm-list }
        "add" => { ssm-add }
        "edit" => { ssm-edit }
        "help" | "-h" | "--help" => { ssm-help }
        _ => { ssm-start $command }
    }
}

def ssm-help [] {
    print "SSM Session Manager Shortcuts

Usage:
  ssm <name>       Start a saved connection
  ssm list         List all saved connections
  ssm add          Add new connection interactively
  ssm edit         Edit config in $EDITOR

Examples:
  ssm staging-db   Connect to staging database
  ssm list         Show available connections

Config: ~/.config/ssm/connections.json"
}

def ssm-list [] {
    let config = (open ($SSM_CONFIG | path expand))

    print "SSM Connections:\n"

    $config.connections
        | transpose name details
        | each { |row|
            let desc = ($row.details.description? | default "No description")
            print $"  \e[36m($row.name)\e[0m - ($desc)"
        }

    print ""
}

def ssm-start [name: string] {
    let config_path = ($SSM_CONFIG | path expand)
    let config = (open $config_path)

    let conn = ($config.connections | get -o $name)

    if ($conn | is-empty) {
        print $"Connection '($name)' not found\n"
        ssm-list
        return
    }

    let conn_type = ($conn.type? | default "shell")
    let target = $conn.target
    let region = ($conn.region? | default "us-east-1")
    let desc = ($conn.description? | default "")

    print $"→ ($name)"
    if ($desc | is-not-empty) {
        print $"  ($desc)"
    }
    print ""

    if $conn_type == "port-forward" {
        let host = $conn.host
        let remote_port = $conn.remote_port
        let local_port = $conn.local_port

        print $"  localhost:($local_port) → ($host):($remote_port)\n"

        let params = $'{"host":["($host)"],"portNumber":["($remote_port)"],"localPortNumber":["($local_port)"]}'

        aws ssm start-session --target $target --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $params --region $region
    } else {
        aws ssm start-session --target $target --region $region
    }
}

def ssm-add [] {
    print "Add SSM Connection\n"

    let name = (input "Name: " | str trim)
    if ($name | is-empty) { return }

    print "Type: (1) port-forward  (2) shell"
    let type_num = (input "[1]: " | str trim)
    let conn_type = if $type_num == "2" { "shell" } else { "port-forward" }

    let target = (input "Instance ID (i-xxx): " | str trim)
    let region_input = (input "Region [us-east-1]: " | str trim)
    let region = if ($region_input | is-empty) { "us-east-1" } else { $region_input }
    let desc = (input "Description: " | str trim)

    mut new_conn = {
        type: $conn_type
        target: $target
        region: $region
        description: $desc
    }

    if $conn_type == "port-forward" {
        let host = (input "Remote host: " | str trim)
        let remote_port_input = (input "Remote port [5432]: " | str trim)
        let remote_port = if ($remote_port_input | is-empty) { "5432" } else { $remote_port_input }
        let local_port_input = (input $"Local port [($remote_port)]: " | str trim)
        let local_port = if ($local_port_input | is-empty) { $remote_port } else { $local_port_input }

        $new_conn = ($new_conn | merge {
            host: $host
            remote_port: $remote_port
            local_port: $local_port
        })
    }

    let config_path = ($SSM_CONFIG | path expand)
    let config = (open $config_path)
    let new_connections = ($config.connections | insert $name $new_conn)
    let updated = ($config | upsert connections $new_connections)

    $updated | to json | save -f $config_path

    print $"\nAdded '($name)' - use: ssm ($name)"
}

def ssm-edit [] {
    let editor = ($env.EDITOR? | default "vim")
    run-external $editor ($SSM_CONFIG | path expand)
}

# Tab completion for ssm command
def "nu-complete ssm" [] {
    let cmds = ["list" "add" "edit" "help"]

    let config_path = ($SSM_CONFIG | path expand)
    let conns = if ($config_path | path exists) {
        (open $config_path).connections | columns
    } else {
        []
    }

    $cmds | append $conns
}
