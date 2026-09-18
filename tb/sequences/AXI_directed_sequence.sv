package AXI_directed_sequence_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import AXI_transaction_pkg::*;

    class AXI_directed_sequence extends uvm_sequence #(AXI_transaction);

        `uvm_object_utils(AXI_directed_sequence)

        function new(string name = "AXI_directed_sequence");
            super.new(name);
        endfunction

        // Helper task to process the configured transaction
        task send_txn(AXI_transaction txn, string msg);
            `uvm_info(get_type_name(), $sformatf("Executing Directed Case: %s", msg), UVM_LOW)
            start_item(txn);
            finish_item(txn);
        endtask

        task body();
            AXI_transaction txn;
            
            // 1. Lower Bound Write
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b1; txn.ARVALID = 1'b0;
            txn.AWADDR = 16'd0; txn.AWLEN = 8'd0; txn.AWSIZE = 3'd2;
            txn.WDATA = new[1]; txn.WDATA[0] = 32'hA5A5_0001;
            send_txn(txn, "DIR_LOWER_BOUND_WR");

            // 2. Lower Bound Read
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b0; txn.ARVALID = 1'b1;
            txn.ARADDR = 16'd0; txn.ARLEN = 8'd0; txn.ARSIZE = 3'd2;
            send_txn(txn, "DIR_LOWER_BOUND_RD");

            // 3. Upper Bound Write
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b1; txn.ARVALID = 1'b0;
            txn.AWADDR = 16'd4092; txn.AWLEN = 8'd0; txn.AWSIZE = 3'd2;
            txn.WDATA = new[1]; txn.WDATA[0] = 32'hDEAD_BEEF;
            send_txn(txn, "DIR_UPPER_BOUND_WR");

            // 4. Upper Bound Read
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b0; txn.ARVALID = 1'b1;
            txn.ARADDR = 16'd4092; txn.ARLEN = 8'd0; txn.ARSIZE = 3'd2;
            send_txn(txn, "DIR_UPPER_BOUND_RD");

            // 5. Exact 4KB Max Burst Write
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b1; txn.ARVALID = 1'b0;
            txn.AWADDR = 16'd3072; txn.AWLEN = 8'd255; txn.AWSIZE = 3'd2;
            txn.WDATA = new[256];
            foreach (txn.WDATA[k]) txn.WDATA[k] = k + 1;
            send_txn(txn, "DIR_4KB_EXACT_WR");

            // 6. Out of Bounds Write
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b1; txn.ARVALID = 1'b0;
            txn.AWADDR = 16'hF000; txn.AWLEN = 8'd0; txn.AWSIZE = 3'd2;
            txn.WDATA = new[1]; txn.WDATA[0] = 32'hBAAD_F00D;
            send_txn(txn, "DIR_OUT_OF_BOUNDS_WR");

            // 7. Out of Bounds Read
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b0; txn.ARVALID = 1'b1;
            txn.ARADDR = 16'hF000; txn.ARLEN = 8'd0; txn.ARSIZE = 3'd2;
            send_txn(txn, "DIR_OUT_OF_BOUNDS_RD");

            // 8. Illegal Boundary Cross Write
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b1; txn.ARVALID = 1'b0;
            txn.AWADDR = 16'd4092; txn.AWLEN = 8'd1; txn.AWSIZE = 3'd2;
            txn.WDATA = new[2]; txn.WDATA[0] = 32'h1; txn.WDATA[1] = 32'h2;
            send_txn(txn, "DIR_ILLEGAL_CROSS_WR");

            // 9. Data Integrity Write
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b1; txn.ARVALID = 1'b0;
            txn.AWADDR = 16'h0100; txn.AWLEN = 8'd3; txn.AWSIZE = 3'd2;
            txn.WDATA = new[4];
            foreach (txn.WDATA[k]) txn.WDATA[k] = 32'h55AA_0000 + k;
            send_txn(txn, "DIR_WRITE_CHECK");

            // 10. Data Integrity Read Same Address
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b0; txn.ARVALID = 1'b1;
            txn.ARADDR = 16'h0100; txn.ARLEN = 8'd3; txn.ARSIZE = 3'd2;
            send_txn(txn, "DIR_READ_CHECK");

            // 11. Illegal Boundary Cross Read
            txn = AXI_transaction::type_id::create("txn");
            txn.AWVALID = 1'b0; txn.ARVALID = 1'b1;
            txn.ARADDR = 16'd4092; txn.ARLEN = 8'd1; txn.ARSIZE = 3'd2;
            send_txn(txn, "DIR_ILLEGAL_CROSS_RD");

            // -------------------------------------------------------------------------
            // Sweep Burst Lengths at Lower Bound (Address 0) to close Coverage Bins
            // -------------------------------------------------------------------------
            for (int i = 0; i < 256; i += 16) begin
                // 1. Write Sweep
                req = AXI_transaction::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {
                    AWVALID == 1'b1;
                    ARVALID == 1'b0;
                    AWADDR == 0;
                    AWLEN == i;
                });
                finish_item(req);

                // 2. Read Sweep
                req = AXI_transaction::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {
                    AWVALID == 1'b0;
                    ARVALID == 1'b1;
                    ARADDR == 0;
                    ARLEN == i;
                });
                finish_item(req);
            end
        endtask
        
    endclass
    
endpackage