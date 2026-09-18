package AXI_scoreboard_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import AXI_transaction_pkg::*;

    class AXI_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(AXI_scoreboard)

        uvm_analysis_imp #(AXI_transaction, AXI_scoreboard) ap_imp;

        // Golden memory model (Associative array to handle sparse 4KB space)
        logic [31:0] golden_mem [int];

        function new(string name = "AXI_scoreboard", uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            ap_imp = new("ap_imp", this);
        endfunction

        virtual function void write(AXI_transaction tx);
            
            // ==========================================
            // 1. Process Write Transactions
            // ==========================================
            if (tx.AWVALID) begin
                // Check AXI4 Rules
                bit boundary_cross = ((tx.AWADDR & 12'hFFF) + (tx.AWLEN << tx.AWSIZE)) > 12'hFFF;
                bit addr_valid     = (tx.AWADDR >> 2) < 1024; // 1024 depth
                
                if (!addr_valid || boundary_cross) begin
                    if (tx.BRESP !== 2'b10) begin
                        `uvm_error("SCB_FAIL", $sformatf("Expected SLVERR (2'b10) for invalid write at 0x%0h, got %0b", tx.AWADDR, tx.BRESP))
                    end else begin
                        `uvm_info("SCB_PASS", $sformatf("Correct SLVERR for invalid write at 0x%0h", tx.AWADDR), UVM_HIGH)
                    end
                end 
                else begin
                    if (tx.BRESP !== 2'b00) begin
                        `uvm_error("SCB_FAIL", $sformatf("Expected OKAY (2'b00) for valid write at 0x%0h, got %0b", tx.AWADDR, tx.BRESP))
                    end else begin
                        // Update Golden Memory for each beat in the burst
                        for (int i = 0; i <= tx.AWLEN; i++) begin
                            int byte_offset = i * (1 << tx.AWSIZE);
                            int word_addr   = (tx.AWADDR + byte_offset) >> 2;
                            golden_mem[word_addr] = tx.WDATA[i];
                        end
                        `uvm_info("SCB_PASS", $sformatf("Golden memory updated for write burst at 0x%0h", tx.AWADDR), UVM_HIGH)
                    end
                end
            end

            // ==========================================
            // 2. Process Read Transactions
            // ==========================================
            if (tx.ARVALID) begin
                // Check AXI4 Rules
                bit boundary_cross = ((tx.ARADDR & 12'hFFF) + (tx.ARLEN << tx.ARSIZE)) > 12'hFFF;
                bit addr_valid     = (tx.ARADDR >> 2) < 1024; // 1024 depth
                
                if (!addr_valid || boundary_cross) begin
                    if (tx.RRESP !== 2'b10) begin
                        `uvm_error("SCB_FAIL", $sformatf("Expected SLVERR (2'b10) for invalid read at 0x%0h, got %0b", tx.ARADDR, tx.RRESP))
                    end
                    // The DUT is expected to return 0 for RDATA on errors
                    foreach(tx.RDATA[i]) begin
                        if (tx.RDATA[i] !== 32'h0) begin
                            `uvm_error("SCB_FAIL", $sformatf("Expected RDATA=0 for invalid read, got %0h", tx.RDATA[i]))
                        end
                    end
                end 
                else begin
                    if (tx.RRESP !== 2'b00) begin
                        `uvm_error("SCB_FAIL", $sformatf("Expected OKAY (2'b00) for valid read at 0x%0h, got %0b", tx.ARADDR, tx.RRESP))
                    end else begin
                        // Verify each beat against Golden Memory
                        for (int i = 0; i <= tx.ARLEN; i++) begin
                            int byte_offset = i * (1 << tx.ARSIZE);
                            int word_addr   = (tx.ARADDR + byte_offset) >> 2;
                            
                            // If memory location was never written to, default is 0
                            logic [31:0] exp_data = golden_mem.exists(word_addr) ? golden_mem[word_addr] : 32'h0;
                            
                            if (tx.RDATA[i] !== exp_data) begin
                                `uvm_error("SCB_FAIL", $sformatf("Read mismatch at word addr %0d. Expected: %0h, Actual: %0h", word_addr, exp_data, tx.RDATA[i]))
                            end
                        end
                        `uvm_info("SCB_PASS", $sformatf("Successfully verified read burst from 0x%0h", tx.ARADDR), UVM_HIGH)
                    end
                end
            end
            
        endfunction

    endclass
endpackage