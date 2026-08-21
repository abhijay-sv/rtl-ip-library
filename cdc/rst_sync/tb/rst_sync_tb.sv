parameter PERIOD = 10;
parameter SYNC_STAGES = 2;

module rst_sync_tb;
    logic clk = 0;
    logic rst_n;
    logic sync_rst_n;

    always #(PERIOD/2) clk <= ~clk;

    rst_sync #(.SYNC_STAGES(SYNC_STAGES)) DUT (.clk(clk), .rst_n(rst_n), .sync_rst_n(sync_rst_n));

    initial begin
        rst_n = 0;
        repeat (4) @(posedge clk);

        $dumpfile("dump.fst");
        $dumpvars(0, rst_sync_tb);
        $monitor("clk = %b, rst_n = %b, sync_rst_n = %b", clk, rst_n, sync_rst_n);

        //INSTANT RESET 
        #1;
        assert (sync_rst_n == 1'b0)
            else $error("RST_SYNC: sync_rst_n did not reset to 0 asynchronously.");

        rst_n = 1;
        repeat (SYNC_STAGES - 1) begin
            @(posedge clk);
            assert (sync_rst_n !== 1'b1)
                else $error("RST_SYNC: sync_rst_n deasserted early after fewer than %0d cycles", SYNC_STAGES);
        end
        @(posedge clk);
        assert (sync_rst_n == 1'b1)
            else $error("RST_SYNC: sync_rst_n did not deassert after %0d cycles", SYNC_STAGES);

        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (SYNC_STAGES - 1) @(posedge clk);
        rst_n = 0;
        #1;
        assert (sync_rst_n == 1'b0)
            else $error("RST_SYNC: sync_rst_n did not reset to 0 asynchronously when reasserted mid-sync.");

        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (SYNC_STAGES) @(posedge clk);
        #(PERIOD/4);
        rst_n = 0;
        #1;
        assert (sync_rst_n == 1'b0)
            else $error("RST_SYNC: sync_rst_n did not reset to 0 asynchronously when asserted mid-clock.");

        $finish;
    end
endmodule
