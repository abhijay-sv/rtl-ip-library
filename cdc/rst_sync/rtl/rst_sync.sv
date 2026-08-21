module rst_sync 
#(
    parameter SYNC_STAGES = 2
)
(
    input logic clk, rst_n,
    output logic sync_rst_n
);

    initial begin
        assert (SYNC_STAGES >= 2)
            else $fatal("SYNC_STAGES must be greater than or equal to two.")
    end

    logic sync_regs [SYNC_STAGES];

    assign sync_rst_n = sync_regs[SYNC_STAGES-1];

    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < SYNC_STAGES; i++) begin
                sync_regs[i] <= 1'd0;
            end
        end
        else begin
            sync_regs[0] <= 1'd1;
            for (int i = 1; i < SYNC_STAGES; i++) begin
                sync_regs[i] <= sync_regs[i-1];
            end
        end
    end
endmodule