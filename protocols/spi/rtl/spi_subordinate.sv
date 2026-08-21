module spi_subordinate //CPOL: 0, CPHA: 0
#(
    parameter SHIFT_MSB = 1,
    parameter MAX_FRAME_SIZE
)
(
    input logic rst_n, cs_n, sframe_valid,
    input logic [MAX_FRAME_SIZE-1:0] sframe_out,
    output logic mframe_ready,
    output logic [MAX_FRAME_SIZE-1:0] mframe_in,

    spi_if.subordinate spi
);


endmodule