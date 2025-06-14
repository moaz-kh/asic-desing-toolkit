#!/bin/bash
# Complete ASIC Design Tools Installer
# OpenLane 1 + Essential simulation and layout tools
# Target: WSL2 Ubuntu 22.04+

set -euo pipefail

# Configuration
readonly WORKSPACE_DIR="$HOME/asic_workspace"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "========================================"
echo "Complete ASIC Tools Installer"
echo "OpenLane + PDKs + Simulation + Layout"
echo "========================================"

# Basic checks
check_wsl2() {
    if [[ -z "${WSL_DISTRO_NAME:-}" ]]; then
        log_error "This script requires WSL2"
        exit 1
    fi
    log_info "WSL2 environment detected: $WSL_DISTRO_NAME"
}

check_resources() {
    local ram_gb disk_gb
    ram_gb=$(awk '/MemTotal/ {print int($2/1024/1024)}' /proc/meminfo)
    disk_gb=$(df -BG . | awk 'NR==2 {print int($4)}')
    
    if [ "$ram_gb" -lt 8 ]; then
        log_error "Need at least 8GB RAM (you have ${ram_gb}GB)"
        exit 1
    fi
    
    if [ "$disk_gb" -lt 50 ]; then
        log_error "Need at least 50GB disk space (you have ${disk_gb}GB)"
        exit 1
    fi
    
    log_info "Resources OK: ${ram_gb}GB RAM, ${disk_gb}GB disk"
}

# Install essential tools
install_essential_tools() {
    log_info "Installing essential tools..."
    sudo apt update
    sudo apt install -y git curl make build-essential
    sudo apt install -y bc
    
    # Simulation tools (required by Makefile sim targets)
    log_info "Installing simulation tools..."
    sudo apt install -y iverilog gtkwave

    # Layout viewing tools (simple installation)
    log_info "Installing layout viewing tools..."
    sudo apt install -y klayout magic

    log_info "Essential tools installed successfully"
}

# Install Docker
install_docker() {
    log_info "Installing Docker..."
    
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        log_info "Docker already working"
        return 0
    fi
    
    # Simple Docker installation
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
    
    log_warn "Docker installed. RESTART WSL2 now:"
    log_warn "1. Exit all terminals"
    log_warn "2. Run 'wsl --shutdown' from Windows"
    log_warn "3. Restart and re-run this script"
    exit 1
}

# Install OpenLane and PDKs
install_openlane() {
    log_info "Installing OpenLane..."
    
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    
    if [ ! -d "OpenLane" ]; then
        git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git
    fi
    
    cd OpenLane
    
    log_info "Downloading Docker images (10-20 minutes)..."
    make pull-openlane
    
    # Install default PDK (SkyWater 130nm)
    log_info "Installing default PDK (SkyWater 130nm)..."
    make pdk
    
    # Check for additional PDKs and offer installation
    install_additional_pdks
    
    # Verify PDK installations
    verify_pdks
    
    log_info "Testing OpenLane installation..."
    make test
    
    log_info "OpenLane installation complete!"
}

# Install additional PDKs
install_additional_pdks() {
    log_info "Checking for additional PDKs..."
    
    echo ""
    echo "Additional PDKs available:"
    echo "  - gf180mcu - GlobalFoundries 180nm MCU process"
    echo "    - Higher voltage capability (up to 10V)"
    echo "    - Automotive/industrial applications"
    echo "    - Larger geometry (easier design rules)"
    echo "    - Production-ready for high-voltage designs"
    echo ""
    read -p "Install GlobalFoundries 180nm PDK? [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing GlobalFoundries 180nm PDK..."
        log_info "This may take 10-15 minutes..."
        
        # Try standard installation method
        if make pdk PDK=gf180mcuA; then
            log_info " GF180MCU PDK installed successfully"
        else
            log_warn "Standard installation failed"
        fi
    else
        log_info "Skipping GlobalFoundries 180nm PDK - using SkyWater 130nm only"
    fi
}

# Verify PDK installations
verify_pdks() {
    log_info "Verifying PDK installations..."
    
    local pdk_dir="pdks"
    local installed_pdks=""
    
    # Check SkyWater 130nm (default)
    if [ -d "$WORKSPACE_DIR/$pdk_dir/sky130A" ]; then
        installed_pdks="$installed_pdks sky130A"
        log_info " SkyWater 130nm PDK installed"
    else
        log_error " SkyWater 130nm PDK not found!"
    fi
    
    # Check GlobalFoundries 180nm (if installed)
    if [ -d "$WORKSPACE_DIR/$pdk_dir/gf180mcuA" ]; then
        installed_pdks="$installed_pdks gf180mcuA"
        log_info " GlobalFoundries 180nm PDK installed"
    else
        log_error " GlobalFoundries 180nm PDK not found!"
    fi
    
    # Display PDK information
    display_pdk_info "$installed_pdks"
}

