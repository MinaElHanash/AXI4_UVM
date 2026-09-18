`include "uvm_macros.svh"
import uvm_pkg::*;
import AXI_pkg::*;

module AXI_top ();

    // 1. Instantiate the Interface
    AXI_if AXI_vif();

    // 2. Instantiate the AXI4 DUT (Updated width parameters to match 32-bit addresses)
    axi4 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .MEMORY_DEPTH(1024)
    ) DUT (
        .ACLK    (AXI_vif.ACLK),
        .ARESETn (AXI_vif.ARESETn),
        
        // Write Address Channel
        .AWADDR  (AXI_vif.AWADDR),
        .AWLEN   (AXI_vif.AWLEN),
        .AWSIZE  (AXI_vif.AWSIZE),
        .AWVALID (AXI_vif.AWVALID),
        .AWREADY (AXI_vif.AWREADY),
        
        // Write Data Channel
        .WDATA   (AXI_vif.WDATA),
        .WVALID  (AXI_vif.WVALID),
        .WLAST   (AXI_vif.WLAST),
        .WREADY  (AXI_vif.WREADY),
        
        // Write Response Channel
        .BRESP   (AXI_vif.BRESP),
        .BVALID  (AXI_vif.BVALID),
        .BREADY  (AXI_vif.BREADY),
        
        // Read Address Channel
        .ARADDR  (AXI_vif.ARADDR),
        .ARLEN   (AXI_vif.ARLEN),
        .ARSIZE  (AXI_vif.ARSIZE),
        .ARVALID (AXI_vif.ARVALID),
        .ARREADY (AXI_vif.ARREADY),
        
        // Read Data Channel
        .RDATA   (AXI_vif.RDATA),
        .RRESP   (AXI_vif.RRESP),
        .RVALID  (AXI_vif.RVALID),
        .RLAST   (AXI_vif.RLAST),
        .RREADY  (AXI_vif.RREADY)
    );

    bind DUT AXI_assertions AXI_assert_inst (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),
        .AWADDR  (AWADDR),
        .AWLEN   (AWLEN),
        .AWSIZE  (AWSIZE),
        .AWVALID (AWVALID),
        .AWREADY (AWREADY),
        .WDATA   (WDATA),
        .WVALID  (WVALID),
        .WLAST   (WLAST),
        .WREADY  (WREADY),
        .BRESP   (BRESP),
        .BVALID  (BVALID),
        .BREADY  (BREADY),
        .ARADDR  (ARADDR),
        .ARLEN   (ARLEN),
        .ARSIZE  (ARSIZE),
        .ARVALID (ARVALID),
        .ARREADY (ARREADY),
        .RDATA   (RDATA),
        .RRESP   (RRESP),
        .RVALID  (RVALID),
        .RLAST   (RLAST),
        .RREADY  (RREADY)
    );

    // 4. Clock Generation
    initial begin  
        AXI_vif.ACLK = 0;
        forever #5ns AXI_vif.ACLK = ~AXI_vif.ACLK;
    end

    // 5. Reset Generation
    initial begin
        AXI_vif.ARESETn = 1;
        #2ns;
        AXI_vif.ARESETn = 0;
        #2ns;
        AXI_vif.ARESETn = 1;
    end

    // 6. UVM Config DB and Run Test
    initial begin
        uvm_config_db #(uvm_active_passive_enum)::set(null, "*", "is_active", UVM_ACTIVE);
        uvm_config_db #(virtual AXI_if)::set(null, "*", "vif", AXI_vif);
        run_test("AXI_test");
    end

endmodule