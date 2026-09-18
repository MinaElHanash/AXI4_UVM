package AXI_transaction_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter int ADDR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;

    class AXI_transaction extends uvm_sequence_item;

        // Global signals
        logic                       ARESETn;

        // Write address channel (AW)
        rand logic [ADDR_WIDTH-1:0] AWADDR;
        rand logic [7:0]            AWLEN;
        rand logic [2:0]            AWSIZE;
        rand logic                  AWVALID; // Added rand
        logic                       AWREADY;

        // Write data channel (W)
        rand logic [DATA_WIDTH-1:0] WDATA[];
        logic                       WVALID;
        logic                       WLAST;
        logic                       WREADY;

        // Write response channel (B)
        logic [1:0]                 BRESP;
        logic                       BVALID;
        rand logic                  BREADY;

        // Read address channel (AR)
        rand logic [ADDR_WIDTH-1:0] ARADDR;
        rand logic [7:0]            ARLEN;
        rand logic [2:0]            ARSIZE;
        rand logic                  ARVALID; // Added rand
        logic                       ARREADY;

        // Read data channel (R)
        logic [DATA_WIDTH-1:0]      RDATA[];
        logic [1:0]                 RRESP;
        logic                       RVALID;
        logic                       RLAST;
        rand logic                  RREADY;

        // ==========================================
        // Randomization Constraints
        // ==========================================
        constraint c1 {
            // Data width sizing
            AWSIZE == 2; 
            ARSIZE == 2;

            // Address alignment
            (AWADDR % 4) == 0;
            (ARADDR % 4) == 0;

            // Guardrail to prevent 32-bit integer overflow
            AWADDR < 4096;
            ARADDR < 4096;

            // Memory boundary limits
            // ((AWLEN + 1) * 4) represents total bytes in the burst
            AWADDR + ((AWLEN + 1) * 4) <= 4096; 
            ARADDR + ((ARLEN + 1) * 4) <= 4096; 

            // Array sizing to prevent driver out-of-bounds errors
            WDATA.size() == AWLEN + 1;
        }
        
        `uvm_object_utils_begin(AXI_transaction)
            // Global signals
            `uvm_field_int(ARESETn,                          UVM_DEFAULT)

            // Write address channel (AW)
            `uvm_field_int(AWADDR,                           UVM_DEFAULT)
            `uvm_field_int(AWLEN,                            UVM_DEFAULT)
            `uvm_field_int(AWSIZE,                           UVM_DEFAULT)
            `uvm_field_int(AWVALID,                          UVM_DEFAULT)
            `uvm_field_int(AWREADY,                          UVM_DEFAULT)

            // Write data channel (W)
            `uvm_field_array_int(WDATA,                      UVM_DEFAULT)
            `uvm_field_int(WVALID,                           UVM_DEFAULT)
            `uvm_field_int(WLAST,                            UVM_DEFAULT)
            `uvm_field_int(WREADY,                           UVM_DEFAULT)

            // Write response channel (B)
            `uvm_field_int(BRESP,                            UVM_DEFAULT)
            `uvm_field_int(BVALID,                           UVM_DEFAULT)
            `uvm_field_int(BREADY,                           UVM_DEFAULT)

            // Read address channel (AR)
            `uvm_field_int(ARADDR,                           UVM_DEFAULT)
            `uvm_field_int(ARLEN,                            UVM_DEFAULT)
            `uvm_field_int(ARSIZE,                           UVM_DEFAULT)
            `uvm_field_int(ARVALID,                          UVM_DEFAULT)
            `uvm_field_int(ARREADY,                          UVM_DEFAULT)

            // Read data channel (R)
            `uvm_field_array_int(RDATA,                      UVM_DEFAULT)
            `uvm_field_int(RRESP,                            UVM_DEFAULT)
            `uvm_field_int(RVALID,                           UVM_DEFAULT)
            `uvm_field_int(RLAST,                            UVM_DEFAULT)
            `uvm_field_int(RREADY,                           UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "AXI_transaction");
            super.new(name);
        endfunction

    endclass
    
endpackage