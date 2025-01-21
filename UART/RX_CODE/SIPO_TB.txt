`timescale 1ns/1ps
module SipoTest;

// Inputs
reg         reset_active_low;
reg         serial_data_in;
reg         baud_clock;

// Outputs
wire        is_active;
wire        data_ready;
wire [10:0] parallel_data_out;

// DUT Instance
SIPO_Receiver ForTest(
    .reset_active_low(reset_active_low),
    .serial_data_in(serial_data_in),
    .baud_clock(baud_clock),

    .is_active(is_active),
    .data_ready(data_ready),
    .parallel_data_out(parallel_data_out)
);

// Waveform dump
initial begin
    $dumpfile("SipoTest.vcd");
    $dumpvars(0, SipoTest);
end

// Monitor signals
initial begin
    $monitor("Time=%0t | Reset=%b | SerialIn=%b | Active=%b | Ready=%b | ParallelOut=%b",
             $time, reset_active_low, serial_data_in, is_active, data_ready, parallel_data_out);
end

// Baud clock generation (9600 baud)
initial begin
    baud_clock = 0;
    forever #5208 baud_clock = ~baud_clock;  // 9600 baud with 100MHz clock
end

// Reset
initial begin
    reset_active_low = 0;
    #50 reset_active_low = 1;
end

// Test cases
initial begin
    send_serial_data(11'b1_10010101_1);  // Valid frame
    #100;
    send_serial_data(11'b1_11001100_0);  // Frame with errors
    #100;
    $stop;
end

// Task to send serial data
task send_serial_data(input [10:0] frame);
    integer i;
    for (i = 0; i < 11; i = i + 1) begin
        serial_data_in = frame[i];
        #104166;  // Adjust timing for 9600 baud
    end
endtask

endmodule
