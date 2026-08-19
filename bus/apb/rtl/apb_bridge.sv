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
    apb_if.bridge  apb,
    apb_if.manager sub_apb [NUM_SUBORDINATES]
);

    always_comb begin
        apb.pready  = 1'd0;
        apb.prdata  = '0;
        apb.pslverr = 1'd0;

        for (int i = 0; i < NUM_SUBORDINATES; i++) begin
            sub_apb[i].paddr   = apb.paddr;
            sub_apb[i].pwdata  = apb.pwdata;
            sub_apb[i].pwrite  = apb.pwrite;
            sub_apb[i].penable = apb.penable;
            sub_apb[i].pprot   = apb.pprot;
            sub_apb[i].pstrb   = apb.pstrb;
            sub_apb[i].pwakeup = apb.pwakeup;

            sub_apb[i].psel = apb.psel && (apb.paddr >= BASE_ADDR[i]) && (apb.paddr < BASE_ADDR[i] + ADDR_SIZE[i]);

            if (sub_apb[i].psel) begin
                apb.pready  = sub_apb[i].pready;
                apb.prdata  = sub_apb[i].prdata;
                apb.pslverr = sub_apb[i].pslverr;
            end
        end
    end

endmodule