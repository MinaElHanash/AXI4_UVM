vlib work

transcript file simulation.log

# 1. Compile with full coverage and assertion flags enabled
vlog +cover=bcesft -covercells -assertdebug \
    axi_memory.v \
    axi4.v \

vlog -assertdebug \
    AXI_if.sv \
    AXI_assertions.sv \
    AXI_transaction.sv \
    AXI_sequence.sv \
    AXI_directed_sequence.sv \
    AXI_sequencer.sv \
    AXI_driver.sv \
    AXI_monitor.sv \
    AXI_agent.sv \
    AXI_coverage.sv \
    AXI_scoreboard.sv \
    AXI_env.sv \
    AXI_test.sv \
    AXI_pkg.sv \
    AXI_top.sv

# 2. Simulate with full coverage, assertion tracking, AND -onfinish stop
vsim -voptargs="+acc" -coverage -cvgperinstance -assertdebug -onfinish stop work.AXI_top

# Exclude bits tied to 0 from toggle coverage
coverage exclude -togglenode /AXI_top/AXI_vif/AWADDR[31:16]
coverage exclude -togglenode /AXI_top/AXI_vif/AWADDR[1:0]
coverage exclude -togglenode /AXI_top/AXI_vif/AWSIZE[2]
coverage exclude -togglenode /AXI_top/AXI_vif/AWSIZE[0]
# (Repeat for ARADDR, ARSIZE, BRESP[0], and RRESP[0])

# 3. Add only the AXI interface signals observed by the monitor and open window
add wave -noupdate -radix hexadecimal /AXI_top/AXI_vif/*
view wave
run 0

# 4. Run all transactions
run -all

# 5. Save coverage database
coverage save coverage_report.ucdb

# 6. Generate all coverage and assertion reports
coverage report -detail -cvg -file functional_coverage.txt
coverage report -detail -code bcesft -file design_code_coverage.txt
coverage report -detail -assert -file assertion_coverage_report.txt
coverage report -detail -file full_coverage_report.txt