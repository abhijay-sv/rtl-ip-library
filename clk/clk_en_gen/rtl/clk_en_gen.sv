module clk_en_gen //Outputs data enable signal
#(
    parameter DIVISOR_WIDTH = 1
)
(
    input logic clk, rst_n, gen_en,
    input logic [DIVISOR_WIDTH-1:0] divisor,
    output logic clk_en
);

    logic [DIVISOR_WIDTH-1:0] max_count;

    assign max_count = (divisor == '0) ? '0 : divisor - 1;

    counter #(
        .COUNT_WIDTH(DIVISOR_WIDTH)
    ) clk_en_cnt (
        .clk(clk),
        .rst_n(rst_n),
        .max_count(max_count),
        .en(gen_en),
        .count(),
        .flag(clk_en)
    );
endmodule