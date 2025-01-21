`timescale 1ns/1ps
module ParityTest;

// Regs to drive the inputs
reg        reset_n;
reg  [7:0] data_in;
reg  [1:0] parity_type;

// Wire to show the output
wire       parity_bit;

// Instantiation of the design module
Parity ForTest(
    .reset_n(reset_n),
    .data_in(data_in),
    .parity_type(parity_type),
    .parity_bit(parity_bit)
);

// dump for waveform generation
initial begin
    $dumpfile("ParityTest.vcd");
    $dumpvars(0, ParityTest);
end

// Monitoring the outputs and the inputs
initial begin
    $monitor("Time = %0t | reset_n = %b | parity_type = %b | data_in = %b | parity_bit = %b",
             $time, reset_n, parity_type, data_in, parity_bit);
end

// Resetting the system
initial begin
    reset_n = 1'b0;  // Assert reset
    #10 reset_n = 1'b1;  // Deassert reset after 10ns
end

// Testing various input data and parity types
initial begin
    // Iterating through different data values
    repeat (10) begin
        data_in = $random % 256;  // Random 8-bit data
        #20;
    end
    $stop;  // Stop simulation after 10 random tests
end

// Parity Types Test
initial begin
    // Testing for each parity type
    parity_type = 2'b00;  // No Parity
    #40 parity_type = 2'b01;  // Odd Parity
    #40 parity_type = 2'b10;  // Even Parity
    #40 parity_type = 2'b11;  // Invalid Parity
end

endmodule
