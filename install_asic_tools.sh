#!/usr/bin/env bash
# ASIC Tools Setup
# Installs the tools needed to simulate and synthesize RTL.
#
#   ./install_asic_tools.sh             Interactive menu (default)
#   ./install_asic_tools.sh --mode=sim  Simulation tools only
#   ./install_asic_tools.sh --mode=full Sim + OpenLane 2 + Sky130 PDK
#   ./install_asic_tools.sh --cleanup   Remove everything this script installed
#   ./install_asic_tools.sh --reinstall Cleanup then fresh install

set -euo pipefail

# --- Configuration -----------------------------------------------------------
readonly TOOLKIT_HOME="$HOME/.asic-toolkit"
readonly PDK_ROOT="$TOOLKIT_HOME/pdks"
readonly STATE_DIR="$TOOLKIT_HOME/state"
readonly APT_MANIFEST="$STATE_DIR/apt-installed.list"
readonly PIP_MANIFEST="$STATE_DIR/pip-installed.list"

readonly SIM_APT_PACKAGES="iverilog gtkwave verilator"
readonly PREREQ_APT_PACKAGES="curl wget git make python3 python3-pip"

# --- Colored logging ---------------------------------------------------------
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Helpers -----------------------------------------------------------------
is_yes() { [[ "$1" =~ ^([yY]|[yY][eE][sS])$ ]]; }
is_no()  { [[ "$1" =~ ^([nN]|[nN][oO])$ ]]; }

# Detect WSL2 vs native Linux. Does not abort on native Linux.
check_environment() {
    if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
        log_info "Environment: WSL2 (${WSL_DISTRO_NAME:-unknown distro})"
        IS_WSL2=1
    else
        log_info "Environment: native Linux"
        IS_WSL2=0
    fi
}

# Warn on low RAM, error on low disk.
check_resources() {
    local ram_gb disk_gb
    ram_gb=$(awk '/MemTotal/ {print int($2/1024/1024)}' /proc/meminfo)
    disk_gb=$(df -BG "$HOME" | awk 'NR==2 {gsub("G","",$4); print $4}')

    if [ "$ram_gb" -lt 16 ]; then
        log_warn "Only ${ram_gb}GB RAM detected. 16GB+ recommended for the full flow (P&R may run out of memory)."
    else
        log_info "RAM: ${ram_gb}GB"
    fi

    if [ "$disk_gb" -lt 50 ]; then
        log_error "Need at least 50GB free disk space (you have ${disk_gb}GB)."
        exit 1
    fi
    log_info "Disk free: ${disk_gb}GB"
}

# Record an apt package only if it was not already installed, so cleanup
# can remove exactly what this script added.
apt_install_tracked() {
    local pkg
    mkdir -p "$STATE_DIR"
    for pkg in "$@"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            echo "$pkg" >> "$APT_MANIFEST"
        fi
    done
    sudo apt-get install -y "$@"
}

pip_install_tracked() {
    local pkg
    mkdir -p "$STATE_DIR"
    for pkg in "$@"; do
        echo "$pkg" >> "$PIP_MANIFEST"
    done
    python3 -m pip install --user --upgrade "$@"
}

install_prerequisites() {
    log_info "Installing prerequisites..."
    sudo apt-get update
    apt_install_tracked $PREREQ_APT_PACKAGES build-essential
}

install_sim_tools() {
    log_info "Installing simulation tools (Icarus Verilog, GTKWave, Verilator)..."
    apt_install_tracked $SIM_APT_PACKAGES
}

install_docker() {
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        log_info "Docker already installed and running."
        return 0
    fi
    log_info "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
    log_warn "Docker installed. You must start a new shell session (or 'wsl --shutdown'"
    log_warn "on WSL2) for the docker group to take effect, then re-run with --mode=full."
    exit 1
}

install_openlane() {
    log_info "Installing OpenLane 2 (pip)..."
    pip_install_tracked openlane

    log_info "Installing Sky130 PDK via volare..."
    pip_install_tracked volare
    mkdir -p "$PDK_ROOT"
    local sky130_version
    sky130_version=$(python3 -m volare ls-remote --pdk sky130 | head -1)
    python3 -m volare enable --pdk sky130 --pdk-root "$PDK_ROOT" "$sky130_version"

    log_info "Running OpenLane smoke test (this can take a few minutes)..."
    if openlane --dockerized --smoke-test; then
        log_info "OpenLane smoke test passed."
    else
        log_warn "OpenLane smoke test failed. Check Docker is running and try again."
    fi
}

# Write-protect the PDK directory so a stray 'rm' or tool run cannot corrupt it.
protect_installation() {
    if [ -d "$PDK_ROOT" ]; then
        log_info "Write-protecting PDK directory: $PDK_ROOT"
        chmod -R a-w "$PDK_ROOT" 2>/dev/null || true
    fi
}

