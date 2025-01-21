module BaudGenR(
    input wire          reset_n,     // Active low reset
    input wire          system_clk,  // The system's main clock (200 MHz)
    input wire  [1:0]   baud_rate,   // Baud Rate configuration

    output reg          baud_clk,    // Clocking output for other modules
    output reg          clock_stable // Indicates when the clock is stable
);

    // Internal declarations
    reg [15:0] threshold;   // Threshold value based on baud_rate
    reg [15:0] clock_ticks; // Counter for clock pulses

    // Baud rate configuration mapping
    always @(*) begin
        case (baud_rate)
            2'b00: threshold = 16'd20833; // 9600 bps
            2'b01: threshold = 16'd10416; // 19200 bps
            2'b10: threshold = 16'd5208;  // 38400 bps
            2'b11: threshold = 16'd3472;  // 57600 bps
            default: threshold = 16'd20833; // Default to 9600 bps
        endcase
    end

    // Counter logic for generating baud clock
    always @(posedge system_clk or negedge reset_n) begin
        if (!reset_n) begin
            clock_ticks <= 16'd0;
            baud_clk <= 1'b0;
            clock_stable <= 1'b0; // Reset clock stability
        end else begin
            if (clock_ticks >= threshold) begin
                clock_ticks <= 16'd0; // Reset counter
                baud_clk <= ~baud_clk; // Toggle baud clock
                clock_stable <= 1'b1; // Indicate clock is stable
            end else begin
                clock_ticks <= clock_ticks + 1'd1;
                clock_stable <= 1'b0; // Clock is not stable during counting
            end
        end
    end

endmodule
