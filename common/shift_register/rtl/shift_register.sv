module shift_register
#(
    parameter SHIFT_MSB = 1, //0 for SHIFT_LSB
    parameter DATA_SIZE = 8
)
(
    input logic clk, rst_n, serial_in, load_en, shift_en,
    input logic [DATA_SIZE-1:0] parallel_in,
    output logic serial_out,
    output logic [DATA_SIZE-1:0] parallel_out
);

    initial begin
        assert (DATA_SIZE > 1)
            else $fatal(1, "DATA_SIZE must be greater than 1");
        assert (SHIFT_MSB == 0 || SHIFT_MSB == 1)
            else $fatal(1, "SHIFT_MSB must be 0 or 1");
    end

    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            serial_out <= 1'd0;
            parallel_out <= '0;
        end
        else begin
            if (load_en) begin
                parallel_out <= parallel_in;
            end
            else if (shift_en) begin
                serial_out <= SHIFT_MSB ? parallel_out[DATA_SIZE-1] : parallel_out[0];
                if (SHIFT_MSB) begin
                    parallel_out <= {parallel_out[DATA_SIZE-2:0], serial_in};
                end
                else begin
                    parallel_out <= {serial_in, parallel_out[DATA_SIZE-1:1]};
                end
            end
        end
    end

    assert property (@(posedge clk) disable iff (!rst_n) 
        !(load_en && shift_en))
        else $error("load_en and shift_en asserted simultaneously");

endmodule