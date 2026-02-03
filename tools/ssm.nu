# ~/.dotfiles/tools/ssm.nu
# AWS SSM Session Manager shortcuts
#
# Usage:
#   ssm <name>           Start a saved connection (legacy)
#   ssm <resource> <env> Start a saved connection by resource/env
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
            pairs: {}
        }

        $default_config | to json | save $config_path
        print $"Created SSM config: ($config_path)"
    }
}

# Main ssm command
def ssm [cmd?: string, env_name?: string] {
    ssm-init

    let command = ($cmd | default "help")

    if ($env_name | is-not-empty) {
        ssm-start-pair $command $env_name
        return
    }

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
  ssm <name>       Start a saved connection (legacy)
  ssm <res> <env>  Start a saved connection by resource/env
  ssm list         List all saved connections
  ssm add          Add new connection interactively
  ssm edit         Edit config in $EDITOR

Examples:
  ssm staging-db   Connect to staging database (legacy)
  ssm db prod      Connect to prod database
  ssm deus staging Connect to staging Deus
  ssm list         Show available connections

Config: ~/.config/ssm/connections.json"
}

def ssm-list [] {
    let config = (open ($SSM_CONFIG | path expand))

    print "SSM Connections:\n"

    let pairs = ($config.pairs? | default {})
    let connections = ($config.connections? | default {})

    if (($pairs | columns | length) > 0) {
        print "  Resource/Env:\n"
        $pairs
            | transpose resource envs
            | each { |row|
                $row.envs
                    | transpose env details
                    | each { |env_row|
                        let desc = ($env_row.details.description? | default "No description")
                        print $"    \e[36m($row.resource)\e[0m \e[36m($env_row.env)\e[0m - ($desc)"
                    }
            }
        print ""
    }

    if (($connections | columns | length) > 0) {
        print "  Legacy:\n"
        $connections
            | transpose name details
            | each { |row|
                let desc = ($row.details.description? | default "No description")
                print $"    \e[36m($row.name)\e[0m - ($desc)"
            }
    }

    print ""
}

def ssm-start [name: string] {
    let config_path = ($SSM_CONFIG | path expand)
    let config = (open $config_path)

    let conn = ($config.connections? | default {} | get -o $name)

    if ($conn | is-empty) {
        let pairs = ($config.pairs? | default {})
        let resource_block = ($pairs | get -o $name)

        if ($resource_block | is-empty) {
            print $"Connection '($name)' not found\n"
            ssm-list
            return
        }

        print $"Resource '($name)' found. Available envs:\n"
        $resource_block
            | transpose env details
            | each { |row|
                let desc = ($row.details.description? | default "No description")
                print $"  \e[36m($row.env)\e[0m - ($desc)"
            }
        print "\nUse: ssm <resource> <env>"
        return
    }

    ssm-run $name $conn
}

def ssm-start-pair [resource: string, env_name: string] {
    let config_path = ($SSM_CONFIG | path expand)
    let config = (open $config_path)

    let pairs = ($config.pairs? | default {})
    let resource_block = ($pairs | get -o $resource)

    if ($resource_block | is-empty) {
        print $"Resource '($resource)' not found\n"
        ssm-list
        return
    }

    let conn = ($resource_block | get -o $env_name)
    if ($conn | is-empty) {
        print $"Env '($env_name)' not found for resource '($resource)'\n"
        print "Available envs:\n"
        $resource_block
            | transpose env details
            | each { |row|
                let desc = ($row.details.description? | default "No description")
                print $"  \e[36m($row.env)\e[0m - ($desc)"
            }
        print ""
        return
    }

    ssm-run $"($resource) ($env_name)" $conn
}

def ssm-run [display: string, conn: record] {
    let conn_type = ($conn.type? | default "shell")
    let target = $conn.target
    let region = ($conn.region? | default "us-east-1")
    let desc = ($conn.description? | default "")

    print $"→ ($display)"
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

    print "Mode: (1) resource/env  (2) legacy name"
    let mode_num = (input "[1]: " | str trim)
    let mode = if $mode_num == "2" { "legacy" } else { "pair" }

    let name = if $mode == "legacy" {
        (input "Name: " | str trim)
    } else {
        ""
    }

    let resource = if $mode == "pair" {
        (input "Resource (e.g. db, deus): " | str trim)
    } else {
        ""
    }
    let env_name = if $mode == "pair" {
        (input "Env (e.g. prod, staging): " | str trim)
    } else {
        ""
    }

    if $mode == "legacy" and ($name | is-empty) { return }
    if $mode == "pair" and (($resource | is-empty) or ($env_name | is-empty)) { return }

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
    let connections = ($config.connections? | default {})
    let pairs = ($config.pairs? | default {})

    let updated = if $mode == "legacy" {
        let new_connections = ($connections | insert $name $new_conn)
        ($config | upsert connections $new_connections)
    } else {
        let resource_block = ($pairs | get -o $resource | default {})
        let updated_resource = ($resource_block | insert $env_name $new_conn)
        let new_pairs = ($pairs | insert $resource $updated_resource)
        ($config | upsert pairs $new_pairs)
    }

    $updated | to json | save -f $config_path

    if $mode == "legacy" {
        print $"\nAdded '($name)' - use: ssm ($name)"
    } else {
        print $"\nAdded '($resource) ($env_name)' - use: ssm ($resource) ($env_name)"
    }
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
        (open $config_path).connections? | default {} | columns
    } else {
        []
    }
    let resources = if ($config_path | path exists) {
        (open $config_path).pairs? | default {} | columns
    } else {
        []
    }

    $cmds | append $resources | append $conns
}
