# ASIC Design Toolkit

Drop in your RTL, simulate it, and synthesize it to GDSII - with one setup
script if you don't have the tools yet.

This toolkit is the friendly UX layer on top of the open-source ASIC flow. It
wraps [OpenLane 2](https://github.com/efabless/openlane2) (Yosys + OpenROAD +
Magic + KLayout) and the Sky130 PDK so a digital designer can go from Verilog
to layout with `make` commands they already know.

Sister project: [fpga-design-toolkit](https://github.com/moaz-kh/fpga-design-toolkit).

## The 5-step journey

```
Step 1 - Clone the toolkit
Step 2 - Run setup            (only if you don't have the tools yet)
Step 3 - Drop in your RTL
Step 4 - make sim             see waveforms
Step 5 - make synth / gds     get a netlist / GDSII
```

## Step 1 - Clone

```bash
git clone https://github.com/moaz-kh/asic-desing-toolkit.git
cd asic-desing-toolkit
```

## Step 2 - Install the tools

```bash
./install_asic_tools.sh
```

You get an interactive menu with two real choices:

| Choice | Installs | Needs Docker | Size / time |
|--------|----------|--------------|-------------|
| **1) Simulation only** | Icarus Verilog + GTKWave + Verilator | No | ~50MB, 2 min |
| **2) Full ASIC flow** | Simulation + OpenLane 2 + Sky130 PDK | Yes | ~8GB, 20-30 min |

Non-interactive flags for CI / power users:

```bash
./install_asic_tools.sh --mode=sim     # simulation tools only
./install_asic_tools.sh --mode=full    # sim + OpenLane 2 + Sky130
./install_asic_tools.sh --cleanup      # remove everything it installed
./install_asic_tools.sh --reinstall    # cleanup then fresh install
```

The Sky130 PDK is installed with [volare](https://github.com/efabless/volare)
into `~/.asic-toolkit/pdks` and write-protected so a stray command can't
corrupt it.

## Step 3 - Create a project

```bash
./initiate_proj.sh
```

Two questions - project name, and what you're targeting:

1. **Simulation only** - just simulate RTL
2. **Sky130 (130nm)** - synthesize to GDSII (Tiny Tapeout compatible)

It generates a ready-to-run project. Put your Verilog in `rtl/` (a working
counter stub is there to replace), edit the testbench in `tb/`, and go.

```
my_project/
├── rtl/              your Verilog goes here
│   ├── my_project.v  example design stub - replace it
│   └── lib/          standard modules, ready to use:
│       ├── synchronizer.v   2-flop CDC synchronizer
│       ├── edge_detector.v  rising/falling edge pulses
│       ├── reset_sync.v     async-assert / sync-deassert reset
│       └── async_fifo.v     parameterized async FIFO
├── tb/               testbenches (self-checking stub included)
├── sim/waves/        VCD output + GTKWave session files
├── config/           OpenLane 2 config  (Sky130 projects only)
└── Makefile
```

## Steps 4 & 5 - Simulate and synthesize

From inside your project:

```bash
make sim          # compile and run simulation
make waves        # open GTKWave
make sim-waves    # simulate then open waveforms (most common)

make synth        # synthesize RTL -> netlist        (Sky130 projects)
make gds          # full RTL -> GDSII flow           (Sky130 projects)
make view-gds     # open the layout in KLayout
```

`make help` lists every command. Step-by-step flow targets (`floorplan`,
`place`, `route`) and result viewers (`timing`, `area`) are there too.

## Requirements

- Linux (native or WSL2), Ubuntu 22.04+ recommended
- 16GB+ RAM recommended for the full flow (place & route is memory-hungry)
- 50GB+ free disk for the full flow

## How this relates to the ecosystem

This toolkit does **not** reimplement the flow - it wraps mature projects:

- **OpenLane 2 / LibreLane** - the RTL-to-GDSII flow engine
- **OpenROAD** - the place & route engine inside OpenLane
- **volare** - the PDK version manager
- **Sky130 PDK** - the open-source 130nm process from SkyWater/Google

The toolkit's value is the UX: a friendly installer, a standalone IP scaffold
(not coupled to a shuttle harness), standard RTL modules ready to use, and a
plain `make` interface.

## Resources

- [OpenLane 2 docs](https://openlane2.readthedocs.io/)
- [Sky130 PDK docs](https://skywater-pdk.readthedocs.io/)
- [Tiny Tapeout](https://tinytapeout.com/)
