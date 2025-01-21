`timescale 1ns/1ps
module BaudTest;

//  Regs to drive the inputs
reg        reset_n;
reg        system_clk;
reg [1:0]  baud_config;

//  Wires to capture the outputs
wire       baud_pulse;
wire       clock_stable;

//  Instance of the design module
BAUDGEN ForTest (
    .reset_n(reset_n),
    .system_clk(system_clk),
    .baud_config(baud_config),
    .baud_pulse(baud_pulse),
    .clock_stable(clock_stable)
);

//  dump for waveform generation
initial begin
    $dumpfile("BaudTest.vcd");
    $dumpvars(0, BaudTest);
end

//  System's Clock - 100MHz
initial begin
    system_clk = 1'b0;
    forever #5 system_clk = ~system_clk; // 100MHz clock
end

//  Reset the system
initial begin
    reset_n = 1'b0;
    #50 reset_n = 1'b1; // Deassert reset after 50ns
end

//  Test various baud rates
integer i;
initial begin
    $display("Starting Baud Rate Test...");
    for (i = 0; i < 4; i = i + 1) begin
        baud_config = i;
        $display("Testing baud_config = %b at 100MHz clock", baud_config);
        #250000; // Adjusted wait time for 100MHz clock
    end
    #1000000 $stop; // Stop simulation after enough time
end

//  Monitor signals
initial begin
    $monitor("Time = %0t | reset_n = %b | baud_config = %b | baud_pulse = %b | clock_stable = %b",
             $time, reset_n, baud_config, baud_pulse, clock_stable);
end

endmodule
