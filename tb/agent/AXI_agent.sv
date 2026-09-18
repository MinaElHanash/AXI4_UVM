package AXI_agent_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import AXI_transaction_pkg::*;
    import AXI_monitor_pkg::*;
    import AXI_sequencer_pkg::*;
    import AXI_driver_pkg::*;

    class AXI_agent extends uvm_agent;

        `uvm_component_utils(AXI_agent)

        AXI_monitor   mon;
        AXI_sequencer sqr;
        AXI_driver    drv;

        uvm_analysis_port #(AXI_transaction) ap; 

        uvm_active_passive_enum is_active = UVM_ACTIVE;

        function new(string name = "AXI_agent", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(), "AXI agent build phase", UVM_LOW)

            if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
                `uvm_warning(get_type_name(), "is_active not found in config_db, defaulting to UVM_ACTIVE")
            
            `uvm_info(get_type_name(), $sformatf("Agent type is %s", is_active.name()), UVM_LOW)

            mon = AXI_monitor::type_id::create("mon", this);

            ap = new("ap", this);

            if (is_active == UVM_ACTIVE) begin
                sqr = AXI_sequencer::type_id::create("sqr", this);
                drv = AXI_driver::type_id::create("drv", this);
            end
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            mon.ap.connect(this.ap);

            if (is_active == UVM_ACTIVE) begin
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
        endfunction

    endclass // AXI_agent

endpackage