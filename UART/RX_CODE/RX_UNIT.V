module RxUnit(
    input wire         reset_n,      // Active low reset.
    input wire         data_tx,      // Serial data received from the transmitter.
    input wire         clock,        // The System's main clock.
    input wire  [1:0]  parity_type,  // Parity type agreed upon by the Tx and Rx units.
    input wire  [1:0]  baud_rate,    // Baud Rate agreed upon by the Tx and Rx units.

    output             active_flag,  // High when data is in progress.
    output             done_flag,    // High when data is received.
    output      [2:0]  error_flag,   // Error flags: [StopError, StartError, ParityError].
    output      [7:0]  data_out      // The 8-bit data separated from the frame.
);

// Intermediate wires
wire baud_clk_w;              // The clocking signal from the baud generator.
wire [10:0] data_parallel_w;  // Parallel data output from the SIPO unit.
wire data_ready_w;            // Indicates that a full frame is ready in the SIPO unit.
wire parity_bit_w;            // Parity bit from the DeFrame unit.
wire start_bit_w;             // Start bit from the DeFrame unit.
wire stop_bit_w;              // Stop bit from the DeFrame unit.

// Baud Generator Instance
BaudGenR BaudGen (
    .reset_n(reset_n),
    .system_clk(clock),
    .baud_rate(baud_rate),

    .baud_clk(baud_clk_w),
    .clock_stable() // Unused output
);

// SIPO Receiver Instance
SIPO_Receiver SIPO (
    .reset_active_low(reset_n),
    .serial_data_in(data_tx),
    .baud_clock(baud_clk_w),

    .is_active(active_flag),
    .data_ready(data_ready_w),
    .parallel_data_out(data_parallel_w)
);

// DeFramer Instance
DeFrame DeFramer (
    .frame_parallel(data_parallel_w),
    .frame_ready(data_ready_w),

    .extracted_parity(parity_bit_w),
    .extracted_start(start_bit_w),
    .extracted_stop(stop_bit_w),
    .frame_done(done_flag),
    .data_payload(data_out)
);

// Error Checking Instance
ErrorChecker ErrorCheck (
    .reset_active_low(reset_n),
    .frame_ready(done_flag),
    .received_frame({stop_bit_w, parity_bit_w, start_bit_w, data_out}),
    .received_parity(parity_bit_w),
    .received_start(start_bit_w),
    .received_stop(stop_bit_w),
    .parity_mode(parity_type),

    .error_location(), // Unused output
    .corrected(),      // Unused output
    .corrected_data(), // Unused output
    .global_error_flag(), // Unused output
    .frame_error_flag(error_flag)
);

endmodule
