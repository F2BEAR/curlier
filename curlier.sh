#!/bin/bash

ROOT_DIR="$(pwd)"
REQUEST_DIR="${CURLIER_REQUESTS_DIR:-$ROOT_DIR/request}"

# verify dependencies
if ! command -v curl >/dev/null 2>&1; then
  echo "❌ curl is not installed."
  exit 1
fi

load_env_files() {
  local request_path="$1"
  local request_dir
  request_dir=$(dirname "$request_path")
  local current_dir="$request_dir"
  local env_files=()

  while [[ "$current_dir" == "$ROOT_DIR"* ]]; do
    if [[ -f "$current_dir/.env" ]]; then
      env_files+=("$current_dir/.env")
    fi

    current_dir=$(dirname "$current_dir")
  done

  if [[ -f "$REQUEST_DIR/.env" ]]; then
    env_files+=("$REQUEST_DIR/.env")
  fi

  for ((i = ${#env_files[@]} - 1; i >= 0; i--)); do
    set -o allexport
    # shellcheck disable=SC1090
    source "${env_files[i]}"
    set +o allexport
  done
}

show_help() {
  echo "📦 Curlier - A CLI for curl API requests"
  echo "Usage: ./curlier.sh <request_name>"
  echo "Example: .curlier.sh get_users [-p key=value ...]"
  echo ""
  echo "Flags"
  echo "  --params | -p <foo>=<bar> -- Sends params to the request file as env vars."
  echo "  --list | -l -- List all available requests."
  echo "  --wildcard | -w -- Sets a wildcard to your request URI"
  echo ""
  echo "All requests are just .sh with the curl command to be executed."
  echo "Save them into $REQUEST_DIR/<request_name>.sh"
  echo ""
  echo "Pro tip: add an alias for curlier.sh into your shell config file (ie: .zshrc, .bashrc, etc...)"
  echo "alias curlier=$ROOT_DIR/curlier/curlier.sh"
}

# display help
if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# display list of available requests
if [[ "$1" == '-l' || "$1" == "--list" ]]; then
  echo "Currently available requests:"
  if [ -d "$REQUEST_DIR" ]; then
    CURRENT_DIR=$(pwd)
    cd "$REQUEST_DIR" || exit 1
    if [ "$(ls -A .)" ]; then
      find . -type f -name "*.sh" | sed 's|^\./||' | sed 's/\.sh$//' | sort | while read -r req; do
        echo "- $req"
      done
    else
      echo "No requests found."
    fi
    cd "$CURRENT_DIR" || exit 1
  else
    echo "No requests directory found."
  fi
  exit 0
fi

REQUEST="$1"
shift

PARAMS=()

# Flags parsing
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -p | --params)
    shift
    while [[ "$1" =~ ^[a-zA-Z0-9_]+=.+$ ]]; do
      param_name="${1%%=*}"
      param_value="${1#*=}"

      export "${param_name}"="${param_value}"

      if [[ -z "$URL_PARAMS" ]]; then
        export URL_PARAMS="${param_name}=${param_value}"
      else
        export URL_PARAMS="$URL_PARAMS&${param_name}=${param_value}"
      fi

      PARAMS+=("$1")
      shift
    done
    continue
    ;;
  -w | --wildcard)
    shift
    while [[ "$1" =~ ^[a-zA-Z0-9_]+=.+$ ]]; do
      wildcard_name="${1%%=*}"
      wildcard_value="${1#*=}"

      export "${wildcard_name}"="${wildcard_value}"
      WILDCARDS+=("$1")
      shift
    done
    continue
    ;;
  *)
    echo "⚠ Unknown optioin: $1"
    exit 1
    ;;
  esac
done

# send params as env vars to the script
for param in "${PARAMS[@]}"; do
  export "${param%%=*}"="${param#*=}"
done

# Declare request file
REQUEST_FILE="$REQUEST_DIR/$REQUEST.sh"

if [[ ! -f "$REQUEST_FILE" ]]; then
  echo "❌ There is no request called '$REQUEST'."
  exit 1
fi

# Load all relevant .env files
load_env_files "$REQUEST_FILE"

# Execute request
bash "$REQUEST_FILE"
