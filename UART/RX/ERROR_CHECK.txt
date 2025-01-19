module ErrorChecker (
    input wire         reset_active_low,  // Active low reset
    input wire         frame_ready,       // Indicates a frame is ready for checking
    input wire  [12:0] received_frame,    // Received frame: 8 data bits + 5 parity bits
    input wire         received_parity,   // The parity bit from the received frame
    input wire         received_start,    // The Start bit from the received frame
    input wire         received_stop,     // The Stop bit from the received frame
    input wire  [1:0]  parity_mode,       // Parity type agreed upon by Tx and Rx
    output reg  [3:0]  error_location,    // Location of the error (0 if no error)
    output reg         corrected,         // High if correction was applied
    output reg  [7:0]  corrected_data,    // Corrected data output
    output reg         global_error_flag, // High if any error is detected
    output reg  [2:0]  frame_error_flag   // {stop_error, start_error, parity_error}
);

    // Internal signals
    reg [4:0] calculated_parity; // Parity bits computed from received data
    reg [4:0] received_parity_bits;   // Parity bits extracted from received frame
    reg [7:0] data_bits;         // Extracted data bits from the received frame
    reg [4:0] syndrome;          // Syndrome for error detection

    reg parity_error;
    reg start_error;
    reg stop_error;

    // Extract data and parity bits
    always @(*) begin
        data_bits = received_frame[12:5]; // 8 MSBs are data bits
        received_parity_bits = received_frame[4:0]; // 5 LSBs are parity bits
    end

    // Calculate parity bits from the received data
    always @(*) begin
        calculated_parity[0] = data_bits[0] ^ data_bits[1] ^ data_bits[3] ^ data_bits[4] ^ data_bits[6];
        calculated_parity[1] = data_bits[0] ^ data_bits[2] ^ data_bits[3] ^ data_bits[5] ^ data_bits[6];
        calculated_parity[2] = data_bits[1] ^ data_bits[2] ^ data_bits[3] ^ data_bits[7];
        calculated_parity[3] = data_bits[4] ^ data_bits[5] ^ data_bits[6] ^ data_bits[7];
        calculated_parity[4] = data_bits[0] ^ data_bits[1] ^ data_bits[2] ^ data_bits[3] ^
                               data_bits[4] ^ data_bits[5] ^ data_bits[6] ^ data_bits[7];
    end

    // Syndrome calculation for error detection
    always @(*) begin
        syndrome = received_parity_bits ^ calculated_parity; // XOR to find differences
    end

    // Error detection and correction
    always @(*) begin
        // Parity check for data bits
        parity_error = (parity_mode == 2'b01) ? ~(^data_bits) != received_parity :
                       (parity_mode == 2'b10) ? (^data_bits) != received_parity :
                       1'b0;

        // Start and Stop Bit checks
        start_error = (received_start != 1'b0); // Start bit must be 0
        stop_error = (received_stop != 1'b1);  // Stop bit must be 1

        // Frame-level error reporting
        frame_error_flag = {stop_error, start_error, parity_error};

        // Correction for data bits using syndrome
        if (syndrome != 5'b00000) begin
            error_location = syndrome; // Syndrome indicates the error location
            corrected_data = data_bits ^ (1 << (error_location - 1)); // Flip the erroneous bit
            corrected = 1'b1;
        end else begin
            error_location = 4'd0; // No error
            corrected_data = data_bits; // Data is correct
            corrected = 1'b0;
        end

        // Global error flag
        global_error_flag = |frame_error_flag || (syndrome != 5'b00000);
    end

endmodule
