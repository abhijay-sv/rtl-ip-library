module clk_en_gen //Outputs data enable signal
#(
    parameter DIVISOR_WIDTH = 2
)
(
    input logic clk, rst_n, gen_en,
    input logic [DIVISOR_WIDTH-1:0] divisor,
    output logic clk_en
);

    logic [DIVISOR_WIDTH-1:0] max_count;

    assign max_count = divisor - 1;

    counter #(
        .COUNT_WIDTH(DIVISOR_WIDTH)
    ) clk_en_cnt (
        .clk(clk),
        .rst_n(rst_n),
        .max_count(max_count),
        .count_en(gen_en),
        .count(),
        .flag(clk_en)
    );

    assert property (@(posedge clk) disable iff (!rst_n) gen_en |-> (divisor != 0))
        else $error("CLK_EN_GEN: divisior must not be 0 while gen_en is enabled");
endmodule