package AXI_sequence_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import AXI_transaction_pkg::*;

    class AXI_sequence extends uvm_sequence;

        `uvm_object_utils(AXI_sequence)

        function new(string name = "AXI_sequence");
            super.new(name);
        endfunction //new()

        task body();

            AXI_transaction req;

            repeat(10000) begin
                req = AXI_transaction::type_id::create("req");
                start_item(req);
                    assert(req.randomize());
                    `uvm_info(get_type_name(), {"data randomized", req.sprint()}, UVM_MEDIUM)
                finish_item(req);
            end

        endtask
        
    endclass //AXI_sequence extends uvm_sequence
    
endpackage