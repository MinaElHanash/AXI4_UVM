package AXI_env_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import AXI_scoreboard_pkg::*;
    import AXI_coverage_pkg::*;
    import AXI_agent_pkg::*;

    class AXI_env extends uvm_env;
        `uvm_component_utils(AXI_env)

        AXI_scoreboard scb;
        AXI_coverage cov;
        AXI_agent agt;

        function new(string name = "AXI_env", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            scb = AXI_scoreboard::type_id::create("AXI_scb", this);
            cov = AXI_coverage::type_id::create("AXI_cov", this);
            agt = AXI_agent::type_id::create("AXI_agt", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            agt.ap.connect(scb.ap_imp);

            agt.ap.connect(cov.ap_imp);
        endfunction

    endclass
endpackage