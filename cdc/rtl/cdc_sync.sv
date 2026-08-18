module cdc_sync
#(
    parameter WIDTH = 1,
    parameter SYNC_STAGES = 2
)
(
    input logic clk, rst_n,
    input logic [WIDTH-1:0] async_in,
    output logic [WIDTH-1:0] sync_out
);

    logic [WIDTH-1:0] sync_regs [SYNC_STAGES];

    assign sync_out = sync_regs[SYNC_STAGES-1];

    always_ff @ (posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            for (int i = 0; i < SYNC_STAGES; i++) begin
                sync_regs[i] <= '0;
            end
        end
        else begin
            sync_regs[0] <= async_in;
            for (int i = 1; i < SYNC_STAGES; i++) begin
                sync_regs[i] <= sync_regs[i-1];
            end
        end
    end
endmodule