# Display PDK information
display_pdk_info() {
    local pdks="$1"
    
    echo ""
    echo "========================================"
    echo "Installed PDKs Information"
    echo "========================================"
    
    if echo "$pdks" | grep -q "sky130A"; then
        echo ""
        echo "SkyWater 130nm (sky130A):"
        echo "  - Technology: 180nm-130nm hybrid process"
        echo "  - Voltage: 1.8V internal, 5.0V I/O"
        echo "  - Features: LUTs, flip-flops, RAM, analog blocks"
        echo "  - Manufacturing: Tiny Tapeout (\$150-300), Google MPW"
        echo "  - Status: Production-ready, 600+ successful tapeouts"
        echo "  - Best for: Digital designs, learning, prototypes"
    fi
    
    if echo "$pdks" | grep -q "gf180mcuA"; then
        echo ""
        echo "GlobalFoundries 180nm MCU (gf180mcuA):"
        echo "  - Technology: 180nm MCU-optimized process"
        echo "  - Voltage: Up to 10V capability"
        echo "  - Features: Automotive/industrial qualified"
        echo "  - Manufacturing: Google-sponsored shuttles"
        echo "  - Status: Production-ready for high-voltage designs"
        echo "  - Best for: Automotive, industrial, high-voltage applications"
    fi
    
    echo ""
    echo "Default PDK for new projects: sky130A"
    echo "========================================"
}

# Verify installation
verify_installation() {
    log_info "Verifying complete installation..."
    
    # Check simulation tools
    if command -v iverilog &> /dev/null; then
        log_info " Icarus Verilog: $(iverilog -V | head -1)"
    else
        log_error " Icarus Verilog not found"
    fi
    
    if command -v gtkwave &> /dev/null; then
        log_info " GTKWave: $(gtkwave --version 2>&1 | head -1)"
    else
        log_error " GTKWave not found"
    fi
    
    # Check layout tools
    if command -v klayout &> /dev/null; then
        log_info " KLayout: $(klayout -v 2>&1 | head -1)"
    else
        log_warn " KLayout not found (layout viewing may not work)"
    fi
    
    if command -v magic &> /dev/null; then
        log_info " Magic: $(magic --version 2>&1 | head -1 || echo "installed")"
    else
        log_warn " Magic not found (layout editing may not work)"
    fi
    
    # Check Docker and OpenLane
    if command -v docker &> /dev/null && docker images | grep -q openlane; then
        log_info " OpenLane Docker images ready"
    else
        log_error " OpenLane Docker images not found"
    fi
    
    if [ -d "$WORKSPACE_DIR/OpenLane" ]; then
        log_info " OpenLane installed at: $WORKSPACE_DIR/OpenLane"
        
        # Check PDKs
        cd "$WORKSPACE_DIR"
        local pdk_count=0
        if [ -d "$WORKSPACE_DIR/pdks/sky130A" ]; then
            log_info " SkyWater 130nm PDK ready"
            pdk_count=$((pdk_count + 1))
        fi
        if [ -d "$WORKSPACE_DIR/pdks/gf180mcuA" ]; then
            log_info " GlobalFoundries 180nm PDK ready"
            pdk_count=$((pdk_count + 1))
        fi
        
        if [ $pdk_count -eq 0 ]; then
            log_error " No PDKs found!"
        else
            log_info " $pdk_count PDK(s) installed and ready"
        fi
    else
        log_error " OpenLane directory not found"
    fi
}

# Main function
main() {
    check_wsl2
    check_resources
    
    echo ""
    echo "This will install:"
    echo "  - OpenLane (ASIC RTL-to-GDSII flow)"
    echo "  - SkyWater 130nm PDK (default, production-ready)"
    echo "  - Optional: GlobalFoundries 180nm PDK (if available)"
    echo "  - Icarus Verilog + GTKWave (simulation)"
    echo "  - KLayout + Magic (layout viewing)"
    echo "  - Docker (required for OpenLane)"
    echo ""
    read -p "Proceed with installation? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    
    install_essential_tools
    install_docker
    install_openlane
    verify_installation
    
    echo ""
    echo "========================================"
    echo "Installation Complete!"
    echo "========================================"
    echo ""
    echo "OpenLane location: $WORKSPACE_DIR/OpenLane"
    echo "PDKs installed: Check PDK information above"
    echo ""
    echo "Next steps:"
    echo "1. Test OpenLane: cd $WORKSPACE_DIR/OpenLane && make test"
    echo "2. Create your first project: ./initiate_asic_proj.sh"
    echo ""
    echo "All tools ready for ASIC design workflow!"
}

