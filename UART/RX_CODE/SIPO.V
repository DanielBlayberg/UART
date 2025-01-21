module SIPO_Receiver (
    input  wire         reset_active_low,  // Active low reset
    input  wire         serial_data_in,    // Serial data received from the transmitter
    input  wire         baud_clock,        // Clock signal from the sampling unit

    output wire         is_active,         // High when receiving data
    output wire         data_ready,        // High when full frame is received
    output wire  [10:0] parallel_data_out  // 11-bit parallel data frame
);

    // Internal registers
    reg [10:0] frame_register, parallel_data_temp;
    reg [3:0]  bit_counter, clock_counter;
    reg [1:0]  current_state, next_state;

    // State encoding
    localparam STATE_IDLE    = 2'b00,
               STATE_CENTER  = 2'b01,
               STATE_RECEIVE = 2'b10,
               STATE_READY   = 2'b11;

    // State machine logic
    always @(posedge baud_clock or negedge reset_active_low) begin
        if (!reset_active_low) begin
            current_state <= STATE_IDLE;
            clock_counter <= 4'd0;
            bit_counter   <= 4'd0;
            frame_register <= 11'b11111111111; // Default idle frame
        end else begin
            current_state <= next_state;
            case (current_state)
                STATE_IDLE: begin
                    frame_register <= 11'b11111111111; // Reset frame
                    clock_counter <= 4'd0;
                    bit_counter <= 4'd0;
                    if (~serial_data_in) begin
                        next_state <= STATE_CENTER; // Start bit detected
                    end else begin
                        next_state <= STATE_IDLE;
                    end
                end

                STATE_CENTER: begin
                    if (clock_counter == 4'd7) begin
                        clock_counter <= 4'd0;
                        next_state <= STATE_RECEIVE; // Center of start bit
                    end else begin
                        clock_counter <= clock_counter + 4'd1;
                    end
                end

                STATE_RECEIVE: begin
                    if (bit_counter == 4'd10) begin
                        bit_counter <= 4'd0;
                        next_state <= STATE_READY; // Frame fully received
                    end else begin
                        if (clock_counter == 4'd15) begin
                            clock_counter <= 4'd0;
                            bit_counter <= bit_counter + 4'd1;
                            frame_register <= {serial_data_in, frame_register[10:1]}; // Shift in new bit
                        end else begin
                            clock_counter <= clock_counter + 4'd1;
                        end
                    end
                end

                STATE_READY: begin
                    next_state <= STATE_IDLE; // Return to idle
                end
            endcase
        end
    end

    // Parallel data assignment
    assign parallel_data_out = (current_state == STATE_READY) ? frame_register : 11'b11111111111;
    assign data_ready = (current_state == STATE_READY);
    assign is_active = (current_state != STATE_IDLE);

endmodule
