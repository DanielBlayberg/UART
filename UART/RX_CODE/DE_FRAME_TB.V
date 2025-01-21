`timescale 1ns/1ps
module DeFrameTest;

// Regs to drive the inputs
reg  [10:0] frame_parallel;
reg         frame_ready;

// Wires to show the outputs
wire        extracted_parity;
wire        extracted_start;
wire        extracted_stop;
wire        frame_done;
wire [7:0]  data_payload;

// Instantiation of the design module
DeFrame ForTest(
    .frame_parallel(frame_parallel),
    .frame_ready(frame_ready),
    .extracted_parity(extracted_parity),
    .extracted_start(extracted_start),
    .extracted_stop(extracted_stop),
    .frame_done(frame_done),
    .data_payload(data_payload)
);

// Waveform dump
initial begin
    $dumpfile("DeFrameTest.vcd");
    $dumpvars(0, DeFrameTest);
end

// Monitor inputs and outputs
initial begin
    $monitor("Time=%0t | frame_ready=%b | frame_parallel=%b | start=%b | stop=%b | parity=%b | data_payload=%b | frame_done=%b",
             $time, frame_ready, frame_parallel, extracted_start, extracted_stop, extracted_parity, data_payload, frame_done);
end

// Test various frames
initial begin
    frame_ready = 0;
    #10 frame_parallel = 11'b0_10101010_0; frame_ready = 1; // Frame with start bit, data, and no parity
    #10 frame_ready = 0;

    #10 frame_parallel = 11'b1_01010101_1; frame_ready = 1; // Frame with valid start/stop/parity
    #10 frame_ready = 0;

    repeat (5) begin
        #10 frame_parallel = $random % 2048; frame_ready = 1;  // Random frames
        #10 frame_ready = 0;
    end

    $stop;
end

endmodule
