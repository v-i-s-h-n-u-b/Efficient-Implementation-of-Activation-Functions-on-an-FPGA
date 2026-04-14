`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2024 04:04:16 PM
// Design Name: 
// Module Name: exp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module exp(
    input logic clk,rst_n,
    input logic start,
    output logic done,
    input logic [31:0]x,
    output logic [31:0]y,
    output logic [31:0]div_a,
    output logic [31:0]div_b,
    output logic div_valid,
    input logic div_done,
    input logic [31:0]div_data
    );
    
   logic sign;
  logic [7:0] exponent;
  logic [22:0] mantissa;
  logic [23:0] mantissa_extended; // Including implicit leading 1
  logic [7:0] actual_exponent;
  logic [31:0] shifted_mantissa;
  logic rounding_bit;
  logic [6:0]integer_part;
  logic [15:0]partial_output;
  logic [31:0]x_new;
  
  wire A = integer_part[6];
  wire B = integer_part[5];
  wire C = integer_part[4];
  wire D = integer_part[3];
  wire E = integer_part[2];
  wire F = integer_part[1];
  wire G = integer_part[0];
  
  assign partial_output[15]= A & (B | C) & (B | D) & (B | E) & (B | F | G);
  assign partial_output[14]= ~A | (~B & ~C) | (~B & ~D) | (~B & ~E) | (~B & ~F & ~G);
  assign partial_output[13]= ~A | (~B & ~C) | (~B & ~D) | (~B & ~E) | (~B & ~F & ~G);
  assign partial_output[12]= ~A | (~B & ~C) | (~B & ~D) | (~B & ~E) | (~B & ~F & ~G);
  assign partial_output[11]= ~A | (~B & ~C) | (~B & ~D) | (~B & ~E) | (~B & ~F & ~G);
  assign partial_output[10]= ~A | (~B & ~C) | (~B & ~D) | (~B & ~E) | (~B & ~F & ~G);
  assign partial_output[9]= (A | B) & (~A | ~B) & (A | C | D | E | F) & (A | C | D | E | G) & (B | ~C | ~D | ~E | ~F) & (B | ~C | ~D | ~E | ~G);
  assign partial_output[8]= (A & ~B & ~E) | (C & ~B & ~D) | (D & ~A & ~B) | (A & B & C & D & E) | (E & F & ~B & ~C) | (E & G & ~B & ~C) | (A & ~B & ~F & ~G) | (A & C & D & F & G & ~E) | (B & ~A & ~C & ~D & ~E & ~F) | (B & ~A & ~C & ~D & ~E & ~G);
  assign partial_output[7]= (A | C | ~D) & (B | C | ~A) & (C | E | ~A) & (A | D | E | ~C) & (C | D | ~E | ~G) & (C | F | ~B | ~E) & (C | G | ~E | ~F) & (A | B | D | F | ~C) & (B | D | E | F | G | ~C) & (C | E | ~B | ~F | ~G) & (F | ~A | ~B | ~D | ~E) & (F | ~A | ~D | ~E | ~G) & (~A | ~C | ~D | ~E | ~F) & (E | ~A | ~B | ~D | ~F | ~G);
  assign partial_output[6]= (A | B | E | ~D) & (A | C | E | ~D) & (A | E | F | ~D) & (C | D | F | ~A) & (C | D | G | ~A) & (A | D | ~B | ~E) & (B | D | ~A | ~G) & (B | D | ~E | ~F) & (D | E | ~A | ~B) & (D | E | ~A | ~F) & (A | B | C | G | ~D) & (A | B | F | G | ~D) & (D | F | G | ~A | ~E) & (B | C | E | F | G | ~A) & (A | B | C | F | ~E | ~G) & (A | C | D | ~B | ~F | ~G) & (~A | ~B | ~C | ~D | ~E) & (~A | ~C | ~D | ~E | ~F) & (~A | ~C | ~D | ~E | ~G) & (E | ~A | ~B | ~C | ~F | ~G) & (~A | ~B | ~D | ~E | ~F | ~G);
  assign partial_output[5]= (A | B | E | F) & (B | E | F | ~G) & (B | C | D | E | F) & (A | C | ~B | ~E) & (A | B | D | G | ~F) & (A | C | D | ~E | ~G) & (A | F | G | ~B | ~E) & (B | C | E | ~A | ~F) & (B | D | E | ~A | ~F) & (C | E | F | ~A | ~B) & (D | E | F | ~A | ~B) & (A | B | ~E | ~F | ~G) & (B | F | ~C | ~D | ~G) & (B | C | F | G | ~A | ~E) & (B | D | F | G | ~A | ~E) & (B | ~C | ~D | ~E | ~F) & (A | C | D | ~B | ~F | ~G) & (B | E | G | ~A | ~C | ~D) & (C | E | G | ~A | ~D | ~F) & (~A | ~B | ~C | ~D | ~E) & (~A | ~B | ~E | ~F | ~G) & (A | E | ~B | ~C | ~D | ~F) & (D | F | ~B | ~C | ~E | ~G) & (D | G | ~B | ~C | ~E | ~F) & (E | ~B | ~C | ~D | ~F | ~G);
  assign partial_output[4]= (A | D | F | G | ~C) & (A | E | F | G | ~B) & (B | C | D | E | F | G) & (A | B | C | ~F | ~G) & (A | B | D | ~E | ~F) & (A | B | D | ~F | ~G) & (A | C | F | ~B | ~D) & (A | D | F | ~B | ~C) & (B | C | F | ~A | ~G) & (B | C | G | ~A | ~F) & (B | D | F | ~A | ~G) & (C | F | G | ~B | ~E) & (D | E | G | ~A | ~F) & (B | F | ~A | ~E | ~G) & (F | G | ~A | ~B | ~D) & (A | B | C | D | ~E | ~G) & (A | B | E | G | ~D | ~F) & (A | C | D | E | ~F | ~G) & (A | C | F | G | ~D | ~E) & (C | ~A | ~B | ~F | ~G) & (E | ~A | ~D | ~F | ~G) & (E | F | G | ~A | ~C | ~D) & (A | D | ~C | ~E | ~F | ~G) & (A | F | ~C | ~D | ~E | ~G) & (A | G | ~B | ~C | ~D | ~F) & (D | F | ~B | ~C | ~E | ~G) & (D | G | ~A | ~B | ~C | ~F) & (B | ~A | ~C | ~D | ~E | ~F) & (E | ~B | ~C | ~D | ~F | ~G);
  assign partial_output[3]= (A & B & E & ~G) | (A & C & E & F & G) | (B & D & E & F & G) | (B & C & E & F & ~G) | (C & E & F & G & ~B) | (A & D & F & ~B & ~E) | (A & D & F & ~E & ~G) | (B & D & G & ~A & ~C) | (A & C & ~B & ~E & ~G) | (A & D & ~C & ~E & ~G) | (A & E & ~C & ~D & ~G) | (A & F & ~B & ~C & ~G) | (B & E & ~C & ~D & ~G) | (B & C & F & G & ~A & ~E) | (A & B & G & ~C & ~D & ~E) | (A & C & E & ~B & ~D & ~F) | (B & C & G & ~A & ~D & ~F) | (B & C & G & ~D & ~E & ~F) | (E & F & G & ~A & ~C & ~D) | (~A & ~B & ~D & ~E & ~G) | (A & G & ~C & ~D & ~E & ~F) | (C & E & ~A & ~B & ~F & ~G) | (D & E & ~A & ~B & ~C & ~G) | (D & G & ~A & ~B & ~E & ~F) | (F & G & ~A & ~B & ~C & ~E) | (F & ~A & ~C & ~D & ~E & ~G) | (B & C & D & ~A & ~E & ~F & ~G);
  assign partial_output[2]= (A & B & D & F & ~E) | (A & C & D & E & F & G) | (A & B & E & ~C & ~F) | (A & B & E & ~C & ~G) | (B & D & ~C & ~E & ~F) | (B & D & ~E & ~F & ~G) | (B & F & ~A & ~D & ~E) | (C & E & ~A & ~D & ~F) | (C & F & ~B & ~E & ~G) | (C & G & ~A & ~B & ~F) | (D & E & ~A & ~B & ~C) | (E & F & ~A & ~B & ~C) | (A & B & C & F & ~D & ~G) | (A & B & C & G & ~D & ~F) | (A & C & D & E & ~B & ~G) | (A & C & F & G & ~B & ~D) | (B & C & D & E & ~A & ~G) | (B & C & D & G & ~A & ~E) | (B & E & F & G & ~C & ~D) | (B & ~A & ~C & ~E & ~G) | (C & ~A & ~B & ~D & ~E) | (E & ~B & ~C & ~F & ~G) | (E & ~B & ~D & ~F & ~G) | (F & ~B & ~D & ~E & ~G) | (A & F & G & ~B & ~C & ~E) | (D & ~A & ~B & ~C & ~F & ~G);
  assign partial_output[1]= (B & D & E & ~A) | (B & C & E & F & G) | (B & E & F & G & ~A) | (B & ~D & ~F & ~G) | (E & ~A & ~F & ~G) | (A & B & C & ~F & ~G) | (A & B & E & ~C & ~F) | (A & C & E & ~D & ~G) | (B & C & G & ~A & ~F) | (B & D & E & ~C & ~G) | (C & D & E & F & G & ~A) | (C & E & ~A & ~D & ~F) | (D & E & ~C & ~F & ~G) | (A & C & D & F & ~B & ~G) | (A & D & F & G & ~B & ~E) | (B & D & F & G & ~A & ~C) | (A & ~D & ~E & ~F & ~G) | (B & ~C & ~D & ~E & ~F) | (E & ~A & ~B & ~C & ~G) | (F & ~B & ~C & ~D & ~G) | (A & C & G & ~B & ~E & ~F) | (A & E & G & ~C & ~D & ~F) | (A & F & G & ~B & ~C & ~E) | (C & D & ~A & ~B & ~E & ~G) | (D & G & ~A & ~B & ~C & ~F) | (F & ~A & ~C & ~D & ~E & ~G) | (G & ~A & ~B & ~C & ~D & ~E);
  assign partial_output[0]= (E & F & G & ~B) | (C & G & ~B & ~D) | (A & D & F & G & ~C) | (G & ~B & ~D & ~F) | (A & B & D & ~C & ~E) | (A & B & F & ~C & ~G) | (A & B & F & ~E & ~G) | (A & C & E & ~B & ~G) | (C & E & G & ~A & ~B) | (E & F & G & ~C & ~D) | (A & B & C & D & E & ~F) | (E & G & ~A & ~D & ~F) | (A & C & D & G & ~E & ~F) | (B & C & D & F & ~E & ~G) | (B & C & D & G & ~E & ~F) | (B & C & E & F & ~D & ~G) | (A & ~C & ~D & ~E & ~G) | (C & ~A & ~B & ~D & ~E) | (C & ~A & ~D & ~E & ~F) | (B & D & E & ~A & ~F & ~G) | (B & F & G & ~A & ~C & ~E) | (B & F & G & ~A & ~D & ~E) | (B & D & ~A & ~C & ~F & ~G) | (B & E & ~C & ~D & ~F & ~G) | (D & E & ~B & ~C & ~F & ~G) | (F & ~A & ~B & ~C & ~D & ~G) | (F & ~A & ~B & ~C & ~E & ~G);
         
localparam BIAS = 127;
  
    assign sign=div_data[31];
    assign exponent=div_data[30:23];
    assign mantissa=div_data[22:0];
    assign mantissa_extended={1'b1, mantissa};
    
    assign actual_exponent = exponent - BIAS;
    assign div_b=32'b00111100110000011000000000000000;
                     
    typedef enum {Reset, Compute, Waiting,Last} States;
    States present_state=Reset;
    States next_state=Reset;
    
    Addition_Subtraction X4(x,32'b00111111110000000000000000000000,1'b0,,x_new);
    
    always @(posedge(clk) or negedge(rst_n))
    begin
      if(!rst_n) present_state<=Reset;
      else present_state<=next_state;
    end
    
    always_comb
    begin
      case(present_state)
          Reset: begin
              div_valid=0;
              done=0;
              if(start) next_state=Compute;
              else next_state=Reset;
          end
          Compute: begin
            done=0;
            if(start) begin
                  div_a=x_new;
                  div_valid=1;
                  next_state=Waiting;
             end
             else next_state=Reset;
          end
          Waiting: begin
              if(div_done) begin
                  div_valid=0;
                  integer_part = 0;     
                  if (exponent == 0 || exponent < BIAS) begin
                      // Special cases: zero or subnormal numbers
                      integer_part = 0;
                  end 
                  else if (actual_exponent < 23) begin
                      // Shift mantissa to the right to discard fractional bits
                      shifted_mantissa = mantissa_extended >> (23 - actual_exponent);
                      // Get the rounding bit (the most significant discarded bit)
                      rounding_bit = (mantissa_extended >> (22 - actual_exponent)) & 1'b1;
                      
                      // Apply rounding
                      if (rounding_bit == 1)
                          shifted_mantissa = shifted_mantissa + 1;
                          
                      integer_part = shifted_mantissa[6:0];  // Limit to 7 bits
                  end 
                  else begin
                      // Shift mantissa to the left if exponent is 23 or greater
                      integer_part = (mantissa_extended << (actual_exponent-23))& 7'b1111111;  // Limit to 7 bits
                   end
                   
                   
                   done=0;
                   next_state=Last;
              end
              else begin
                  div_valid=1;
                  next_state=Waiting;
                  done=0;    
              end
          end
          Last: begin
            y={1'b0,partial_output,15'b0};
            done=1;
            div_valid=0;
            next_state=Reset;
          end
      endcase
    end
  
  endmodule