main "$@"

# ================================================
# FUTURE IMPROVEMENT SUGGESTIONS
# ================================================
# This section documents potential enhancements that could be added to this installer
# in the future to provide additional ASIC design capabilities and improved workflow.

# SUGGESTION 1: Standalone Synthesis Tools
# ========================================
# Purpose: Add optional Yosys installation for standalone synthesis
# 
# Implementation would add:
# - sudo apt install -y yosys
# - Enables synthesis experiments outside of OpenLane
# - Useful for understanding synthesis flow step-by-step
# - Educational value for learning synthesis optimization
#
# Benefits:
# - Independent synthesis exploration
# - Better understanding of OpenLane internals
# - Custom synthesis script development
# - Academic research capabilities
#
# Usage example:
# yosys -p "read_verilog design.v; synth; write_json netlist.json"

# SUGGESTION 2: Mixed-Signal Simulation
# =====================================
# Purpose: Add optional ngspice for mixed-signal simulation capabilities
#
# Implementation would add:
# - sudo apt install -y ngspice
# - Enable analog/digital co-simulation
# - SPICE-level verification of critical circuits
# - Power analysis and characterization
#
# Benefits:
# - Complete mixed-signal design capability
# - Analog verification of digital circuits
# - Power consumption analysis
# - Signal integrity verification
# - PLL and analog IP validation
#
# Usage example:
# ngspice -b spice_netlist.cir

# SUGGESTION 3: Schematic Capture
# ===============================
# Purpose: Add optional Xschem for schematic capture and analog design
#
# Implementation would add:
# - Installation of Xschem from source or PPA
# - Integration with ngspice for simulation
# - Symbol library setup for SkyWater PDK
# - Schematic-driven design workflow
#
# Benefits:
# - Visual circuit design and documentation
# - Analog circuit design capabilities
# - Mixed-signal system design
# - Better design documentation and communication
# - Educational value for circuit understanding
#
# Usage example:
# xschem analog_design.sch

# SUGGESTION 4: Advanced Analysis Tools
# ====================================
# Purpose: Add optional advanced analysis and optimization tools
#
# Implementation could add:
# - OpenSTA (static timing analysis) - standalone installation
# - OpenROAD tools - individual component installation
# - Custom scripting environment setup
# - Performance analysis and optimization tools
#
# Benefits:
# - Detailed timing analysis outside of OpenLane
# - Custom optimization flows
# - Research and development capabilities
# - Better understanding of physical design

# SUGGESTION 5: Development Environment Enhancements
# =================================================
# Purpose: Enhanced development environment for ASIC design
#
# Implementation could add:
# - VS Code with HDL extensions and ASIC-specific configuration
# - Python environment with ASIC design libraries (gdspy, etc.)
# - Documentation generation tools (Doxygen, Sphinx)
# - Version control integration specific to ASIC workflows
#
# Benefits:
# - Professional development environment
# - Better project documentation
# - Team collaboration capabilities
# - Integration with existing digital design workflows

# SUGGESTION 6: Additional PDK Support
# ===================================
# Purpose: Add support for future PDKs as they become available
#
# Implementation could add:
# - Intel/Altera PDKs (when reverse-engineered)
# - TSMC open PDKs (if released)
# - Academic PDKs (FreePDK, NCSU)
# - Custom foundry PDKs
#
# Benefits:
# - Access to different technology nodes
# - Foundry-specific optimization
# - Research and comparison capabilities
# - Industry-standard process support
#
# Current status:
# - sky130A: Production-ready, most mature
# - gf180mcuA: Production-ready, automotive focus
# - Future PDKs: Depends on open-source releases

# IMPLEMENTATION NOTES:
# ====================
# When implementing any of these suggestions:
# 1. Keep installations optional (user choice during installation)
# 2. Maintain backward compatibility with existing workflow
# 3. Add verification steps for each new tool
# 4. Update the verification function to check new tools
# 5. Consider disk space and installation time impact
# 6. Provide clear documentation for each new capability

# PRIORITY RECOMMENDATIONS:
# =========================
# Based on typical ASIC development needs:
# 1. Standalone Yosys - Most educational value for beginners
# 2. Mixed-Signal Simulation - Essential for complete ASIC verification
# 3. Schematic Capture - Important for analog/mixed-signal designs
# 4. Advanced Analysis Tools - Professional development capability
# 5. Development Environment - Team development and documentation

# USAGE GUIDANCE:
# ==============
# These tools would be added as optional components:
# - Default installation keeps current minimal approach
# - Advanced users can opt-in to additional capabilities
# - Each tool addition should include basic usage examples
# - Integration with existing Makefile targets where appropriate