package AXI_monitor_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import AXI_transaction_pkg::*; 

    class AXI_monitor extends uvm_monitor;
        `uvm_component_utils(AXI_monitor)

        virtual AXI_if vif;
        uvm_analysis_port #(AXI_transaction) ap;

        function new(string name = "AXI_monitor", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual AXI_if)::get(this, "", "vif", vif)) begin
                `uvm_fatal(get_type_name(), "Failed to get virtual interface in monitor")
            end
            
            ap = new("ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            // Wait for reset to complete before monitoring
            wait(vif.ARESETn === 1'b1);

            // Run Write and Read monitoring threads completely independent of each other
            fork
                monitor_write_channel();
                monitor_read_channel();
            join
        endtask

        // ==========================================
        // Write Channel Monitoring Thread
        // ==========================================
        task monitor_write_channel();
            AXI_transaction write_tx;
            logic [31:0] wdata_queue[$];
            
            forever begin
                write_tx = AXI_transaction::type_id::create("write_tx");
                wdata_queue.delete();
                
                // AXI allows address and data to arrive out of order or in parallel.
                // Forking them guarantees we catch both regardless of the driver's timing.
                fork
                    // 1. Capture Write Address (AW)
                    begin
                        do begin
                            @(posedge vif.ACLK);
                        end while (!(vif.AWVALID && vif.AWREADY)); // Transfer occurs when both are HIGH
                        
                        write_tx.AWADDR  = vif.AWADDR;
                        write_tx.AWLEN   = vif.AWLEN;
                        write_tx.AWSIZE  = vif.AWSIZE;
                        write_tx.AWVALID = 1'b1;
                    end

                    // 2. Capture Write Data (W)
                    begin
                        bit last_beat = 0;
                        while (!last_beat) begin
                            @(posedge vif.ACLK);
                            if (vif.WVALID && vif.WREADY) begin // Transfer occurs when both are HIGH
                                wdata_queue.push_back(vif.WDATA);
                                if (vif.WLAST) begin
                                    last_beat = 1;
                                end
                            end
                        end
                        
                        // Copy queued data into the transaction dynamic array
                        write_tx.WDATA = new[wdata_queue.size()];
                        foreach (wdata_queue[i]) write_tx.WDATA[i] = wdata_queue[i];
                    end
                join

                // 3. Capture Write Response (B)
                do begin
                    @(posedge vif.ACLK);
                end while (!(vif.BVALID && vif.BREADY)); // Transfer occurs when both are HIGH
                
                write_tx.BRESP = vif.BRESP;

                // Broadcast completed write transaction
                `uvm_info(get_type_name(), "Write Transaction Monitored", UVM_HIGH)
                ap.write(write_tx);
            end
        endtask

        // ==========================================
        // Read Channel Monitoring Thread
        // ==========================================
        task monitor_read_channel();
            AXI_transaction read_tx;
            logic [31:0] rdata_queue[$];

            forever begin
                read_tx = AXI_transaction::type_id::create("read_tx");
                rdata_queue.delete();

                // 1. Capture Read Address (AR)
                do begin
                    @(posedge vif.ACLK);
                end while (!(vif.ARVALID && vif.ARREADY)); // Transfer occurs when both are HIGH
                
                read_tx.ARADDR  = vif.ARADDR;
                read_tx.ARLEN   = vif.ARLEN;
                read_tx.ARSIZE  = vif.ARSIZE;
                read_tx.ARVALID = 1'b1;

                // 2. Capture Read Data (R)
                begin
                    bit last_beat = 0;
                    while (!last_beat) begin
                        @(posedge vif.ACLK);
                        if (vif.RVALID && vif.RREADY) begin // Transfer occurs when both are HIGH
                            rdata_queue.push_back(vif.RDATA);
                            read_tx.RRESP = vif.RRESP; 
                            if (vif.RLAST) begin
                                last_beat = 1;
                            end
                        end
                    end
                    
                    // Note: Ensure RDATA in AXI_transaction.sv is updated to: logic [DATA_WIDTH-1:0] RDATA[];
                    read_tx.RDATA = new[rdata_queue.size()];
                    foreach (rdata_queue[i]) read_tx.RDATA[i] = rdata_queue[i];
                end

                // Broadcast completed read transaction
                `uvm_info(get_type_name(), "Read Transaction Monitored", UVM_HIGH)
                ap.write(read_tx);
            end
        endtask

    endclass
endpackage