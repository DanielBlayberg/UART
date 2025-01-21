`timescale 1ns/1ps
module BaudTest;

// Regs to drive inputs
reg        reset_n;
reg        system_clk;
reg  [1:0] baud_rate;

// Wires to show outputs
wire       baud_clk;
wire       clock_stable;

// Instance of the design module
BaudGenR ForTest(
    .reset_n(reset_n),
    .system_clk(system_clk),
    .baud_rate(baud_rate),
    .baud_clk(baud_clk),
    .clock_stable(clock_stable)
);

// Waveform dump
initial begin
    $dumpfile("BaudTest.vcd");
    $dumpvars(0, BaudTest);
end

// 200MHz system clock
initial begin
    system_clk = 1'b0;
    forever #2.5 system_clk = ~system_clk;  // 200MHz clock
end

// Reset logic
initial begin
    reset_n = 1'b0;  // Assert reset
    #50 reset_n = 1'b1;  // Deassert reset after 50ns
end

// Test different Baud Rates
integer i;
initial begin
    $display("Starting Baud Rate Test...");
    for (i = 0; i < 4; i = i + 1) begin
        baud_rate = i;  // Set baud rate configuration
        case (i)
            0: #208330;  // Wait for stable clock at 9600 bps
            1: #104160;  // Wait for stable clock at 19200 bps
            2: #52080;   // Wait for stable clock at 38400 bps
            3: #34720;   // Wait for stable clock at 57600 bps
        endcase
        $display("Testing Baud Rate Configuration: %b", baud_rate);
    end
    $stop;  // End simulation
end

// Monitor signals
initial begin
    $monitor("Time = %0t | reset_n = %b | baud_rate = %b | baud_clk = %b | clock_stable = %b",
             $time, reset_n, baud_rate, baud_clk, clock_stable);
end

endmodule
