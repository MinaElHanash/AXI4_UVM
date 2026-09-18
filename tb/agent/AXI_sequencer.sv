package AXI_sequencer_pkg;

     import uvm_pkg::*;
    `include "uvm_macros.svh"

    import AXI_transaction_pkg::*;

    class AXI_sequencer extends uvm_sequencer #(AXI_transaction);

        `uvm_component_utils(AXI_sequencer)

         function new(string name = "AXI_sqquencer", uvm_component parent);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(), "AXI sequencer build phase", UVM_LOW)
        endfunction
    endclass //AXI_sequencer extends uvm_sequencer

    
endpackage