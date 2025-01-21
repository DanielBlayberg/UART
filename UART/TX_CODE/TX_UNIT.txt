module TxUnit(
    input wire          reset_n,        // Active low reset
    input wire          start_send,     // Start transmission signal
    input wire          system_clk,     // The main system clock
    input wire  [1:0]   parity_mode,    // Parity type (ODD, EVEN, NONE)
    input wire  [1:0]   baud_config,    // Baud Rate configuration
    input wire  [7:0]   input_data,     // Parallel data input

    output              serial_out,     // Serial transmitter's data out
    output              is_transmitting, // High when transmitting
    output              transmission_done // High when transmission is done
);

    // Internal connections
    wire parity_bit_w;
    wire baud_clk_w;
    wire clock_stable_w;

    // Baud generator unit instantiation
    BAUDGEN BaudGenUnit(
        // Inputs
        .reset_n(reset_n),
        .system_clk(system_clk),
        .baud_config(baud_config),

        // Outputs
        .baud_pulse(baud_clk_w),
        .clock_stable(clock_stable_w)
    );

    // Parity calculation unit instantiation
    Parity ParityUnit(
        // Inputs
        .reset_n(reset_n),
        .data_in(input_data),
        .parity_type(parity_mode),

        // Output
        .parity_bit(parity_bit_w)
    );

    // PISO shift register unit instantiation
    PISO_UART PISOUnit(
        // Inputs
        .reset_n(reset_n),
        .start_send(start_send),
        .baud_clock(baud_clk_w),
        .parity_bit(parity_bit_w),
        .parallel_data(input_data),

        // Outputs
        .serial_out(serial_out),
        .is_transmitting(is_transmitting),
        .transmission_done(transmission_done)
    );

endmodule
