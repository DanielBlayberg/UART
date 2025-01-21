module PISO_UART(
    input wire           reset_n,         
    input wire           start_send,      
    input wire           baud_clock,      
    input wire           parity_bit,      
    input wire [7:0]     parallel_data,   
  
    output reg           serial_out,      
    output reg           is_transmitting, 
    output reg           transmission_done, 
    output reg           error_flag       
);

    // Internal declarations
    reg [3:0]    bit_counter;         
    reg [10:0]   transmit_frame;      
    reg [10:0]   frame_shift_reg;     
    reg [1:0]    current_state, next_state; 
    wire         is_transmission_done; 
    reg          start_request;       

    // State encoding
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        LOAD_FRAME = 3'b001,
        TRANSMIT = 3'b010,
        DONE = 3'b011,
        ERROR = 3'b100,
        RELOAD_FRAME = 3'b101
    } state_t;

    // Frame generation
    always @(posedge baud_clock or negedge reset_n) begin
        if (!reset_n) begin
            transmit_frame <= 11'b11111111111; 
        end else if (current_state == LOAD_FRAME || current_state == RELOAD_FRAME) begin
            transmit_frame <= {1'b1, parity_bit, parallel_data, 1'b0}; // Stop, parity, data, start
        end
    end

    // Counter logic
    always @(posedge baud_clock or negedge reset_n) begin
        if (!reset_n || current_state == IDLE || is_transmission_done) begin
            bit_counter <= 4'd0; // Reset counter
        end else if (current_state == TRANSMIT) begin
            bit_counter <= bit_counter + 1;
        end
    end

    assign is_transmission_done = (bit_counter == 4'd11); 

    // FSM: Transmission control
    always @(posedge baud_clock or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            error_flag <= 1'b0;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                error_flag = 1'b0;
                if (start_send) next_state = LOAD_FRAME;
                else next_state = IDLE;
            end
            LOAD_FRAME: begin
                if (start_request) next_state = RELOAD_FRAME;
                else next_state = TRANSMIT;
            end
            TRANSMIT: begin
                if (start_send && !is_transmission_done) next_state = ERROR; // Prevent interruption
                else if (is_transmission_done) next_state = DONE;
                else next_state = TRANSMIT;
            end
            DONE: begin
                if (start_request) next_state = RELOAD_FRAME;
                else next_state = IDLE;
            end
            RELOAD_FRAME: begin
                next_state = TRANSMIT;
            end
            ERROR: begin
                error_flag = 1'b1; // Indicate error
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Transmission logic
    always @(posedge baud_clock or negedge reset_n) begin
        if (!reset_n) begin
            frame_shift_reg <= 11'b11111111111;
            serial_out <= 1'b1; // Idle state
            is_transmitting <= 1'b0;
            transmission_done <= 1'b0;
            start_request <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    serial_out <= 1'b1; // Idle
                    is_transmitting <= 1'b0;
                    transmission_done <= 1'b0;
                    start_request <= start_send;
                end
                LOAD_FRAME: begin
                    frame_shift_reg <= transmit_frame;
                end
                TRANSMIT: begin
                    serial_out <= frame_shift_reg[0]; 
                    frame_shift_reg <= frame_shift_reg >> 1; 
                    is_transmitting <= 1'b1;
                    transmission_done <= 1'b0;
                end
                DONE: begin
                    serial_out <= 1'b1; // Return to idle
                    is_transmitting <= 1'b0;
                    transmission_done <= 1'b1;
                end
                ERROR: begin
                    serial_out <= 1'b1; // Return to idle
                    is_transmitting <= 1'b0;
                    transmission_done <= 1'b0;
                end
            endcase
        end
    end

endmodule
