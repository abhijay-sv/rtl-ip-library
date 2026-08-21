parameter PERIOD = 10;
parameter WIDTH = 16;
parameter SYNC_STAGES = 2;

module cdc_sync_tb;
    logic clk = 0;
    logic rst_n;
    logic [WIDTH-1:0] async_in, sync_out;
    logic [WIDTH-1:0] expected;
    logic [WIDTH-1:0] prev_expected = '0;

    always #(PERIOD/2) clk <= ~clk;

    cdc_sync #(.WIDTH(WIDTH), .SYNC_STAGES(SYNC_STAGES)) DUT (.clk(clk), .rst_n(rst_n), .async_in(async_in), .sync_out(sync_out));

    initial begin
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        async_in = '0;

        $dumpfile("dump.fst");
        $dumpvars(0, cdc_sync_tb);
        $monitor("clk = %b, rst_n = %b, async_in = %h, sync_out = %h", clk, rst_n, async_in, sync_out);

        //RESET TEST
        assert (sync_out == '0)
            else $error("CDC_SYNC: Sync out did not reset to 0 after rst_n.");

        //RANDOM TEST CASES
        repeat (10) begin
            do begin
                async_in = $urandom();
            end while (async_in == prev_expected);
            expected = async_in;
            
            repeat (SYNC_STAGES - 1) begin
                @(posedge clk);
                assert (sync_out !== expected)
                else $error("CDC_SYNC: async_in = %h passed through early, sync_out = %h after fewer than %0d cycles", async_in, sync_out, SYNC_STAGES);
            end

            @(posedge clk);
            assert (sync_out == expected)
            else $error("CDC_SYNC: async_in = %h, sync_out = %h, expected %h", async_in, sync_out, expected);

            prev_expected = expected;
        end
        
        $finish;
    end
endmodule