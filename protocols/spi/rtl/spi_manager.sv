module spi_manager //CPOL: 0, CPHA: 0
#(
    parameter MSB_FIRST = 1,
    parameter NUM_SUBORDINATES = 1
    parameter MAX_TRANSACTION_SIZE
)
(
    input logic clk, rst_n,
    input [MAX_TRANSACTION_SIZE-1:0] transaction,
    output logic cs [NUM_SUBORDINATES],

    spi_if.manager spi
);


endmodule