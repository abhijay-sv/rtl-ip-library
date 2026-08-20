module counter
#(
    parameter COUNT_WIDTH
)
(
    input  logic clk, rst_n,
    input  logic en,
    input  logic [COUNT_WIDTH-1:0] max_count,
    output logic [COUNT_WIDTH-1:0] count,
    output logic flag
);

    logic [COUNT_WIDTH-1:0] next_count;

    assign next_count = flag ? '0 : count + 1;

    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
            flag <= (max_count == 0);
        end
        else if (en) begin
            count <= next_count;
            flag <= next_count == max_count;
        end
    end

endmodule
