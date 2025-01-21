`timescale 1ns/1ps
module PisoTest;

// Test Inputs
reg        reset_n;
reg        start_send;
reg        baud_clock;
reg        parity_bit;
reg  [7:0] parallel_data;

// Test Outputs
wire       serial_out;
wire       is_transmitting;
wire       transmission_done;
wire       error_flag;

// Instantiation of the PISO_UART module
PISO_UART ForTest(
    .reset_n(reset_n),
    .start_send(start_send),
    .baud_clock(baud_clock),
    .parity_bit(parity_bit),
    .parallel_data(parallel_data),
    .serial_out(serial_out),
    .is_transmitting(is_transmitting),
    .transmission_done(transmission_done),
    .error_flag(error_flag)
);

// Waveform dump
initial begin
    $dumpfile("PisoTest.vcd");
    $dumpvars(0, PisoTest);
end

// Monitor the outputs and inputs
initial begin
    $monitor("Time = %0t | reset_n = %b | start_send = %b | baud_clock = %b | parity_bit = %b | parallel_data = %b | serial_out = %b | is_transmitting = %b | transmission_done = %b | error_flag = %b",
             $time, reset_n, start_send, baud_clock, parity_bit, parallel_data, serial_out, is_transmitting, transmission_done, error_flag);
end

// Clock generation: Baud Rate Clock (e.g., 9600 baud rate for 100MHz)
initial begin
    baud_clock = 1'b0;
    forever #5208 baud_clock = ~baud_clock;  // ~9600 baud rate with 100MHz clock
end

// Reset logic
initial begin
    reset_n = 1'b0;  // Assert reset
    #100 reset_n = 1'b1;  // Deassert reset after 100ns
end

// Start Send Signal
initial begin
    start_send = 1'b0;
    #150 start_send = 1'b1;  // Enable sending after 150ns
    #200 start_send = 1'b0;  // Disable sending
end

// Test different Parity Types and Data
initial begin
    // Test Case 1: No Parity
    parallel_data = 8'b10101010;  // Sample Data
    parity_bit = 1'b0;  // No parity
    #104166;  // Wait for a full cycle

    // Test Case 2: Odd Parity
    parallel_data = 8'b11001100;
    parity_bit = (^parallel_data) ? 1'b0 : 1'b1;  // Odd Parity Calculation
    #104166;

    // Test Case 3: Even Parity
    parallel_data = 8'b11110000;
    parity_bit = (^parallel_data) ? 1'b1 : 1'b0;  // Even Parity Calculation
    #104166;

    // Test Case 4: Random Data
    parallel_data = 8'b00001111;
    parity_bit = 1'b0;  // No parity
    #104166;

    $stop;  // Stop simulation
end

endmodule
