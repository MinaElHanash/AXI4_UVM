package AXI_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import AXI_env_pkg::*;
    import AXI_sequence_pkg::*;
    import AXI_directed_sequence_pkg::*;

    class AXI_test extends uvm_test;

        `uvm_component_utils(AXI_test)
        
        AXI_env env;
        AXI_sequence seq;
        AXI_directed_sequence dir_seq;

        function new(string name = "AXI_test", uvm_component parent);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env=AXI_env::type_id::create("env", this);
            seq=AXI_sequence::type_id::create("seq");
            dir_seq=AXI_directed_sequence::type_id::create("dir_seq");

            `uvm_info(get_type_name(), "AXI test build phase", UVM_LOW)
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            uvm_top.print_topology();
        endfunction

        task run_phase(uvm_phase phase);
            virtual AXI_if vif;
            
            if(!uvm_config_db#(virtual AXI_if)::get(this, "", "vif", vif))
                `uvm_fatal("TEST", "Failed to get virtual interface")

            phase.raise_objection(this);
            
            // 1. Spawns the reset thread in the background and moves on immediately
            fork
                begin
                    #15000ns; 
                    `uvm_info(get_type_name(), "Injecting mid-test reset", UVM_LOW)
                    vif.ARESETn = 0;
                    #10ns;
                    vif.ARESETn = 1;
                end
            join_none 
            
            // 2. Main thread stays blocked here until BOTH sequences finish completely
            `uvm_info(get_type_name(), "starting random AXI sequence", UVM_LOW)
            seq.start(env.agt.sqr);
            #10ns;
            
            `uvm_info(get_type_name(), "starting directed AXI sequence", UVM_LOW)
            dir_seq.start(env.agt.sqr);
            #10ns;
            
            // 3. Objection drops only when all transactions are done
            phase.drop_objection(this);
        endtask

    endclass //AXI_test extends uvm_test

endpackage