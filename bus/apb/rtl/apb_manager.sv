`include "apb_if.svh"

module apb_manager
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    input  logic req_valid,
    input  logic req_write,
    input  logic [ADDR_WIDTH-1:0] req_addr,
    input  logic [DATA_WIDTH-1:0] req_wdata,
    input  logic [DATA_WIDTH/8-1:0] req_wstrb, //Tie to '1 if unused
    input  logic [2:0] req_prot, //Tie to 3'd0 if unused
    input  logic req_wakeup,  //Tie to 1'd1 if unused
    output logic req_ready,
    output logic [DATA_WIDTH-1:0] req_rdata,
    output logic req_error,

    apb_if.manager apb
);

endmodule
