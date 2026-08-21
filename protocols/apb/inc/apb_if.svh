interface apb_if
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    input logic pclk, preset_n
);

    logic [ADDR_WIDTH-1:0] paddr;
    logic [2:0] pprot;
    logic [DATA_WIDTH-1:0] pwdata, prdata;
    logic [DATA_WIDTH/8-1:0] pstrb;
    logic psel, penable, pwrite, pready;
    logic pslverr, pwakeup;
    
    modport manager (
        input  pclk, preset_n,
        input  pready, prdata, pslverr,
        output paddr, pprot, penable, pwdata, pstrb, psel, pwrite, pwakeup
    );

    modport subordinate (
        input  pclk, preset_n,
        input  paddr, pprot, penable, pwdata, pstrb, psel, pwrite, pwakeup,
        output pready, prdata, pslverr
    );
endinterface
