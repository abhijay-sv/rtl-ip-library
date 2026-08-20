module spi_subordinate //CPOL: 0, CPHA: 0
#(
    parameter MSB_FIRST = 1,
    parameter MAX_TRANSACTION_SIZE
)
(
    input logic rst_n, cs,
    output [MAX_TRANSACTION_SIZE-1:0] transaction,

    spi_if.subordinate spi
);


endmodule