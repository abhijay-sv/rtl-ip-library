module counter
#(
    parameter COUNT_WIDTH
)
(
    input  logic clk, rst_n,
    input  logic count_en, clear,
    input  logic [COUNT_WIDTH-1:0] max_count,
    output logic [COUNT_WIDTH-1:0] count,
    output logic flag
);

    logic [COUNT_WIDTH-1:0] next_count;

    assign next_count = flag ? '0 : count + 1;

    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n || clear) begin
            count <= '0;
            flag <= (max_count == 0);
        end
        else if (count_en) begin
            count <= next_count;
            flag <= next_count == max_count;
        end
    end

    assert property (@(posedge clk) disable iff (!rst_n) 
        !(count_en && clear))
        else $error("COUNTER: count_en and clear asserted simultaneously");
    assert property (@(posedge clk) disable iff (!rst_n)
        ($past(count_en) && count_en) |-> $stable(max_count))
        else $error("COUNTER: max_count changed while counter enabled");
    assert property (@(posedge clk) disable iff (!rst_n)
        $rose(count_en) |-> (max_count >= count))
        else $error("COUNTER: max_count invalid on counter re-enable: max_count < count");

endmodule
