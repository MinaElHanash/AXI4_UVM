interface AXI_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)();

    // Global signals
    logic                       ACLK;
    logic                       ARESETn;

    // Write address channel (AW)
    logic [ADDR_WIDTH-1:0]      AWADDR;
    logic [7:0]                 AWLEN;
    logic [2:0]                 AWSIZE;
    logic                       AWVALID;
    logic                       AWREADY;

    // Write data channel (W)
    logic [DATA_WIDTH-1:0]      WDATA;
    logic                       WVALID;
    logic                       WLAST;
    logic                       WREADY;

    // Write response channel (B)
    logic [1:0]                 BRESP;
    logic                       BVALID;
    logic                       BREADY;

    // Read address channel (AR)
    logic [ADDR_WIDTH-1:0]      ARADDR;
    logic [7:0]                 ARLEN;
    logic [2:0]                 ARSIZE;
    logic                       ARVALID;
    logic                       ARREADY;

    // Read data channel (R)
    logic [DATA_WIDTH-1:0]      RDATA;
    logic [1:0]                 RRESP;
    logic                       RVALID;
    logic                       RLAST;
    logic                       RREADY;

endinterface