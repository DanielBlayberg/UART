`timescale 1ns/1ps
module ErrorCheckerTest;

// Regs to drive the inputs
reg         reset_active_low;
reg         frame_ready;
reg  [12:0] received_frame;
reg         received_parity;
reg         received_start;
reg         received_stop;
reg  [1:0]  parity_mode;

// Wires to show the outputs
wire [3:0]  error_location;
wire        corrected;
wire [7:0]  corrected_data;
wire        global_error_flag;
wire [2:0]  frame_error_flag;

// Instantiation of the design module
ErrorChecker ForTest(
    .reset_active_low(reset_active_low),
    .frame_ready(frame_ready),
    .received_frame(received_frame),
    .received_parity(received_parity),
    .received_start(received_start),
    .received_stop(received_stop),
    .parity_mode(parity_mode),
    .error_location(error_location),
    .corrected(corrected),
    .corrected_data(corrected_data),
    .global_error_flag(global_error_flag),
    .frame_error_flag(frame_error_flag)
);

// Waveform dump
initial begin
    $dumpfile("ErrorCheckerTest.vcd");
    $dumpvars(0, ErrorCheckerTest);
end

// Monitor inputs and outputs
initial begin
    $monitor("Time=%0t | reset=%b | frame_ready=%b | received_frame=%b | parity=%b | start=%b | stop=%b | parity_mode=%b | error_flag=%b | corrected=%b | corrected_data=%b | location=%b",
             $time, reset_active_low, frame_ready, received_frame, received_parity, received_start, received_stop, parity_mode, frame_error_flag, corrected, corrected_data, error_location);
end

// Test scenarios
initial begin
    reset_active_low = 0;
    frame_ready = 0;
    #10 reset_active_low = 1;

    // Valid frame
    #10 received_frame = 13'b1010101010101; frame_ready = 1; parity_mode = 2'b01; received_start = 0; received_stop = 1;
    #10 frame_ready = 0;

    // Frame with parity error
    #10 received_frame = 13'b0010101010101; frame_ready = 1; parity_mode = 2'b10; received_parity = 1;
    #10 frame_ready = 0;

    // Random frame tests
    repeat (5) begin
        #10 received_frame = $random % 8192; frame_ready = 1; parity_mode = $random % 3;
        #10 frame_ready = 0;
    end

    $stop;
end

endmodule
