#!/usr/bin/env bash
# New ASIC Project
# Two questions, generates a ready-to-run project scaffold.
#
#   ./initiate_proj.sh                 Interactive (default)
#   ./initiate_proj.sh <name> --sim    Simulation-only project
#   ./initiate_proj.sh <name> --sky130 Sky130 RTL-to-GDSII project

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly SCRIPTS_DIR="$SCRIPT_DIR/scripts"

dispatch() {
    local name="$1" target="$2"
    case "$target" in
        sim)    bash "$SCRIPTS_DIR/create_sim_project.sh" "$name" ;;
        sky130) bash "$SCRIPTS_DIR/create_sky130_project.sh" "$name" ;;
        *)      log_error "Unknown target: $target"; exit 1 ;;
    esac
}

# Non-interactive form: ./initiate_proj.sh <name> --sim|--sky130
if [[ $# -gt 0 ]]; then
    NAME="$1"
    case "${2:-}" in
        --sim)    dispatch "$NAME" sim; exit 0 ;;
        --sky130) dispatch "$NAME" sky130; exit 0 ;;
        "")       : ;;  # name only - fall through to ask for target
        *)        log_error "Unknown flag: ${2:-}"; exit 1 ;;
    esac
else
    NAME=""
fi

echo "========================================"
echo "New ASIC Project"
echo "========================================"
echo

while [[ -z "$NAME" ]]; do
    read -r -p "Project name: " NAME
    if [[ -z "$NAME" ]]; then
        echo "Please enter a name."
    fi
done

echo
echo "What are you targeting?"
echo
echo "1) Simulation only  - I just want to simulate my RTL"
echo "2) Sky130 (130nm)   - I want to synthesize to GDSII (Tiny Tapeout compatible)"
echo
while true; do
    read -r -p "Enter choice [1-2]: " choice
    case "$choice" in
        1) dispatch "$NAME" sim; break ;;
        2) dispatch "$NAME" sky130; break ;;
        *) echo "Please enter 1 or 2." ;;
    esac
done
