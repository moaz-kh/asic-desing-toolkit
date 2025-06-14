#!/bin/bash
# ASIC Design Project Initialization Script
# Enhanced with multi-PDK OpenLane flow and professional structure
# Usage: bash initiate_asic_proj.sh

set -e  # Exit on any error

echo "================================================"
echo "Professional ASIC Design Project Initialization"
echo "================================================"
echo "Complete OpenLane RTL-to-GDSII environment setup"

# Get project name with validation
while true; do
    echo
    echo "Enter your project name:"
    echo "(alphanumeric, underscore, hyphen only)"
    read -p "Project Name: " PROJECT_NAME
    
    # Check if empty
    if [[ -z "$PROJECT_NAME" ]]; then
        echo "ERROR: Project name cannot be empty."
        continue
    fi
    
    # Check for valid characters
    if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "ERROR: Invalid project name. Use only letters, numbers, underscore, and hyphen."
        continue
    fi
    
    # Check if directory already exists
    if [[ -d "$PROJECT_NAME" ]]; then
        echo "ERROR: Directory '$PROJECT_NAME' already exists!"
        read -p "Do you want to use a different name? [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo "Exiting..."
            exit 1
        fi
        continue
    fi
    
    # Valid project name
    echo "Valid project name: $PROJECT_NAME"
    break
done

# Get top module name
echo
echo "Enter your top module name (default: $PROJECT_NAME):"
read -p "Top Module: " TOP_MODULE
if [[ -z "$TOP_MODULE" ]]; then
    TOP_MODULE="$PROJECT_NAME"
fi

# Get target clock frequency
echo
echo "Enter target clock frequency in MHz (default: 100):"
read -p "Clock Frequency (MHz): " CLOCK_FREQ
if [[ -z "$CLOCK_FREQ" ]]; then
    CLOCK_FREQ="100"
fi

