module clk_gate //Outputs gated clk signal
(
    input logic clk, en,
    output logic gated_clk
);
    logic latched_en;

    assign gated_clk = clk & latched_en;

    always_ff @ (negedge clk) begin
        latched_en <= en;
    end
endmodule