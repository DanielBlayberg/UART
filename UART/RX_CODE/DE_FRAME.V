module DeFrame (
    input wire  [10:0]  frame_parallel,  // Full frame from the SIPO unit
    input wire          frame_ready,     // Indicates the frame is ready for processing

    output reg          extracted_parity, // The parity bit separated from the data frame
    output reg          extracted_start,  // The Start bit separated from the data frame
    output reg          extracted_stop,   // The Stop bit separated from the data frame
    output reg          frame_done,       // Indicates that the frame has been processed
    output reg  [7:0]   data_payload      // The 8-bit data separated from the frame
);

    // Extracting frame components
    always @(*) begin
        extracted_start  = frame_parallel[0];         // Start bit (LSB)
        data_payload     = frame_parallel[8:1];      // Data payload (8 bits)
        extracted_parity = frame_parallel[9];        // Parity bit
        extracted_stop   = frame_parallel[10];       // Stop bit (MSB)
        frame_done       = frame_ready;             // Pass the ready signal
    end

endmodule