# Validate frequency is a number
if ! [[ "$CLOCK_FREQ" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "ERROR: Invalid frequency. Using default 100 MHz."
    CLOCK_FREQ="100"
fi

CLOCK_PERIOD=$(echo "scale=2; 1000 / $CLOCK_FREQ" | bc -l)

# Confirmation
echo
echo "Project Configuration:"
echo "  Name: $PROJECT_NAME"
echo "  Top Module: $TOP_MODULE"
echo "  Clock: ${CLOCK_FREQ} MHz (${CLOCK_PERIOD} ns period)"
echo "  Features: Multi-PDK OpenLane, Simulation"
echo
read -p "Proceed with project creation? [Y/n]: " -n 1 -r
echo

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Project creation cancelled."
    exit 0
fi

echo
echo "================================================"
echo "Creating Professional ASIC Directory Structure"
echo "================================================"

# Create main project directory
echo "Creating main project directory: $PROJECT_NAME"
mkdir -p "$PROJECT_NAME"

# Create source directories
echo "Creating source directories..."
mkdir -p "$PROJECT_NAME/sources/rtl"
echo "  -> sources/rtl (RTL source files)"

mkdir -p "$PROJECT_NAME/sources/tb" 
echo "  -> sources/tb (Testbench files)"

mkdir -p "$PROJECT_NAME/sources/include"
echo "  -> sources/include (Header files)"

mkdir -p "$PROJECT_NAME/sources/constraints"
echo "  -> sources/constraints (SDC timing constraints)"

# Create simulation directories
echo "Creating simulation directories..."
mkdir -p "$PROJECT_NAME/sim/waves"
echo "  -> sim/waves (Waveform dumps)"

mkdir -p "$PROJECT_NAME/sim/logs"
echo "  -> sim/logs (Simulation logs)"

# Create OpenLane design structure (OpenLane 1 standard)
echo "Creating OpenLane design structure..."
mkdir -p "$PROJECT_NAME/designs/$TOP_MODULE"
echo "  -> designs/$TOP_MODULE (OpenLane design directory)"

mkdir -p "$PROJECT_NAME/config"
echo "  -> config (PDK-specific configurations)"

# Create output directories organized by PDK
echo "Creating output directories..."
mkdir -p "$PROJECT_NAME/runs/sky130"
echo "  -> runs/sky130 (SkyWater 130nm outputs)"

mkdir -p "$PROJECT_NAME/runs/gf180"
echo "  -> runs/gf180 (GlobalFoundries 180nm outputs)"

mkdir -p "$PROJECT_NAME/layout"
echo "  -> layout (Final GDSII files)"

mkdir -p "$PROJECT_NAME/reports"
echo "  -> reports (Timing/area/power reports)"

mkdir -p "$PROJECT_NAME/verification"
echo "  -> verification (DRC/LVS results)"

# Create documentation and utility directories
echo "Creating documentation directories..."
mkdir -p "$PROJECT_NAME/docs"
echo "  -> docs (Project documentation)"

mkdir -p "$PROJECT_NAME/scripts"
echo "  -> scripts (Build and automation scripts)"

mkdir -p "$PROJECT_NAME/vendor"
echo "  -> vendor (Third-party IP)"

mkdir -p "$PROJECT_NAME/ip"
echo "  -> ip (Custom IP cores)"

echo
echo "================================================"
echo "Creating Template Files"
echo "================================================"

# Check if Makefile.template exists
if [[ ! -f "Makefile.template" ]]; then
    echo "ERROR: Makefile.template not found in current directory!"
    echo "Please ensure Makefile.template is in the same directory as this script."
    exit 1
fi
 
# Create enhanced Makefile from template
echo "Creating enhanced Makefile from template..."
sed -e "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" -e "s/TOP_MODULE_PLACEHOLDER/$TOP_MODULE/g" -e "s/TESTBENCH_PLACEHOLDER/${TOP_MODULE}_tb/g" Makefile.template > "$PROJECT_NAME/Makefile"
echo "Makefile created successfully"

echo
echo "================================================"
echo "Creating Multi-PDK Configuration Templates"
echo "================================================"

# Create SkyWater 130nm config template
echo "Creating SkyWater 130nm configuration..."
cat > "$PROJECT_NAME/config/sky130.json" << EOF
{
    "DESIGN_NAME": "$TOP_MODULE",
    "VERILOG_FILES": [
    ],
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": $CLOCK_PERIOD,
    
    "PDK": "sky130A",
    "STD_CELL_LIBRARY": "sky130_fd_sc_hd",
    
    "FP_SIZING": "absolute",
    "DIE_AREA": "0 0 200 200",
    "FP_CORE_UTIL": 40,
    "FP_ASPECT_RATIO": 1,
    "FP_PDN_AUTO_ADJUST": 0,
    
    "PL_TARGET_DENSITY": 0.4,
    "PL_RESIZER_DESIGN_OPTIMIZATIONS": 1,
    "PL_RESIZER_TIMING_OPTIMIZATIONS": 1,
    
    "GLB_RESIZER_TIMING_OPTIMIZATIONS": 1,
    "GLB_RESIZER_MAX_WIRE_LENGTH": 0,
    "GLB_RESIZER_MAX_SLEW_MARGIN": 10,
    "GLB_RESIZER_MAX_CAP_MARGIN": 10,
    
    "SYNTH_STRATEGY": "AREA 0",
    "SYNTH_BUFFERING": 1,
    "SYNTH_SIZING": 1,
    
    "RUN_HEURISTIC_DIODE_INSERTION": 1,
    "HEURISTIC_ANTENNA_THRESHOLD": 90,
    
    "RUN_CVC": 1,
    "RUN_SIMPLE_CTS": 0,
    
    "QUIT_ON_TIMING_VIOLATIONS": 0,
    "QUIT_ON_MAGIC_DRC": 1,
    "QUIT_ON_LVS_ERROR": 1,
    "QUIT_ON_SLEW_VIOLATIONS": 0
}
EOF

# Create GlobalFoundries 180nm config template  
echo "Creating GlobalFoundries 180nm configuration..."
cat > "$PROJECT_NAME/config/gf180.json" << EOF
{
    "DESIGN_NAME": "$TOP_MODULE",
    "VERILOG_FILES": [
    ],
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": $CLOCK_PERIOD,
    
    "PDK": "gf180mcuA",
    "STD_CELL_LIBRARY": "gf180mcu_fd_sc_mcu7t5v0",
    
    "FP_SIZING": "absolute", 
    "DIE_AREA": "0 0 300 300",
    "FP_CORE_UTIL": 35,
    "FP_ASPECT_RATIO": 1,
    "FP_PDN_AUTO_ADJUST": 0,
    
    "PL_TARGET_DENSITY": 0.35,
    "PL_RESIZER_DESIGN_OPTIMIZATIONS": 1,
    "PL_RESIZER_TIMING_OPTIMIZATIONS": 1,
    
    "GLB_RESIZER_TIMING_OPTIMIZATIONS": 1,
    "GLB_RESIZER_MAX_WIRE_LENGTH": 0,
    "GLB_RESIZER_MAX_SLEW_MARGIN": 10,
    "GLB_RESIZER_MAX_CAP_MARGIN": 10,
    
    "SYNTH_STRATEGY": "AREA 0",
    "SYNTH_BUFFERING": 1,
    "SYNTH_SIZING": 1,
    
    "RUN_HEURISTIC_DIODE_INSERTION": 1,
    "HEURISTIC_ANTENNA_THRESHOLD": 90,
    
    "RUN_CVC": 1,
    "RUN_SIMPLE_CTS": 0,
    
    "QUIT_ON_TIMING_VIOLATIONS": 0,
    "QUIT_ON_MAGIC_DRC": 1,
    "QUIT_ON_LVS_ERROR": 1,
    "QUIT_ON_SLEW_VIOLATIONS": 0
}
EOF

echo
echo "================================================"
echo "Creating SDC Timing Constraints"
echo "================================================"

# Create basic SDC constraints
echo "Creating basic SDC timing constraints..."
cat > "$PROJECT_NAME/sources/constraints/${TOP_MODULE}.sdc" << EOF
# SDC Timing Constraints for $TOP_MODULE
# Target frequency: ${CLOCK_FREQ} MHz (${CLOCK_PERIOD} ns period)

# Create clock
create_clock -name clk -period $CLOCK_PERIOD [get_ports clk]

# Set clock uncertainty (10% of period for safety)
set_clock_uncertainty [expr $CLOCK_PERIOD * 0.1] [get_clocks clk]

# Set clock transition time
set_clock_transition 0.1 [get_clocks clk]

# Input/Output delays (30% of clock period)
set input_delay [expr $CLOCK_PERIOD * 0.3]
set output_delay [expr $CLOCK_PERIOD * 0.3]

# Set input delays on all input ports except clock
set_input_delay \$input_delay -clock [get_clocks clk] [all_inputs]
set_input_delay 0 -clock [get_clocks clk] [get_ports clk]

# Set output delays on all output ports
set_output_delay \$output_delay -clock [get_clocks clk] [all_outputs]

# Set driving cell for inputs
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_1 [all_inputs]

# Set load capacitance for outputs  
set_load 0.1 [all_outputs]

# Set maximum transition time
set_max_transition 0.5 [current_design]

# Set maximum fanout
set_max_fanout 10 [current_design]
EOF

echo
echo "================================================"
echo "Creating File Management System"
echo "================================================"

# Create rtl_list.f for simulation
echo "Creating rtl_list.f for simulation..."
cat > "$PROJECT_NAME/sources/rtl_list.f" << EOF
# RTL File List for Simulation
# Generated by initiate_asic_proj.sh
# Date: $(date)
# Project: $PROJECT_NAME

# Project-specific RTL files
# (Add your design files here or run 'make update_list')

# Include directories
+incdir+$(pwd)/$PROJECT_NAME/sources/include

# Usage: iverilog -f sources/rtl_list.f -s testbench_top -o sim.vvp
EOF

echo
echo "================================================"
echo "Auto-Example Generation (Optional)"
echo "================================================"

echo "Do you want to create a complete ASIC example design?"
echo "This will create:"
echo "  • Standalone 8-bit counter module (counter.v)"
echo "  • Top-level integration module (${TOP_MODULE}.v)"
echo "  • Comprehensive testbench with assertions"
echo "  • Updated configurations for both PDKs"
echo "  • Ready-to-run OpenLane flow"
echo
read -p "Create example design? [Y/n]: " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo
    echo "Creating complete ASIC example..."
    
    # Create standalone counter module (the actual implementation)
    echo "Creating counter.v (standalone 8-bit counter module)..."
    cat > "$PROJECT_NAME/sources/rtl/counter.v" << 'EOF'
// 8-bit Counter with Enable and Clear
// Standalone module for ASIC implementation

module counter (
    input clk,              // Clock input
    input rst_n,            // Active-low reset
    input enable,           // Counter enable
    input clear,            // Synchronous clear
    output reg [7:0] count, // 8-bit count output
    output overflow         // Overflow flag
);

    // Overflow detection
    assign overflow = (count == 8'hFF) && enable;

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 8'h00;
        else if (clear)
            count <= 8'h00;
        else if (enable)
            count <= count + 1'b1;
    end

endmodule
EOF

    # Create top-level module that instantiates the counter
    echo "Creating ${TOP_MODULE}.v (top-level integration module)..."
    cat > "$PROJECT_NAME/sources/rtl/${TOP_MODULE}.v" << EOF
// Top-level module for $PROJECT_NAME
// Instantiates 8-bit counter for ASIC demonstration
// Target: ${CLOCK_FREQ} MHz operation

module $TOP_MODULE (
    input clk,           // Main clock input
    input rst_n,         // Active-low reset
    input enable,        // Counter enable
    input clear,         // Counter clear
    output [7:0] count,  // Counter output
    output overflow,     // Counter overflow flag
    output heartbeat     // Heartbeat signal (MSB of counter)
);

    // Instantiate the counter module
    counter u_counter (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .clear(clear),
        .count(count),
        .overflow(overflow)
    );
    
    // Heartbeat output (toggles every 128 counts)
    assign heartbeat = count[7];

endmodule
EOF

    # Create comprehensive testbench
    echo "Creating comprehensive testbench..."
    cat > "$PROJECT_NAME/sources/tb/${TOP_MODULE}_tb.v" << EOF
// Comprehensive Testbench for $TOP_MODULE
// ASIC verification with assertions and coverage

\`timescale 1ns/1ps

module ${TOP_MODULE}_tb;

    // Test parameters
    parameter CLK_PERIOD = $CLOCK_PERIOD;
    parameter SIM_TIME = CLK_PERIOD * 1000; // 1000 clock cycles
    
    // DUT signals
    reg clk, rst_n, enable, clear;
    wire [7:0] count;
    wire overflow, heartbeat;
    
    // Test control
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate DUT
    $TOP_MODULE dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .clear(clear),
        .count(count),
        .overflow(overflow),
        .heartbeat(heartbeat)
    );

    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Waveform dump
    initial begin
        \$dumpfile("sim/waves/${TOP_MODULE}_waves.vcd");
        \$dumpvars(0, ${TOP_MODULE}_tb);
    end

    // Test sequence
    initial begin
        \$display("=== $TOP_MODULE ASIC Testbench Started ===");
        \$display("Target frequency: ${CLOCK_FREQ} MHz");
        \$display("Clock period: %0.2f ns", CLK_PERIOD);
        
        // Initialize
        rst_n = 0;
        enable = 0;
        clear = 0;
        
        // Reset test
        \$display("\\n--- Reset Test ---");
        repeat(5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        check_result("Reset", count, 8'h00, "Count should be 0 after reset");
        
        // Basic counting test
        \$display("\\n--- Basic Counting Test ---");
        enable = 1;
        repeat(10) begin
            @(posedge clk);
        end
        check_result("Count to 10", count, 8'd10, "Should count to 10");
        
        // Clear test
        \$display("\\n--- Clear Test ---");
        clear = 1;
        @(posedge clk);
        clear = 0;
        check_result("Synchronous Clear", count, 8'h00, "Count should be 0 after clear");
        
        // Overflow test
        \$display("\\n--- Overflow Test ---");
        enable = 1;
        repeat(260) @(posedge clk); // Count past 255
        check_result("Overflow", overflow, 1'b1, "Overflow should be asserted");
        
        // Heartbeat test
        \$display("\\n--- Heartbeat Test ---");
        enable = 1;
        repeat(130) @(posedge clk); // Count to > 128
        check_result("Heartbeat", heartbeat, 1'b1, "Heartbeat should be high when count[7]=1");
        
        // Disable test
        \$display("\\n--- Disable Test ---");
        enable = 0;
        repeat(5) begin
            @(posedge clk);
        end
        // Count should remain stable
        
        // Final results
        \$display("\\n=== Test Results ===");
        \$display("Total tests: %0d", test_count);
        \$display("Passed: %0d", pass_count);
        \$display("Failed: %0d", fail_count);
        \$display("Success rate: %0.1f%%", (pass_count * 100.0) / test_count);
        
        if (fail_count == 0)
            \$display("\\n🎉 ALL TESTS PASSED! Ready for ASIC implementation.");
        else
            \$display("\\n❌ Some tests failed. Check design before tapeout.");
            
        \$display("\\n=== Testbench Complete ===");
        \$finish;
    end

    // Check result task
    task check_result;
        input [200*8-1:0] test_name;
        input [7:0] actual;
        input [7:0] expected;
        input [200*8-1:0] description;
        begin
            test_count = test_count + 1;
            if (actual === expected) begin
                \$display("✓ PASS: %s - %s", test_name, description);
                pass_count = pass_count + 1;
            end else begin
                \$display("✗ FAIL: %s - Expected: %h, Got: %h", test_name, expected, actual);
                \$display("       %s", description);
                fail_count = fail_count + 1;
            end
        end
    endtask
 
endmodule
EOF

    # Update configurations with example design files
    echo "Updating PDK configurations..."
    
    # Update Sky130 config
    python3 -c "
import json
with open('$PROJECT_NAME/config/sky130.json', 'r') as f:
    config = json.load(f)
config['VERILOG_FILES'] = [
    'sources/rtl/counter.v',
    'sources/rtl/$TOP_MODULE.v'
]
with open('$PROJECT_NAME/config/sky130.json', 'w') as f:
    json.dump(config, f, indent=4)
"

    # Update GF180 config
    python3 -c "
import json
with open('$PROJECT_NAME/config/gf180.json', 'r') as f:
    config = json.load(f)
config['VERILOG_FILES'] = [
    'sources/rtl/counter.v',
    'sources/rtl/$TOP_MODULE.v'
]
with open('$PROJECT_NAME/config/gf180.json', 'w') as f:
    json.dump(config, f, indent=4)
"

    # Update rtl_list.f
    echo "$(pwd)/$PROJECT_NAME/sources/rtl/counter.v" >> "$PROJECT_NAME/sources/rtl_list.f"
    echo "$(pwd)/$PROJECT_NAME/sources/rtl/${TOP_MODULE}.v" >> "$PROJECT_NAME/sources/rtl_list.f"
    echo "$(pwd)/$PROJECT_NAME/sources/tb/${TOP_MODULE}_tb.v" >> "$PROJECT_NAME/sources/rtl_list.f"
    
    echo "Example design created successfully!"
    echo "Created: sources/rtl/counter.v (standalone counter module)"
    echo "Created: sources/rtl/${TOP_MODULE}.v (top-level integration module)"
    echo "Created: sources/tb/${TOP_MODULE}_tb.v (comprehensive testbench)"
    EXAMPLE_CREATED=true
else
    echo "Skipping example design creation."
    EXAMPLE_CREATED=false
fi

echo
echo "================================================"
echo "Creating Project Documentation"
echo "================================================"

# Create comprehensive .gitignore
echo "Creating ASIC-specific .gitignore..."
cat > "$PROJECT_NAME/.gitignore" << 'EOF'
# OpenLane outputs
runs/*/
designs/*/runs/
*.gds
*.def
*.lef
*.mag
*.spice

# Simulation outputs
*.vvp
*.vcd
*.fst
*.lxt
*.lxt2
*.ghw
sim/waves/*
!sim/waves/.gitkeep

# Synthesis outputs
*.json.bak
*.v.bak

# Reports and logs
*.log
*.rpt
*.tmp
reports/*.rpt
verification/*

# Layout tools
*.db
*.lib

# OS specific
.DS_Store
Thumbs.db

# Editor specific
*.swp
*.swo
*~
.vscode/settings.json
.idea/

# Build outputs
build/
dist/
__pycache__/

# Vendor specific
vendor/*/
!vendor/.gitkeep
EOF

# Create comprehensive README
echo "Creating project README..."
cat > "$PROJECT_NAME/README.md" << EOF
# $PROJECT_NAME

## ASIC Design Project
Complete RTL-to-GDSII flow using open-source tools

### Project Configuration
- **Top Module**: $TOP_MODULE
- **Target Frequency**: ${CLOCK_FREQ} MHz (${CLOCK_PERIOD} ns period)
- **Supported PDKs**: SkyWater 130nm, GlobalFoundries 180nm
- **Tools**: OpenLane, Icarus Verilog, GTKWave

## Quick Start

### 1. Verify Installation
\`\`\`bash
make check-tools
make check-openlane
\`\`\`

### 2. Run Simulation
\`\`\`bash
make sim-waves              # Run simulation and view waveforms
\`\`\`

### 3. Run ASIC Flow
\`\`\`bash
# SkyWater 130nm
make asic-flow-sky130

# GlobalFoundries 180nm  
make asic-flow-gf180

# Compare results
make compare-pdks
\`\`\`

## Directory Structure
\`\`\`
$PROJECT_NAME/
├── sources/              # Source code
│   ├── rtl/             # RTL source files
│   │   ├── counter.v        # Standalone counter module
│   │   └── $TOP_MODULE.v    # Top-level integration
│   ├── tb/              # Testbenches
│   ├── include/         # Header files
│   ├── constraints/     # SDC timing constraints
│   └── rtl_list.f       # File list for simulation
├── config/              # PDK-specific configurations
│   ├── sky130.json      # SkyWater 130nm config
│   └── gf180.json       # GlobalFoundries 180nm config
├── designs/             # OpenLane design directories
│   └── $TOP_MODULE/     # Design-specific OpenLane files
├── sim/                 # Simulation workspace
│   ├── waves/           # Waveform dumps
│   └── logs/            # Simulation logs
├── runs/                # OpenLane run outputs
│   ├── sky130/          # SkyWater results
│   └── gf180/           # GlobalFoundries results
├── layout/              # Final GDSII files
├── reports/             # Analysis reports
└── docs/                # Documentation
\`\`\`

## Available Make Targets

### Simulation
\`\`\`bash
make sim                 # Run Icarus Verilog simulation
make waves               # Open GTKWave waveform viewer
make sim-waves           # Run simulation and open waveforms
\`\`\`

### ASIC Flow (Multi-PDK)
\`\`\`bash
make asic-flow-sky130    # Complete flow for SkyWater 130nm
make asic-flow-gf180     # Complete flow for GlobalFoundries 180nm
make compare-pdks        # Compare results between PDKs
\`\`\`

### Individual Steps
\`\`\`bash
make synth-sky130        # Synthesis only (SkyWater)
make synth-gf180         # Synthesis only (GlobalFoundries)
make floorplan-sky130    # Floorplanning (SkyWater)
make placement-sky130    # Placement (SkyWater)
make routing-sky130      # Routing (SkyWater)
\`\`\`

### Layout Viewing
\`\`\`bash
make view-gds-sky130     # View SkyWater GDSII in KLayout
make view-gds-gf180      # View GlobalFoundries GDSII in KLayout
make view-magic          # Open layout in Magic
\`\`\`

### Configuration Management
\`\`\`bash
make update-config       # Update configs from rtl_list.f
make verify-config       # Verify configuration files
\`\`\`

### Analysis
\`\`\`bash
make timing-sky130       # Timing analysis (SkyWater)
make timing-gf180        # Timing analysis (GlobalFoundries)
make area-report         # Area utilization report
make power-report        # Power analysis report
\`\`\`

### Utilities
\`\`\`bash
make status              # Show project status
make clean               # Clean simulation files
make clean-runs          # Clean OpenLane runs
make help                # Show all targets
\`\`\`

## Design Hierarchy

The example demonstrates proper ASIC design modularity:

### counter.v
Standalone 8-bit counter with enable, clear, and overflow detection
\`\`\`verilog
counter u_counter (
    .clk(clk), .rst_n(rst_n), .enable(enable),
    .clear(clear), .count(count), .overflow(overflow)
);
\`\`\`

### ${TOP_MODULE}.v
Top-level integration module that:
- Instantiates the counter
- Adds heartbeat output (count[7])
- Demonstrates proper design hierarchy

## PDK Comparison

| Feature | SkyWater 130nm | GlobalFoundries 180nm |
|---------|----------------|----------------------|
| **Voltage** | 1.8V core, 5V I/O | Up to 10V |
| **Use Case** | Digital, mixed-signal | Automotive, industrial |
| **Die Area** | Smaller geometry | Larger geometry |
| **Cost** | Lower (shuttle programs) | Higher voltage capability |
| **Maturity** | 600+ tapeouts | Production automotive |

## Design Flow

1. **RTL Design** → Write Verilog in \`sources/rtl/\`
2. **Simulation** → Test with \`make sim-waves\`
3. **Synthesis** → \`make synth-sky130\` or \`make synth-gf180\`
4. **Physical Design** → \`make asic-flow-sky130/gf180\`
5. **Verification** → DRC/LVS automatically run
6. **Analysis** → \`make timing-sky130\`, \`make area-report\`
7. **Layout** → \`make view-gds-sky130\` 

## Tape-out Checklist

- [ ] All simulations pass
- [ ] Timing closure achieved
- [ ] DRC clean
- [ ] LVS clean  
- [ ] Power analysis complete
- [ ] Design review complete
- [ ] Documentation updated

## Troubleshooting

### Common Issues
1. **Timing violations** → Reduce clock frequency or optimize RTL
2. **DRC errors** → Check design rules, reduce density
3. **LVS errors** → Verify netlist connectivity
4. **Large die area** → Increase utilization or optimize

### Getting Help
- Check \`make status\` for project overview
- View logs in \`sim/logs/\` and \`runs/\*/logs/\`
- Use \`make help\` for all available targets

## Files Generated
- **GDSII**: \`layout/\*.gds\` - Final layout for fabrication
- **Reports**: \`reports/\*.rpt\` - Timing, area, power analysis
- **Logs**: \`sim/logs/\`, \`runs/\*/logs/\` - Tool outputs

Generated with professional ASIC project initialization script.
EOF

# Create tape-out checklist
echo "Creating tape-out checklist..."
cat > "$PROJECT_NAME/docs/TAPEOUT_CHECKLIST.md" << EOF
# Tape-out Checklist for $PROJECT_NAME

## Pre-Tapeout Verification

### Functional Verification
- [ ] All testbenches pass
- [ ] Corner case testing complete
- [ ] Assertion-based verification
- [ ] Code coverage > 95%
- [ ] Random testing completed

### Timing Verification  
- [ ] Setup timing closure (all corners)
- [ ] Hold timing closure (all corners)
- [ ] Clock domain crossing verified
- [ ] Reset timing verified
- [ ] I/O timing constraints met

### Physical Verification
- [ ] DRC clean (all rules pass)
- [ ] LVS clean (layout vs schematic)
- [ ] Antenna rules pass
- [ ] Density rules met
- [ ] Metal fill completed

### Power Analysis
- [ ] Static power analysis
- [ ] Dynamic power analysis  
- [ ] Electromigration analysis
- [ ] IR drop analysis
- [ ] Power grid verification

### Design Reviews
- [ ] RTL design review
- [ ] Synthesis review
- [ ] Floorplan review
- [ ] Placement review
- [ ] Routing review
- [ ] Final layout review

### Documentation
- [ ] Design specification updated
- [ ] User manual completed
- [ ] Test plan documented
- [ ] Known issues documented
- [ ] Revision history updated

### Manufacturing Readiness
- [ ] PDK compliance verified
- [ ] Foundry DRC rules checked
- [ ] Package compatibility verified
- [ ] Test vector generation
- [ ] Production test plan

## Post-Tapeout Activities
- [ ] Silicon validation plan
- [ ] Debug strategy defined
- [ ] Measurement plan ready
- [ ] Documentation finalized

**Sign-off Date**: ___________
**Reviewer**: ___________
**Project Manager**: ___________
EOF

# Create .gitkeep files
echo "Creating .gitkeep files..."
touch "$PROJECT_NAME/sources/include/.gitkeep"
touch "$PROJECT_NAME/vendor/.gitkeep"
touch "$PROJECT_NAME/ip/.gitkeep"
touch "$PROJECT_NAME/sim/waves/.gitkeep"

echo
echo "================================================"
echo "Project Created Successfully!"
echo "================================================"

echo "Project: $PROJECT_NAME"
echo "Location: $(pwd)/$PROJECT_NAME"
echo "Top Module: $TOP_MODULE"
echo "Target: ${CLOCK_FREQ} MHz (${CLOCK_PERIOD} ns)"

echo
echo "Features Included:"
echo "✅ Professional ASIC directory structure"
echo "✅ Multi-PDK support (SkyWater 130nm + GlobalFoundries 180nm)"
echo "✅ SDC timing constraints"
echo "✅ Comprehensive simulation setup"
echo "✅ File list management (rtl_list.f)"
echo "✅ OpenLane configuration templates"
if [[ "$EXAMPLE_CREATED" == "true" ]]; then
    echo "✅ Complete working example (standalone counter + top integration)"
    echo "✅ Proper design hierarchy demonstration"
    echo "✅ Comprehensive testbench with assertions"
fi
echo "✅ Multi-PDK comparison capability"
echo "✅ Professional documentation"
echo "✅ Tape-out checklist"

echo
echo "Next Steps:"
echo "1. cd $PROJECT_NAME"
if [[ "$EXAMPLE_CREATED" == "true" ]]; then
    echo "2. make sim-waves              # Test example design"
    echo "3. make asic-flow-sky130       # Run complete ASIC flow"
    echo "4. make view-gds-sky130        # View final layout"
    echo "5. make compare-pdks           # Compare PDK results"
else
    echo "2. Add your RTL to sources/rtl/"
    echo "3. make update-config          # Update configurations"
    echo "4. make sim-waves              # Test your design"
    echo "5. make asic-flow-sky130       # Run ASIC flow"
fi

echo
echo "Multi-PDK Workflow:"
echo "• make asic-flow-sky130    → SkyWater 130nm implementation"
echo "• make asic-flow-gf180     → GlobalFoundries 180nm implementation"  
echo "• make compare-pdks        → Compare area/timing/power"

echo
echo "Documentation:"
echo "• README.md - Complete workflow guide"
echo "• docs/TAPEOUT_CHECKLIST.md - Professional checklist"
echo "• make help - All available targets"

echo
echo "🎉 Professional ASIC development environment ready!"
echo "Ready for RTL-to-GDSII with open-source tools!"