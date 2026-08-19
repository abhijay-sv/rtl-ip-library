`include "apb_if.svh"

module apb_bridge
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_SUBORDINATES,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR [NUM_SUBORDINATES],
    parameter logic [ADDR_WIDTH-1:0] ADDR_SIZE [NUM_SUBORDINATES]
)
(
    input  logic pready_in [NUM_SUBORDINATES],
    input  logic [DATA_WIDTH-1:0] prdata_in [NUM_SUBORDINATES],
    input  logic pslverr_in [NUM_SUBORDINATES],
    output logic psel_out [NUM_SUBORDINATES],

    apb_if.bridge apb
);

    always_comb begin
        apb.pready = 1'd0;
        apb.prdata = '0;
        apb.pslverr = 1'd0;
        psel_out = '0;

        for (int i = 0; i < NUM_SUBORDINATES; i++) begin
            if ((paddr >= BASE_ADDR[i]) && (paddr < BASE_ADDR[i] + ADDR_SIZE[i])) begin
                apb.pready = pready_in[i];
                apb.prdata = prdata_in[i];
                apb.pslverr = pslverr_in[i];
                psel_out[i] = apb.psel;
            end
        end
    end

endmodule
