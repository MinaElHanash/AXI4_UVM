module axi4_memory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,    // For 1024 locations
    parameter DEPTH = 1024
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    input  wire                     mem_en,
    input  wire                     mem_we,
    input  wire [ADDR_WIDTH-1:0]    mem_addr,
    input  wire [DATA_WIDTH-1:0]    mem_wdata,
    output wire [DATA_WIDTH-1:0]    mem_rdata  // CHANGED to wire
);

    // Memory array
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    
    integer j;
    
    // Continuous assignment for zero-latency reads
    assign mem_rdata = memory[mem_addr];
    
    // Memory write logic only
    always @(posedge clk) begin
        if (mem_en && mem_we) begin
            memory[mem_addr] <= mem_wdata;
        end
    end
    
    // Initialize memory
    initial begin
        for (j = 0; j < DEPTH; j = j + 1)
            memory[j] = 0;
    end

endmodule