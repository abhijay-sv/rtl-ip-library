module async_fifo 
#(  
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 16,
    parameter SYNC_STAGES = 2
)
(
    input logic rclk, rrst_n, r_en, 
    input logic wclk, wrst_n, w_en,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full, empty
);
    localparam FIFO_DEPTH = 1 << ADDR_WIDTH;

    logic [ADDR_WIDTH:0] b_wptr, g_wptr, next_b_wptr, next_g_wptr, wsync_g_rptr;
    logic [ADDR_WIDTH:0] b_rptr, g_rptr, next_b_rptr, next_g_rptr, rsync_g_wptr;
    logic [ADDR_WIDTH:0] rptr_overflow_val;
    logic [DATA_WIDTH-1:0] fifo_data [FIFO_DEPTH];
    logic next_full, next_empty;
    logic raw_rst_n, wsync_rst_n, rsync_rst_n;

    assign raw_rst_n = wrst_n & rrst_n; //Get the shared rst_n so that both pointers reset if either does.

    rst_sync #(
        .SYNC_STAGES(SYNC_STAGES)
    ) rst_wsync (
        .clk(wclk), 
        .rst_n(raw_rst_n), 
        .sync_rst_n(wsync_rst_n)
    );

    rst_sync #(
        .SYNC_STAGES(SYNC_STAGES)
    ) rst_rsync (
        .clk(rclk), 
        .rst_n(raw_rst_n), 
        .sync_rst_n(rsync_rst_n)
    );

    cdc_sync #(
        .WIDTH(ADDR_WIDTH + 1), 
        .SYNC_STAGES(SYNC_STAGES)
    ) rptr_wsync (
        .clk(wclk), 
        .rst_n(wsync_rst_n), 
        .async_in(g_rptr), 
        .sync_out(wsync_g_rptr)
    );

    cdc_sync #(
        .WIDTH(ADDR_WIDTH + 1), 
        .SYNC_STAGES(SYNC_STAGES)
    ) wptr_rsync (
        .clk(rclk), 
        .rst_n(rsync_rst_n), 
        .async_in(g_wptr), 
        .sync_out(rsync_g_wptr)
    );
    

    always_ff @ (posedge rclk, negedge rsync_rst_n) begin : RCLK
        if (!rsync_rst_n) begin
            b_rptr <= '0;
            g_rptr <= '0;
            data_out <= '0;
            empty <= 1'd1;
        end
        else begin
            empty <= next_empty;
            
            if (r_en && !empty) begin
                b_rptr <= next_b_rptr;
                g_rptr <= next_g_rptr;
                data_out <= fifo_data[b_rptr[ADDR_WIDTH-1:0]];
            end
        end
    end

    always_comb begin : NEXT_RCLK_VALUES
        next_b_rptr = b_rptr + 1'd1;
        next_g_rptr = (next_b_rptr >> 1) ^ next_b_rptr;
        next_empty = (r_en && !empty) ? (rsync_g_wptr == next_g_rptr) : (rsync_g_wptr == g_rptr); 
    end

    always_ff @ (posedge wclk, negedge wsync_rst_n) begin : WCLK
        if (~wsync_rst_n) begin
            b_wptr <= '0;
            g_wptr <= '0;
            full <= 1'd0;
        end
        else begin
            full <= next_full;
            
            if (w_en && !full) begin
                b_wptr <= next_b_wptr;
                g_wptr <= next_g_wptr;
                fifo_data[b_wptr[ADDR_WIDTH-1:0]] <= data_in;
            end
        end
    end

    always_comb begin : NEXT_WCLK_VALUES
        next_b_wptr = b_wptr + 1'd1;
        next_g_wptr = (next_b_wptr >> 1) ^ next_b_wptr;
        rptr_overflow_val = {~wsync_g_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wsync_g_rptr[ADDR_WIDTH-2:0]};
        next_full = (w_en && !full) ? (rptr_overflow_val == next_g_wptr) : (rptr_overflow_val == g_wptr); 
    end

endmodule