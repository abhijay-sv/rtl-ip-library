module spi_manager //CPOL: 0, CPHA: 0
#(
    parameter SHIFT_MSB = 1,
    parameter NUM_SUBORDINATES = 1
    parameter MAX_FRAME_SIZE
)
(
    input logic clk, rst_n, mframe_valid,
    input logic [MAX_DATA_SIZE-1:0] mframe_out,
    input logic [$clog2(NUM_SUBORDINATES+1)-1:0] cs_addr,
    output logic sframe_ready,
    output logic [MAX_DATA_SIZE-1:0] sframe_in,
    output logic cs_n [NUM_SUBORDINATES],

    spi_if.manager spi
);


endmodule