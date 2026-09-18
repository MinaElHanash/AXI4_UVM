package AXI_driver_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import AXI_transaction_pkg::*;

    class AXI_driver extends uvm_driver #(AXI_transaction);

        `uvm_component_utils(AXI_driver)

        virtual AXI_if vif;
        AXI_transaction req;

        function new(string name = "AXI_driver", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual AXI_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal(get_type_name(), "Failed to get virtual interface in AXI_driver")
            end
        endfunction

        task run_phase(uvm_phase phase);
            // 1. Initial default state at simulation time 0
            reset_signals();
            req = null;

            forever begin
                // 2. Wait until we are completely out of reset BEFORE starting
                wait(vif.ARESETn === 1'b1);

                fork
                    // Thread 1: Watch for a NEW mid-operation reset
                    begin
                        @(negedge vif.ARESETn);
                    end

                    // Thread 2: Normal driving loop
                    begin
                        forever begin
                            seq_item_port.get_next_item(req);
                            
                            if (req.AWVALID) drive_write(req);
                            if (req.ARVALID) drive_read(req);
                            
                            seq_item_port.item_done();
                            req = null; // Clear req to indicate it finished cleanly
                        end
                    end
                join_any

                // 3. If we reach here, a negedge reset triggered Thread 1
                disable fork;    // Kill the driving thread immediately

                // 4. Clean up sequencer state if a transaction was interrupted
                if (req != null) begin
                    seq_item_port.item_done();
                    req = null;
                end
            end
        endtask

        // Separate task for reset signaling
        task reset_signals();
            vif.AWVALID <= 1'b0;
            vif.AWADDR  <= '0;
            vif.AWLEN   <= '0;
            vif.AWSIZE  <= '0;
            vif.WVALID  <= 1'b0;
            vif.WDATA   <= '0;
            vif.WLAST   <= 1'b0;
            vif.BREADY  <= 1'b0;
            vif.ARVALID <= 1'b0;
            vif.ARADDR  <= '0;
            vif.ARLEN   <= '0;
            vif.ARSIZE  <= '0;
            vif.RREADY  <= 1'b0;
        endtask

        task drive_write(AXI_transaction req);
            // 1. Write Address Channel
            @(negedge vif.ACLK);
            vif.AWADDR  <= req.AWADDR;
            vif.AWLEN   <= req.AWLEN;
            vif.AWSIZE  <= req.AWSIZE;
            vif.AWVALID <= 1'b1;

            do begin
                @(posedge vif.ACLK);
            end while (!vif.AWREADY);

            @(negedge vif.ACLK);
            vif.AWVALID <= 1'b0;

            // 2. Write Data Channel
            for (int i = 0; i <= req.AWLEN; i++) begin
                int wait_cycles = $urandom_range(0, 2); // Randomize inter-beat gap
                
                // If there is a gap before the next beat, WVALID must be LOW
                if (wait_cycles > 0) begin
                    @(negedge vif.ACLK);
                    vif.WVALID <= 1'b0; 
                    repeat (wait_cycles) @(posedge vif.ACLK);
                end

                // Drive valid data and assert WVALID simultaneously
                @(negedge vif.ACLK);
                vif.WDATA  <= req.WDATA[i];
                vif.WLAST  <= (i == req.AWLEN) ? 1'b1 : 1'b0; // Assert WLAST on final transfer
                vif.WVALID <= 1'b1;

                // WVALID remains asserted until WREADY is HIGH
                do begin
                    @(posedge vif.ACLK);
                end while (!vif.WREADY);
            end

            // End of burst: pull WVALID and WLAST low
            @(negedge vif.ACLK);
            vif.WVALID <= 1'b0;
            vif.WLAST  <= 1'b0;

            // 3. Write Response Channel
            vif.BREADY <= 1'b0;
            repeat($urandom_range(0, 5)) @(posedge vif.ACLK); // Add delay to hit 100% on code coverage
            vif.BREADY <= 1'b1;

            do begin
                @(posedge vif.ACLK);
            end while (!vif.BVALID);

            @(negedge vif.ACLK);
            vif.BREADY <= 1'b0; // Deassert after completion
        endtask

        task drive_read(AXI_transaction req);
            // 1. Read Address Channel
            @(negedge vif.ACLK);
            vif.ARADDR  <= req.ARADDR;
            vif.ARLEN   <= req.ARLEN;
            vif.ARSIZE  <= req.ARSIZE;
            vif.ARVALID <= 1'b1;

            do begin
                @(posedge vif.ACLK);
            end while (!vif.ARREADY);

            @(negedge vif.ACLK);
            vif.ARVALID <= 1'b0;

            // 2. Read Data Channel
            for (int i = 0; i <= req.ARLEN; i++) begin
                vif.RREADY <= 1'b0;
                repeat($urandom_range(0, 5)) @(posedge vif.ACLK); // Add delay to hit 100% on code coverage
                vif.RREADY <= 1'b1;
                
                do begin
                    @(posedge vif.ACLK);
                end while (!vif.RVALID);
            end
            
            @(negedge vif.ACLK);
            vif.RREADY <= 1'b0; // Deassert after burst completion
        endtask

    endclass

endpackage