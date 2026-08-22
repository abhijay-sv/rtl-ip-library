parameter PERIOD = 10;
parameter WIDTH = 4;

module counter_tb;
    logic clk = 0;
    logic rst_n, count_en, clear, flag;
    logic [WIDTH-1:0] max_count, count;
    int stop_point;

    always #(PERIOD/2) clk <= ~clk;

    counter #(.COUNT_WIDTH(WIDTH)) DUT (
        .clk(clk), 
        .rst_n(rst_n), 
        .count_en(count_en), 
        .clear(clear),
        .max_count(max_count),
        .count(count),
        .flag(flag)
    );

    assert property (@(posedge clk) disable iff (!rst_n)
        flag <-> (count == max_count))
    else $error("COUNTER: flag mismatch, count=%h max_count=%h flag=%b", count, max_count, flag);

    assert property (@(posedge clk) disable iff (!rst_n)
        (!count_en && !clear) |-> $stable(count))
    else $error("COUNTER: count changed while count_en=0, count=%h", count);

    assert property (@(posedge clk) disable iff (!rst_n)
        clear |=> (count == '0))
    else $error("COUNTER: count did not reset to 0 one cycle after clear, count=%h", count);

    assert property (@(posedge clk) disable iff (!rst_n)
        (count_en && !clear && !$past(flag)) |-> (count == $past(count) + 1))
    else $error("COUNTER: count did not increment by 1, expected=%0d got=%h", $past(count) + 1, count);

    initial begin
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        count_en = 1'd0;
        clear = 1'd0;
        max_count = '1;

        $dumpfile("dump.fst");
        $dumpvars(0, counter_tb);
        $monitor("clk = %b, rst_n = %b, count_en = %b, clear = %b, max_count = %h, count = %h, flag = %b", 
                    clk, rst_n, count_en, clear, max_count, count, flag);

        //RESET TEST
        assert (count == '0)
            else $error("COUNTER: count did not reset to 0 after rst_n, count=%h", count);

        //ZERO TEST
        max_count = '0;
        rst_n = 1'b0;
        @(posedge clk);
        rst_n = 1'b1;
        count_en = 1'b1;
        repeat (3) begin
            @(posedge clk)
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d with flag set constantly, got count=%h flag=%b", max_count, count, flag);
        end
        count_en = 1'b0;

        //ZERO CLEAR TEST
        clear = 1'b1;
        @(posedge clk);
        clear = 1'b0;
        count_en = 1'b1;
        repeat (3) begin
            @(posedge clk)
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d with flag set constantly after clear, got count=%h flag=%b", max_count, count, flag);
        end
        count_en = 1'b0;

        //MAX MAX COUNT TEST
        max_count = '1;
        rst_n = 1'b0;
        @(posedge clk);
        rst_n = 1'b1;
        count_en = 1'b1;

        repeat (max_count) @(posedge clk);
        assert (count == max_count)
            else $error("COUNTER: expected count=%0d with flag set, got count=%h flag=%b", max_count, count, flag);

        @(posedge clk);
        assert (count == '0)
            else $error("COUNTER: count did not wrap to 0, count=%h", count);

        count_en = 1'b0;

        //RANDOM STANDARD COUNT CASES
        repeat (5) begin
            max_count = $urandom_range(1, 15);

            rst_n = 1'b0;
            @(posedge clk);
            rst_n = 1'b1;
            count_en = 1'b1;

            repeat (max_count) @(posedge clk);
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d, got count=%h flag=%b", max_count, count, flag);

            @(posedge clk);
            assert (count == '0)
                else $error("COUNTER: count did not wrap to 0, count=%h", count);

            count_en = 1'b0;
            repeat (3) @(posedge clk);
        end

        //RANDOM MID COUNT PAUSE
        repeat (5) begin
            max_count = $urandom_range(4, 15);
            stop_point = $urandom_range(1, max_count - 1);

            rst_n = 1'b0;
            @(posedge clk);
            rst_n = 1'b1;
            count_en = 1'b1;

            repeat (stop_point) @(posedge clk);
            count_en = 1'b0;

            repeat ($urandom_range(1, 3)) @(posedge clk);
            assert (count == stop_point)
                else $error("COUNTER: count changed while stopped, expected=%h got=%h", stop_point, count);

            count_en = 1'b1;
            repeat (max_count - stop_point) @(posedge clk);
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d with flag set, got count=%h flag=%b", max_count, count, flag);

            count_en = 1'b0;
            repeat (3) @(posedge clk);
        end

        //VARIED LENGTH CLEAR MID-COUNT 
        repeat (5) begin
            max_count = $urandom_range(4, 15);
            stop_point = $urandom_range(1, max_count - 1);

            rst_n = 1'b0;
            @(posedge clk);
            rst_n = 1'b1;
            count_en = 1'b1;

            repeat (stop_point) @(posedge clk);
            count_en = 1'b0;
            clear = 1'b1;
            repeat ($urandom_range(1, 3)) @(posedge clk);
            clear = 1'b0;

            count_en = 1'b1;
            repeat (max_count) @(posedge clk);
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d with flag set after clear, got count=%h flag=%b", max_count, count, flag);

            count_en = 1'b0;
            repeat (3) @(posedge clk);
        end

        //RESET MID-COUNT 
        repeat (5) begin
            max_count = $urandom_range(4, 15);
            stop_point = $urandom_range(1, max_count - 1);

            rst_n = 1'b0;
            @(posedge clk);
            rst_n = 1'b1;
            count_en = 1'b1;

            repeat (stop_point) @(posedge clk);

            rst_n = 1'b0;
            repeat ($urandom_range(1, 3)) begin
                @(posedge clk);
                assert (count == '0)
                    else $error("COUNTER: count did not reset to 0 while rst_n held low, count=%h", count);
            end
            rst_n = 1'b1;

            repeat (max_count) @(posedge clk);
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d with flag set after reset, got count=%h flag=%b", max_count, count, flag);

            count_en = 1'b0;
            repeat (3) @(posedge clk);
        end

        //DECREASING MAX COUNT WITHOUT RESET/CLEAR
        repeat (3) begin
            max_count = $urandom_range(4, 12);
            stop_point = $urandom_range(1, max_count - 2);

            rst_n = 1'b0;
            @(posedge clk);
            rst_n = 1'b1;
            count_en = 1'b1;

            repeat (stop_point) @(posedge clk);
            count_en = 1'b0;

            max_count = $urandom_range(stop_point + 1, max_count - 1);

            count_en = 1'b1;
            repeat (max_count - stop_point) @(posedge clk);
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d after max_count decreased, got count=%h flag=%b", max_count, count, flag);

            count_en = 1'b0;
            repeat (3) @(posedge clk);
        end

        //INCREASING MAX COUNT WITHOUT RESET/CLEAR
        repeat (3) begin
            max_count = $urandom_range(4, 12);
            stop_point = $urandom_range(1, max_count - 2);

            rst_n = 1'b0;
            @(posedge clk);
            rst_n = 1'b1;
            count_en = 1'b1;

            repeat (stop_point) @(posedge clk);
            count_en = 1'b0;

            max_count = $urandom_range(max_count + 1, 15); 

            count_en = 1'b1;
            repeat (max_count - stop_point) @(posedge clk);
            assert (count == max_count)
                else $error("COUNTER: expected count=%0d after max_count increased, got count=%h flag=%b", max_count, count, flag);

            count_en = 1'b0;
            repeat (3) @(posedge clk);
        end

        $finish;
    end
endmodule