`timescale 1ns/1ps
module RxTest;

// Inputs
reg         reset_n;
reg         data_tx;
reg         clock;
reg  [1:0]  parity_type;
reg  [1:0]  baud_rate;

// Outputs
wire        done_flag;
wire        active_flag;
wire [2:0]  error_flag;
wire [7:0]  data_out;

// DUT Instance
RxUnit ForTest(
    .reset_n(reset_n),
    .data_tx(data_tx),
    .clock(clock),
    .parity_type(parity_type),
    .baud_rate(baud_rate),

    .active_flag(active_flag),
    .done_flag(done_flag),
    .error_flag(error_flag),
    .data_out(data_out)
);

// Waveform dump
initial begin
    $dumpfile("RxTest.vcd");
    $dumpvars(0, RxTest);
end

// Monitor signals
initial begin
    $monitor("Time=%0t | Reset=%b | Data_TX=%b | BaudRate=%b | Parity=%b | Active=%b | Done=%b | Errors=%b | DataOut=%b",
             $time, reset_n, data_tx, baud_rate, parity_type, active_flag, done_flag, error_flag, data_out);
end

// Clock generation: 100MHz
initial begin
    clock = 1'b0;
    forever #5 clock = ~clock;
end

// Reset and configuration
initial begin
    reset_n = 0;
    #50 reset_n = 1;
end

// Test cases
initial begin
    baud_rate = 2'b10;  // Baud rate for 9600
    parity_type = 2'b01;  // Odd parity
    send_frame(11'b1_10010101_1);  // Valid frame
    #100;

    baud_rate = 2'b11;  // Baud rate for 19200
    parity_type = 2'b10;  // Even parity
    send_frame(11'b1_11001100_1);  // Valid frame
    #100;

    $stop;
end

// Task to send a frame
task send_frame(input [10:0] frame);
    integer i;
    for (i = 0; i < 11; i = i + 1) begin
        data_tx = frame[i];
        #(5208 * (1 << baud_rate));  // Adjust timing for baud rate
    end
endtask

endmodule
