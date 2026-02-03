#!/usr/bin/env zsh
# ~/.dotfiles/tools/ssm.zsh
# AWS SSM Session Manager shortcuts
#
# Usage:
#   ssm <name>           Start a saved connection
#   ssm list             List all connections
#   ssm add              Add new connection (interactive)
#   ssm edit             Edit config file
#   ssm help             Show help

SSM_CONFIG="${HOME}/.config/ssm/connections.json"

# Initialize config if needed
_ssm_init() {
  if [[ ! -f "$SSM_CONFIG" ]]; then
    mkdir -p "$(dirname "$SSM_CONFIG")"
    cat > "$SSM_CONFIG" << 'EOF'
{
  "connections": {
    "staging-db": {
      "type": "port-forward",
      "target": "i-08cb6f5a5d70d4451",
      "host": "delphi-staging-aurora-cluster.cluster-c0t5xvscn3cc.us-east-1.rds.amazonaws.com",
      "remote_port": "5432",
      "local_port": "5434",
      "region": "us-east-1",
      "description": "Staging Aurora PostgreSQL"
    }
  }
}
EOF
    echo "Created SSM config: $SSM_CONFIG"
  fi
}

ssm() {
  _ssm_init

  local cmd="${1:-help}"

  case "$cmd" in
    list|ls)
      _ssm_list
      ;;
    add)
      _ssm_add
      ;;
    edit)
      ${EDITOR:-vim} "$SSM_CONFIG"
      ;;
    help|-h|--help)
      _ssm_help
      ;;
    *)
      _ssm_start "$cmd"
      ;;
  esac
}

_ssm_help() {
  cat << 'EOF'
SSM Session Manager Shortcuts

Usage:
  ssm <name>       Start a saved connection
  ssm list         List all saved connections
  ssm add          Add new connection interactively
  ssm edit         Edit config in $EDITOR

Examples:
  ssm staging-db   Connect to staging database
  ssm list         Show available connections

Config: ~/.config/ssm/connections.json
EOF
}

_ssm_list() {
  echo "SSM Connections:"
  echo ""
  jq -r '.connections | to_entries[] | "  \u001b[36m\(.key)\u001b[0m - \(.value.description // "No description")"' "$SSM_CONFIG"
  echo ""
}

_ssm_start() {
  local name="$1"

  if ! command -v jq &>/dev/null; then
    echo "Error: jq required (brew install jq)"
    return 1
  fi

  local conn=$(jq -r ".connections[\"$name\"] // empty" "$SSM_CONFIG")

  if [[ -z "$conn" ]]; then
    echo "Connection '$name' not found"
    echo ""
    _ssm_list
    return 1
  fi

  local type=$(echo "$conn" | jq -r '.type')
  local target=$(echo "$conn" | jq -r '.target')
  local region=$(echo "$conn" | jq -r '.region // "us-east-1"')
  local desc=$(echo "$conn" | jq -r '.description // ""')

  echo "→ $name"
  [[ -n "$desc" ]] && echo "  $desc"
  echo ""

  if [[ "$type" == "port-forward" ]]; then
    local host=$(echo "$conn" | jq -r '.host')
    local remote_port=$(echo "$conn" | jq -r '.remote_port')
    local local_port=$(echo "$conn" | jq -r '.local_port')

    echo "  localhost:$local_port → $host:$remote_port"
    echo ""

    aws ssm start-session \
      --target "$target" \
      --document-name AWS-StartPortForwardingSessionToRemoteHost \
      --parameters "{\"host\":[\"$host\"],\"portNumber\":[\"$remote_port\"],\"localPortNumber\":[\"$local_port\"]}" \
      --region "$region"
  else
    aws ssm start-session --target "$target" --region "$region"
  fi
}

_ssm_add() {
  echo "Add SSM Connection"
  echo ""

  read "name?Name: "
  [[ -z "$name" ]] && return 1

  echo "Type: (1) port-forward  (2) shell"
  read "type_num?[1]: "
  local type=$([[ "$type_num" == "2" ]] && echo "shell" || echo "port-forward")

  read "target?Instance ID (i-xxx): "
  read "region?Region [us-east-1]: "
  region="${region:-us-east-1}"
  read "desc?Description: "

  local new_conn
  if [[ "$type" == "port-forward" ]]; then
    read "host?Remote host: "
    read "remote_port?Remote port [5432]: "
    remote_port="${remote_port:-5432}"
    read "local_port?Local port [$remote_port]: "
    local_port="${local_port:-$remote_port}"

    new_conn=$(jq -n \
      --arg type "$type" \
      --arg target "$target" \
      --arg host "$host" \
      --arg remote_port "$remote_port" \
      --arg local_port "$local_port" \
      --arg region "$region" \
      --arg desc "$desc" \
      '{type:$type,target:$target,host:$host,remote_port:$remote_port,local_port:$local_port,region:$region,description:$desc}')
  else
    new_conn=$(jq -n \
      --arg type "$type" \
      --arg target "$target" \
      --arg region "$region" \
      --arg desc "$desc" \
      '{type:$type,target:$target,region:$region,description:$desc}')
  fi

  local tmp=$(mktemp)
  jq --arg n "$name" --argjson c "$new_conn" '.connections[$n]=$c' "$SSM_CONFIG" > "$tmp"
  mv "$tmp" "$SSM_CONFIG"

  echo ""
  echo "Added '$name' - use: ssm $name"
}

# Tab completion
_ssm_complete() {
  local -a conns cmds
  cmds=(list add edit help)
  if [[ -f "$SSM_CONFIG" ]] && command -v jq &>/dev/null; then
    conns=(${(f)"$(jq -r '.connections|keys[]' "$SSM_CONFIG" 2>/dev/null)"})
  fi
  _describe 'command' cmds
  _describe 'connection' conns
}
compdef _ssm_complete ssm
