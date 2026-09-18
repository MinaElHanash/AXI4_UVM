@echo off
set "TARGET_DIR=D:\DV HS\02 assignments\UVM_Project\Repo"

echo Navigating to %TARGET_DIR%...
cd /d "%TARGET_DIR%"
if errorlevel 1 (
    echo Error: Could not find directory "%TARGET_DIR%"
    pause
    exit /b
)

echo Creating directories...
mkdir rtl 2>nul
mkdir tb\interface 2>nul
mkdir tb\pkg 2>nul
mkdir tb\agent 2>nul
mkdir tb\env 2>nul
mkdir tb\sequences 2>nul
mkdir tb\tests 2>nul
mkdir sim 2>nul
mkdir reports 2>nul
mkdir docs 2>nul
mkdir artifacts 2>nul
mkdir scripts 2>nul

echo Moving files...
:: RTL
move axi4.v rtl\ >nul 2>&1
move axi_memory.v rtl\ >nul 2>&1

:: TB Interface
move AXI_if.sv tb\interface\ >nul 2>&1

:: TB Pkg
move AXI_pkg.sv tb\pkg\ >nul 2>&1
move AXI_transaction.sv tb\pkg\ >nul 2>&1

:: TB Agent
move AXI_agent.sv tb\agent\ >nul 2>&1
move AXI_driver.sv tb\agent\ >nul 2>&1
move AXI_monitor.sv tb\agent\ >nul 2>&1
move AXI_sequencer.sv tb\agent\ >nul 2>&1

:: TB Env
move AXI_env.sv tb\env\ >nul 2>&1
move AXI_scoreboard.sv tb\env\ >nul 2>&1
move AXI_coverage.sv tb\env\ >nul 2>&1
move AXI_assertions.sv tb\env\ >nul 2>&1

:: TB Sequences
move AXI_sequence.sv tb\sequences\ >nul 2>&1
move AXI_directed_sequence.sv tb\sequences\ >nul 2>&1

:: TB Tests
move AXI_test.sv tb\tests\ >nul 2>&1
move AXI_top.sv tb\tests\ >nul 2>&1

:: Sim
move run.do sim\ >nul 2>&1
move run.bat sim\ >nul 2>&1

:: Reports
move design_code_coverage.txt reports\ >nul 2>&1
move functional_coverage.txt reports\ >nul 2>&1
move assertion_coverage_report.txt reports\ >nul 2>&1
move full_coverage_report.txt reports\ >nul 2>&1

:: Docs
move AXI4_Memory_UVM_Project.pdf docs\ >nul 2>&1
move "AXI4_Memory_SV_Project (1).pdf" docs\ >nul 2>&1
move Mina_Shohdy_UVM_Project.pdf docs\ >nul 2>&1

:: Artifacts
move simulation.zip artifacts\ >nul 2>&1

:: Scripts
move organize_repo.sh scripts\ >nul 2>&1
move organize_repo.bat scripts\ >nul 2>&1

echo Repository organization complete!
pause