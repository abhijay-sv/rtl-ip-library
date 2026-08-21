interface spi_if();

    logic sclk, miso, mosi;

    modport manager (
        input miso,
        output sclk, mosi
    );

    modport subordinate (
        input sclk, mosi,
        output miso
    );

endinterface
