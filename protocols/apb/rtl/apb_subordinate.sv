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

    always_ff @ (posedge apb.pclk, negedge apb.preset_n) begin
        if (!apb.preset_n) begin
            req_valid   <= 1'd0;
            req_write   <= 1'd0;
            req_addr    <= '0;
            req_wdata   <= '0;
            req_wstrb   <= '0;
            req_prot    <= '0;
            req_wakeup  <= 1'd1;
            apb.pready  <= 1'd0;
            apb.prdata  <= '0;
            apb.pslverr <= 1'd0;
        end
        else begin
            req_valid  <= apb.penable && apb.psel;
            req_write  <= apb.pwrite;
            req_addr   <= apb.paddr;
            req_wdata  <= apb.pwdata;
            req_wstrb  <= apb.pstrb;
            req_prot   <= apb.pprot;
            req_wakeup <= apb.pwakeup;

            apb.pready <= req_valid ? req_ready : 1'd0;

            if (req_valid && req_ready) begin
                apb.prdata <= req_rdata;
                apb.pslverr <= req_error;
            end
        end
    end
endmodule