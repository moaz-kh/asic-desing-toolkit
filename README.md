# ASIC Design Toolkit

**Complete open-source ASIC design workflow from RTL to GDSII using OpenLane**


## 🚀 What This Toolkit Provides

- **One-command ASIC tool installation** (OpenLane + PDKs + simulation tools)
- **Professional project templates** with multi-PDK support
- **Complete RTL-to-GDSII workflow** using industry-standard open-source tools
- **Ready-to-run examples** with comprehensive testbenches
- **Multi-PDK comparison** (SkyWater 130nm vs GlobalFoundries 180nm)
- **Professional Makefile** with 30+ automated targets

## 🎯 Perfect For

- **ASIC designers** transitioning from FPGAs to silicon
- **Students** learning chip design and tapeout flows
- **Researchers** needing reproducible ASIC workflows
- **Startups** requiring cost-effective silicon prototyping
- **Anyone** wanting to design custom chips without expensive EDA licenses

## ⚡ Quick Start

### 1. Install ASIC Tools (5 minutes)
```bash
git clone https://github.com/moaz-kh/asic-design-toolkit.git
cd asic-design-toolkit
chmod +x install_asic_tools.sh
./install_asic_tools.sh
```

**What gets installed:**
- OpenLane (RTL-to-GDSII flow)
- SkyWater 130nm PDK (production-ready, 600+ successful tapeouts)
- Optional: GlobalFoundries 180nm PDK (automotive/industrial)
- Icarus Verilog + GTKWave (simulation)
- KLayout + Magic (layout viewing)

### 2. Create Your First ASIC Project (2 minutes)
```bash
chmod +x initiate_asic_proj.sh
./initiate_asic_proj.sh
```

Interactive setup creates:
- Complete directory structure
- Multi-PDK configurations
- Example 8-bit counter with testbench
- Professional Makefile with 30+ targets

### 3. Run Complete ASIC Flow (10-30 minutes)
```bash
cd your_project_name

# Test simulation first
make sim-waves

# Run complete RTL-to-GDSII flow
make asic-flow-sky130      # SkyWater 130nm
make asic-flow-gf180       # GlobalFoundries 180nm (optional)

# View your chip layout
make view-gds-sky130
```

## 🛠️ Complete Workflow

```mermaid
graph LR
    A[Verilog RTL] --> B[Simulation]
    B --> C[Synthesis]
    C --> D[Floorplan]
    D --> E[Placement]
    E --> F[Routing]
    F --> G[GDSII Layout]
    G --> H[Fabrication Ready]
```

## 📁 Generated Project Structure

```
your_project/
├── sources/rtl/           # Your Verilog designs
├── sources/tb/            # Testbenches
├── config/               # Multi-PDK configurations
│   ├── sky130.json       # SkyWater 130nm settings
│   └── gf180.json        # GlobalFoundries 180nm settings
├── sim/waves/            # Simulation waveforms
├── runs/                 # OpenLane outputs
│   ├── sky130/          # SkyWater results
│   └── gf180/           # GlobalFoundries results
├── layout/              # Final GDSII files
└── Makefile             # 30+ automated targets
```

## 🎖️ Key Features

### Multi-PDK Support
- **SkyWater 130nm**: 1.8V-5V, proven with 600+ tapeouts, $150-300 via Tiny Tapeout
- **GlobalFoundries 180nm**: Up to 10V, automotive-grade, production-ready

### Professional Automation
```bash
make help                 # Show all 30+ available targets
make check-all           # Verify complete setup
make asic-flow-sky130    # Complete RTL-to-GDSII flow
make compare-pdks        # Compare implementations
make timing-sky130       # Timing analysis
make area-report         # Area utilization
make view-gds-sky130     # Open layout viewer
```

### Example Design Included
- 8-bit counter with enable, clear, overflow detection
- Comprehensive testbench with 1000+ test cases
- Ready-to-manufacture with proper timing constraints
- Demonstrates professional ASIC design practices

## 🔧 Requirements

- **OS**: Ubuntu 22.04+ (native or WSL2)
- **Memory**: 8GB+ RAM 
- **Storage**: 50GB+ available space
- **Tools**: Automatically installed by script

## 📊 Proven Results

- **600+ successful tapeouts** using SkyWater 130nm PDK
- **Production-ready flows** for educational and commercial use
- **Complete silicon verification** from simulation to fabricated chips
- **Industry-standard tools** (OpenLane, OpenROAD, Yosys, Magic)

## 🎓 Learning Path

1. **Start here**: Run example counter design
2. **Simulation**: Learn Verilog testbench development
3. **Synthesis**: Understand RTL-to-netlist conversion
4. **Physical Design**: Learn placement and routing
5. **Verification**: Master DRC/LVS checking
6. **Tapeout**: Submit to Tiny Tapeout or shuttle programs

## 🆚 Why Open-Source ASIC?

| Commercial EDA | Open-Source (This Toolkit) |
|----------------|---------------------------|
| $100K-500K/year | **Free** |
| Black box tools | **Full transparency** |
| Vendor lock-in | **Tool independence** |
| Complex setup | **One-command install** |
| Limited access | **Available to everyone** |

## 🌟 Success Stories

This toolkit enables the same flows used for:
- Google's **Open MPW shuttle program** (300+ designs)
- **Tiny Tapeout** educational program (500+ student designs)
- **Commercial ASIC prototypes** for startups
- **Research chips** at universities worldwide

## 🤝 Contributing

We welcome contributions! Please see:
- Add new PDK support
- Improve example designs  
- Enhance automation scripts
- Update documentation

## 📚 Additional Resources

- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [SkyWater PDK](https://skywater-pdk.readthedocs.io/)
- [Tiny Tapeout](https://tinytapeout.com/) - $150 chip fabrication
- [Zero to ASIC Course](https://www.zerotoasiccourse.com/)

## 🏷️ Keywords

`ASIC design` `RTL-to-GDSII` `OpenLane` `SkyWater 130nm` `GlobalFoundries 180nm` `chip design` `tapeout` `silicon` `open source EDA` `digital design` `Verilog` `GDSII` `place and route` `synthesis` `verification` `Tiny Tapeout`

---

**Ready to design your first chip?** ⚡ 

```bash
git clone https://github.com/moaz-kh/asic-design-toolkit.git
cd asic-design-toolkit
./install_asic_tools.sh
```

*From idea to silicon in minutes, not months.* 🚀