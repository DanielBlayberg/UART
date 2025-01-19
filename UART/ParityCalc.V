
module Parity(
  input wire         reset_n,     
  input wire  [7:0]  data_in,     
  input wire  [1:0]  parity_type, // Parity type agreed upon by the Tx and Rx units.

  output reg         parity_bit   
);

  // Encoding for the parity types
  localparam ODD        = 2'b01,
             Even       = 2'b10,
             NONE       = 2'b00;  // No parity

  integer count;

  always @(*) begin
    count = 0; 
    if (!reset_n) begin
        parity_bit = 1'b1; 
    end else begin
        for (integer i = 0; i < 8; i = i + 1) begin
            count = count + data_in[i];
        end

        case (parity_type)
            ODD:    parity_bit = (count % 2 == 0) ? 1'b1 : 1'b0;  
            Even:   parity_bit = (count % 2 == 0) ? 1'b0 : 1'b1;  
            NONE:   parity_bit = 1'b0;                           
            default:parity_bit = 1'b1;                            
        endcase
    end
  end

endmodule

/*
ODD:     parity_bit = (^data_in)? 1'b0 : 1'b1;
    Even:    parity_bit = (^data_in)? 1'b1 : 1'b0;
*/   
