`timescale 1ns/1ps
module TxTest;

// Regs to drive the inputs
reg        reset_n;
reg        start_send;
reg        system_clk;
reg  [1:0] parity_mode;
reg  [1:0] baud_config;
reg  [7:0] input_data;

// Wires to show the outputs
wire       serial_out;
wire       is_transmitting;
wire       transmission_done;

// Instance for the design module
TxUnit ForTest(
    // Inputs
    .reset_n(reset_n),
    .start_send(start_send),
    .system_clk(system_clk),
    .parity_mode(parity_mode),
    .baud_config(baud_config),
    .input_data(input_data),

    // Outputs
    .serial_out(serial_out),
    .is_transmitting(is_transmitting),
    .transmission_done(transmission_done)
);

// Waveform dump
initial begin
    $dumpfile("TxTest.vcd");
    $dumpvars(0, TxTest);
end

// Monitor the outputs and the inputs
initial begin
    $monitor("Time = %0t | reset_n = %b | start_send = %b | system_clk = %b | parity_mode = %b | baud_config = %b | input_data = %b | serial_out = %b | is_transmitting = %b | transmission_done = %b",
             $time, reset_n, start_send, system_clk, parity_mode, baud_config, input_data, serial_out, is_transmitting, transmission_done);
end

// 100MHz system clock
initial begin
    system_clk = 1'b0;
    forever #5 system_clk = ~system_clk;  // 100MHz clock
end

// Reset logic
initial begin
    reset_n = 1'b0;  // Assert reset
    start_send = 1'b0;  // Start signal off
    #100 reset_n = 1'b1;  // Deassert reset after 100ns
    #50 start_send = 1'b1;  // Enable start signal
end

// Varying Baud Rate and Parity Modes
initial begin
    // Test case 1: Baud Rate 9600, Odd Parity
    baud_config = 2'b00;  // Baud Rate configuration
    parity_mode = 2'b01;  // Odd Parity
    input_data = 8'b10101010;  // Example data
    #1041666;  // Wait for one frame (9600 baud rate)

    // Test case 2: Baud Rate 19200, Even Parity
    baud_config = 2'b01;
    parity_mode = 2'b10;  // Even Parity
    input_data = 8'b11001100;
    #520833;  // Wait for one frame (19200 baud rate)

    // Test case 3: Baud Rate 38400, No Parity
    baud_config = 2'b10;
    parity_mode = 2'b00;  // No Parity
    input_data = 8'b11110000;
    #260416;  // Wait for one frame (38400 baud rate)

    // Test case 4: Baud Rate 57600, Invalid Parity
    baud_config = 2'b11;
    parity_mode = 2'b11;  // Invalid Parity
    input_data = 8'b00001111;
    #173611;  // Wait for one frame (57600 baud rate)

    $stop;  // End simulation
end

endmodule
