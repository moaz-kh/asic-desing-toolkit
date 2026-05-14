# CLAUDE.md

Guidance for working in this repository.

## What this repo is

The ASIC Design Toolkit: a UX layer over the open-source RTL-to-GDSII flow.
It is **not** an EDA flow - it wraps OpenLane 2, volare, and the Sky130 PDK.
Everything is organized around one user journey: clone → setup → drop in RTL →
`make sim` → `make synth`/`make gds`.

## Repo layout

```
install_asic_tools.sh      Tool installer (--mode=sim / --mode=full)
initiate_proj.sh           Project generator - 2-question dispatcher
scripts/
  create_sim_project.sh    Generates a simulation-only project
  create_sky130_project.sh Generates a Sky130 RTL-to-GDSII project
templates/                 Files copied/substituted into generated projects
  lib/*.v                  Standard RTL modules, copied verbatim
  design_stub.v            Example design  (__DESIGN_NAME__ placeholder)
  testbench_stub.v         Example testbench
  config.json              OpenLane 2 config
  Makefile.sim             Makefile for sim-only projects
  Makefile.sky130          Makefile for Sky130 projects
```

Generated projects use `__DESIGN_NAME__` substituted via `sed`.

## Hard rules

- **OpenLane 2 only.** Never use OpenLane 1 (`efabless/openlane` Docker image +
  `./flow.tcl`). The flow is `pip install openlane` + `openlane --dockerized`.
- **PDKs via volare**, never git-cloned. They live in `~/.asic-toolkit/pdks`.
- **Support native Linux and WSL2.** Detect the environment; never hard-fail
  on native Linux.

## Shell conventions

- `set -euo pipefail` at the top of every script.
- `readonly` for configuration constants.
- `log_info` / `log_warn` / `log_error` with ANSI color codes.
- `is_yes` / `is_no` helpers accept `y/Y/yes/YES/n/N/no/NO`.
- Interactive menus use a `while true; do read ...; case ...; break; done` loop.

## RTL conventions (for templates/lib and stubs)

- Active-low resets named `rst_n`; clock named `clk`.
- Sequential logic: `always @(posedge clk or negedge rst_n)`.
- Parameterize widths/depths; no magic numbers.
- One comment block per module explaining *why* / when to use it - not what
  each line does.

## Testing changes

After touching templates or the create scripts, regenerate and simulate:

```bash
cd /tmp && rm -rf t && mkdir t && cd t
bash <toolkit>/initiate_proj.sh demo --sim
cd demo && make sim          # must end with "ALL TESTS PASSED"
```

For Sky130 changes, also check `config/config.json` is valid JSON and
`make -n gds` expands to an `openlane --dockerized` command.

## Roadmap

MVP (done): installer, project generators, standard modules, sim + Sky130
Makefiles. Phase 2: GTKWave session management, GF180 support, `docs/` folder.
Phase 3: CI, `make compare-pdks`, LibreLane backend notes.
