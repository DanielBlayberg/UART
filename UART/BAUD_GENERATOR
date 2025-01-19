module BAUDGEN (
    input wire          reset_n,       // Active low reset
    input wire [1:0]    baud_config,   // Baud rate configuration (2-bit)
    input wire          system_clk,    // System clock
    
    output reg          baud_pulse,    // Generated baud pulse
    output reg          clock_stable   // High if clock is stable
);

    // Internal declarations
    reg [15:0] counter;                // Counter for baud rate generation
    reg [15:0] threshold;              // Threshold value based on baud_config

    // Baud rate configuration mapping
    always @(*) begin
        case (baud_config)
            2'b00: threshold = 16'd10416; // 9600 bps
            2'b01: threshold = 16'd5208;  // 19200 bps
            2'b10: threshold = 16'd2604;  // 38400 bps
            2'b11: threshold = 16'd1302;  // 57600 bps
            default: threshold = 16'd10416; // Default to 9600 bps
        endcase
    end

    // Counter logic for generating baud pulses
    always @(posedge system_clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 16'd0;
            baud_pulse <= 1'b0;
            clock_stable <= 1'b0; // Reset stability flag
        end else begin
            if (counter >= threshold) begin
                counter <= 16'd0; // Reset counter
                baud_pulse <= ~baud_pulse; // Toggle baud pulse
                clock_stable <= 1'b1; // Indicate clock stability
            end else begin
                counter <= counter + 16'd1;
                clock_stable <= 1'b0; // Indicate unstable clock during counting
            end
        end
    end

endmodule
