`include "apb_if.svh"
//TODO: add assertions
module apb_manager
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    input  logic req_valid,
    input  logic req_write,
    input  logic [ADDR_WIDTH-1:0] req_addr,
    input  logic [DATA_WIDTH-1:0] req_wdata,
    input  logic [DATA_WIDTH/8-1:0] req_wstrb, //Tie to '1 if unused
    input  logic [2:0] req_prot, //Tie to 3'd0 if unused
    input  logic req_wakeup,  //Tie to 1'd1 if unused
    output logic req_ready,
    output logic [DATA_WIDTH-1:0] req_rdata,
    output logic req_error,

    apb_if.manager apb
);

    typedef enum logic [1:0] {IDLE, SETUP, ACCESS} manager_state;

    logic busy;
    manager_state state, next_state;

    assign busy = (state == SETUP) || (state == ACCESS && apb.pready == 0);
    assign apb.psel = (state != IDLE);
    assign apb.penable = (state == ACCESS);


    always_ff @ (posedge apb.pclk, negedge apb.preset_n) begin
        if (!apb.preset_n) begin
            req_ready <= 1'd0;
            req_rdata <= '0;
            req_error <= 1'd0;
            apb.paddr <= '0;
            apb.pprot <= '0;
            apb.pwdata <= '0;
            apb.pstrb <= '0;
            apb.pwrite <= 1'd0;
            apb.pwakeup <= 1'd0;
            state <= IDLE;
        end
        else begin
            state <= next_state;
            req_ready <= (state == ACCESS) ? apb.pready : 1'd0;

            if (!busy) begin
                apb.pwakeup <= req_wakeup;

                if (req_valid) begin
                    apb.paddr <= req_addr;
                    apb.pprot <= req_prot;
                    apb.pwdata <= req_wdata;
                    apb.pwrite <= req_write;
                    apb.pstrb <= req_write ? req_wstrb : '0;
                end

                if (state == ACCESS) begin
                    req_rdata <= apb.prdata;
                    req_error <= apb.pslverr;
                end
            end
        end
    end

    always_comb begin
        case (state)
            IDLE: next_state = req_valid ? SETUP : IDLE;
            SETUP: next_state = ACCESS;
            ACCESS: next_state = !apb.pready ? ACCESS : (req_valid ? SETUP : IDLE);
            default: next_state = IDLE;
        endcase
    end

endmodule