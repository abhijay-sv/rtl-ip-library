`include "apb_if.svh"

module apb_subordinate
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    input  logic req_ready,
    input  logic [DATA_WIDTH-1:0] req_rdata,
    input  logic req_error, //Tie to 1'd0 if unused
    output logic req_valid,
    output logic req_write,
    output logic [ADDR_WIDTH-1:0] req_addr,
    output logic [DATA_WIDTH-1:0] req_wdata,
    output logic [DATA_WIDTH/8-1:0] req_wstrb,
    output logic [2:0] req_prot,
    output logic req_wakeup,

    apb_if.subordinate apb
);

endmodule
