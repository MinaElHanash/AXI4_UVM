# AXI4 UVM Verification Project

A SystemVerilog/UVM verification environment for a parameterized AXI4 memory slave. The repository contains the AXI4 RTL design, a UVM testbench, protocol assertions, functional/code/assertion coverage, simulation scripts, and project documentation.

## Project goals

- Verify AXI4 write-address, write-data, write-response, read-address, and read-data channels.
- Exercise single-beat and burst transfers.
- Verify aligned accesses, 4 KiB boundary behavior, and out-of-range accesses.
- Check returned data against a scoreboard golden-memory model.
- Collect functional, code, assertion, and coverage reports.
- Exercise reset behavior, including a mid-test reset.

## Repository layout

```text
AXI4_UVM/
├── README.md
├── rtl/
│   ├── axi4.v
│   └── axi_memory.v
├── tb/
│   ├── interface/
│   │   └── AXI_if.sv
│   ├── pkg/
│   │   ├── AXI_pkg.sv
│   │   └── AXI_transaction.sv
│   ├── agent/
│   │   ├── AXI_agent.sv
│   │   ├── AXI_driver.sv
│   │   ├── AXI_monitor.sv
│   │   └── AXI_sequencer.sv
│   ├── env/
│   │   ├── AXI_env.sv
│   │   ├── AXI_scoreboard.sv
│   │   ├── AXI_coverage.sv
│   │   └── AXI_assertions.sv
│   ├── sequences/
│   │   ├── AXI_sequence.sv
│   │   └── AXI_directed_sequence.sv
│   └── tests/
│       ├── AXI_test.sv
│       └── AXI_top.sv
├── sim/
│   ├── run.do
│   └── run.bat
├── reports/
│   ├── design_code_coverage.txt
│   ├── functional_coverage.txt
│   ├── assertion_coverage_report.txt
│   └── full_coverage_report.txt
├── docs/
│   ├── AXI4_Memory_UVM_Project.pdf
│   ├── AXI4_Memory_SV_Project (1).pdf
│   └── Mina_Shohdy_UVM_Project.pdf
├── artifacts/
│   └── simulation.zip
└── scripts/
    ├── organize_repo.sh
    └── organize_repo.bat
```

The repository currently contains the original flat files at its root. Run one of the organization scripts once to move them into the layout above. The scripts use `git mv`, preserve history, update the ModelSim/QuestaSim paths in `sim/run.do`, and remove the now-empty root-level source copies.

## Design under test

The DUT is `rtl/axi4.v`, an AXI4-style memory slave with:

- 32-bit data and address configuration in the testbench.
- 1024 word memory depth.
- Independent write and read finite-state machines.
- Write response checking using `OKAY` (`2'b00`) and `SLVERR` (`2'b10`).
- Read data and response generation.
- 4 KiB boundary and memory-range checks.
- `rtl/axi_memory.v` as the underlying word-addressed memory model.

The default top-level configuration is set in `tb/tests/AXI_top.sv`:

- `DATA_WIDTH = 32`
- `ADDR_WIDTH = 32`
- `MEMORY_DEPTH = 1024`
- Clock period = 10 ns

## UVM testbench

The testbench is built from the following components:

- `AXI_if.sv`: AXI signal interface.
- `AXI_transaction.sv`: sequence item, fields, dynamic burst data arrays, and constraints.
- `AXI_driver.sv`: drives write and read channel handshakes and reacts to reset.
- `AXI_monitor.sv`: observes completed write and read transactions and publishes them through an analysis port.
- `AXI_sequencer.sv`: supplies transactions to the driver.
- `AXI_agent.sv`: contains the sequencer, driver, monitor, and analysis port.
- `AXI_env.sv`: connects the agent to the scoreboard and coverage collector.
- `AXI_scoreboard.sv`: maintains a golden memory model and checks responses/data.
- `AXI_coverage.sv`: samples address, burst-length, boundary, and response coverage.
- `AXI_assertions.sv`: checks signal stability and known-value requirements while valid is asserted.
- `AXI_sequence.sv`: generates 10,000 constrained-random transactions.
- `AXI_directed_sequence.sv`: tests lower/upper bounds, maximum bursts, invalid accesses, boundary crossings, and data integrity.
- `AXI_test.sv`: starts the random and directed sequences and injects a mid-test reset.
- `AXI_top.sv`: instantiates the DUT/interface, binds assertions, generates clock/reset, configures the UVM virtual interface, and calls `run_test`.

## Directed scenarios

The directed sequence covers:

1. Lower-bound write/read.
2. Upper-bound write/read.
3. Exact 4 KiB maximum burst.
4. Out-of-bounds write/read.
5. Illegal 4 KiB boundary-crossing write/read.
6. Multi-beat data-integrity write/read.
7. Burst-length sweep at address zero.

## Running the simulation

### Prerequisites

- QuestaSim/ModelSim with SystemVerilog, UVM, assertion, and coverage support.
- A valid `questa`/`vsim` installation available on the machine.
- The UVM library configured for the simulator.

### Windows

From the repository root:

```bat
sim\\run.bat
```

Update the QuestaSim executable path in `sim/run.bat` if it differs from the path used by the original project.

### QuestaSim command line

```tcl
cd sim
do run.do
```

The simulation script creates `work`, compiles the RTL and testbench, runs `work.AXI_top`, saves `coverage_report.ucdb`, and writes reports under `reports/`.

## Generated outputs

- `simulation.log`: simulator transcript.
- `coverage_report.ucdb`: QuestaSim coverage database.
- `reports/functional_coverage.txt`: functional coverage report.
- `reports/design_code_coverage.txt`: branch, condition, expression, statement, and toggle coverage report.
- `reports/assertion_coverage_report.txt`: assertion coverage report.
- `reports/full_coverage_report.txt`: combined detailed report.

Generated simulator directories and databases should normally not be committed unless they are intentionally being distributed as artifacts.

## Notes and limitations

- The project is written for QuestaSim/ModelSim and the run scripts contain simulator-specific commands.
- `run.bat` originally contains a machine-specific absolute path; update it for your installation.
- The DUT and assertion module use some fixed-width protocol signals while the interface and transaction are parameterized. Keep widths consistent if changing the default configuration.
- The project is an educational AXI4 verification environment rather than a complete production AXI4 implementation. Review protocol behavior before reusing it in silicon or production IP verification.

## License

No license file is currently included. Add a license before distributing the project or incorporating it into another project.