restore_write_permissions() {
    if [ -d "$PDK_ROOT" ]; then
        log_info "Restoring write permissions on: $PDK_ROOT"
        chmod -R u+w "$PDK_ROOT" 2>/dev/null || true
    fi
}

verify_installation() {
    log_info "Verifying installation..."
    local ok=1
    local t
    for t in iverilog vvp gtkwave verilator; do
        if command -v "$t" &>/dev/null; then
            log_info "  PASS  $t"
        else
            log_warn "  MISS  $t"
            ok=0
        fi
    done
    if [ "${MODE:-}" = "full" ]; then
        if command -v docker &>/dev/null; then log_info "  PASS  docker"; else log_warn "  MISS  docker"; ok=0; fi
        if command -v openlane &>/dev/null; then log_info "  PASS  openlane"; else log_warn "  MISS  openlane"; ok=0; fi
        if [ -d "$PDK_ROOT/sky130A" ]; then log_info "  PASS  sky130 PDK"; else log_warn "  MISS  sky130 PDK"; ok=0; fi
    fi
    if [ "$ok" -eq 1 ]; then
        log_info "All checks passed."
    else
        log_warn "Some tools are missing. Re-run the installer or check the messages above."
    fi
}

cleanup() {
    log_warn "This will remove everything install_asic_tools.sh installed."
    read -r -p "Continue? [y/N]: " reply
    if ! is_yes "${reply:-n}"; then
        log_info "Cleanup cancelled."
        exit 0
    fi

    restore_write_permissions

    if [ -f "$PIP_MANIFEST" ]; then
        log_info "Removing pip packages..."
        # shellcheck disable=SC2046
        python3 -m pip uninstall -y $(sort -u "$PIP_MANIFEST") 2>/dev/null || true
    fi

    if [ -f "$APT_MANIFEST" ]; then
        log_info "Removing apt packages this script installed..."
        # shellcheck disable=SC2046
        sudo apt-get remove -y $(sort -u "$APT_MANIFEST") 2>/dev/null || true
    fi

    log_info "Removing $TOOLKIT_HOME ..."
    rm -rf "$TOOLKIT_HOME"

    log_info "Cleanup complete. Docker (if installed) was left in place."
}

run_mode() {
    MODE="$1"
    check_environment
    check_resources
    install_prerequisites

    case "$MODE" in
        sim)
            install_sim_tools
            ;;
        full)
            install_sim_tools
            install_docker
            install_openlane
            protect_installation
            ;;
        *)
            log_error "Unknown mode: $MODE"
            exit 1
            ;;
    esac

    verify_installation
    echo
    log_info "Done. Create a project with:  ./initiate_proj.sh"
}

interactive_menu() {
    echo "========================================"
    echo "ASIC Tools Setup"
    echo "========================================"
    echo
    echo "What do you need?"
    echo
    echo "1) Simulation only  - Icarus Verilog + GTKWave + Verilator"
    echo "                      No Docker needed. ~50MB. Ready in 2 minutes."
    echo "                      For: RTL simulation and waveform viewing only."
    echo
    echo "2) Full ASIC flow   - Simulation + OpenLane 2 + Sky130 PDK"
    echo "                      Requires Docker. ~8GB download. Takes 20-30 min."
    echo "                      For: RTL simulation AND synthesis to GDSII."
    echo
    echo "3) Exit"
    echo
    local choice
    while true; do
        read -r -p "Enter choice [1-3]: " choice
        case "$choice" in
            1) run_mode sim; break ;;
            2) run_mode full; break ;;
            3) log_info "Exiting."; exit 0 ;;
            *) echo "Please enter 1, 2, or 3." ;;
        esac
    done
}

usage() {
    cat <<'EOF'
ASIC Tools Setup - installs the tools needed to simulate and synthesize RTL.

  ./install_asic_tools.sh             Interactive menu (default)
  ./install_asic_tools.sh --mode=sim  Simulation tools only
  ./install_asic_tools.sh --mode=full Sim + OpenLane 2 + Sky130 PDK
  ./install_asic_tools.sh --cleanup   Remove everything this script installed
  ./install_asic_tools.sh --reinstall Cleanup then fresh install
EOF
}

main() {
    local arg="${1:-}"
    case "$arg" in
        --mode=sim)   run_mode sim ;;
        --mode=full)  run_mode full ;;
        --cleanup)    cleanup ;;
        --reinstall)  cleanup; echo; interactive_menu ;;
        "")           interactive_menu ;;
        -h|--help)    usage ;;
        *)
            log_error "Unknown argument: $arg"
            log_error "Run with --help for usage."
            exit 1
            ;;
    esac
}

main "$@"
