# ASIC Design Toolkit — Remaining Work

MVP is complete and merged. This file tracks Phase 2 and Phase 3 items.

---

## Phase 2 — Polish

Start after a newcomer can run all 5 steps end-to-end without hitting errors.

### 2.1 GTKWave session management

`make save-session` should write a `.gtkw` file that `make waves` auto-loads.
The stubs in `Makefile.sim` and `Makefile.sky130` already print instructions;
this phase wires them up properly.

- In `templates/Makefile.sim` and `templates/Makefile.sky130`: make
  `save-session` invoke GTKWave with `--dump` to produce a starter `.gtkw`,
  then `waves` should load `$(GTKW)` if it exists (already structured for it —
  just needs the save-session command to actually launch GTKWave).
- Copy the pattern from `fpga-design-toolkit` verbatim.

### 2.2 GF180 support

Add GlobalFoundries 180nm as a second tapeout target.

- Add `scripts/create_gf180_project.sh` (mirrors `create_sky130_project.sh`).
- Add `templates/config_gf180.json`:
  ```json
  {
      "PDK": "gf180mcuA",
      "DESIGN_NAME": "__DESIGN_NAME__",
      "VERILOG_FILES": ["rtl/*.v", "rtl/lib/*.v"],
      "CLOCK_PORT": "clk",
      "CLOCK_PERIOD": 20.0,
      "FP_SIZING": "absolute",
      "DIE_AREA": "0 0 300 300",
      "FP_CORE_UTIL": 40
  }
  ```
- Add `templates/Makefile.gf180` (mirrors `Makefile.sky130` with
  `PDK_ROOT` pointing to gf180mcuA).
- Add option 3 to `initiate_proj.sh` menu:
  `3) GF180 (180nm) - GlobalFoundries, higher voltage, automotive`.
- Add GF180 PDK install to `install_asic_tools.sh --mode=full` (optional,
  prompted after Sky130):
  ```bash
  volare enable --pdk gf180mcu --pdk-root "$PDK_ROOT" \
      $(python3 -m volare ls-remote --pdk gf180mcu | head -1)
  ```

### 2.3 `docs/` folder

Write plain-language guides after the flow is proven end-to-end.

```
docs/
├── quick-start.md        The 5-step journey in plain language
├── config-reference.md   OpenLane 2 JSON fields explained for newcomers
├── drc-fixes.md          Common DRC violations and how to fix them
├── wsl2-setup.md         Docker on WSL2 gotchas (Desktop vs Engine, --dockerized)
└── troubleshooting.md    PDK not found, OOM during P&R, Docker permission errors
```

### 2.4 README rewrite

README was rewritten in the MVP around the 5-step journey. This item is to
revisit it once the full flow (gds → view-gds) has been run on real hardware
and the docs/ folder exists, and add links to the new guides.

---

## Phase 3 — Nice to Have

Defer until Phase 2 is complete.

### 3.1 GitHub Actions CI

Lint RTL + run simulation on every push.

```yaml
# .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  sim:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get install -y iverilog
      - run: |
          ./initiate_proj.sh ci_test --sim
          cd ci_test && make sim
```

### 3.2 `make compare-pdks`

Run Sky130 + GF180 side by side and compare area and timing in a table.

- Requires GF180 support (Phase 2.2) to be done first.
- Add a `compare-pdks` target to `templates/Makefile.sky130` and
  `templates/Makefile.gf180` that calls both flows and prints a summary table
  with area (um²), timing slack (ns), and cell count.

### 3.3 LibreLane backend note

LibreLane (FOSSi Foundation) is the active successor to OpenLane 2 after
Efabless shut down. It is CLI-compatible — no code change is needed.

- Add a note to `docs/troubleshooting.md` (Phase 2.3) explaining that
  `pip install librelane` can replace `pip install openlane` and the
  `--dockerized` flag and config format are identical.
- Monitor LibreLane releases; if it becomes the clear standard, update
  `install_asic_tools.sh --mode=full` to install LibreLane instead of
  OpenLane 2 (or let the user choose).

---

## Testing protocol (for each Phase 2/3 item)

```bash
# After touching any template or create script, always run:
cd /tmp && rm -rf t && mkdir t && cd t
bash <toolkit>/initiate_proj.sh demo --sim
cd demo && make sim     # must end with "ALL TESTS PASSED"

# For Sky130 / GF180 changes, also check:
python3 -c "import json; json.load(open('config/config.json'))"
make -n gds | grep -q "openlane --dockerized"
```
