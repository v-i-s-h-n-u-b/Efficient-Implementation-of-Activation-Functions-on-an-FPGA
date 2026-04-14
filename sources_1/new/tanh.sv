`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2024 17:49:10
// Design Name: 
// Module Name: tanh
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
module tanh(
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
  
  wire A = integer_part[6];
  wire B = integer_part[5];
  wire C = integer_part[4];
  wire D = integer_part[3];
  wire E = integer_part[2];
  wire F = integer_part[1];
  wire G = integer_part[0];
  
 
  assign partial_output[15]= 0;
  assign partial_output[14]= 1;
  assign partial_output[13]= 1;
  assign partial_output[12]= 1;
  assign partial_output[11]= 1;
  assign partial_output[10]= A | B | C | D | (E & F);
  assign partial_output[9]= A | B | (C & D) | (E & ~C & ~D & ~F) | (F & ~C & ~D & ~E);
  assign partial_output[8]= ~A & ~B & (C | E | G) & (~C | ~D) & (E | F | ~D) & (C | D | ~E | ~F);
  assign partial_output[7]= A | (B & C) | (B & D & E) | (B & D & F) | (C & F & ~D) | (C & G & ~D) | (E & ~B & ~D & ~F) | (F & ~B & ~C & ~E & ~G) | (G & ~B & ~C & ~E & ~F);
  assign partial_output[6]= A | (B & C & D & E) | (B & C & D & F) | (B & ~C & ~D) | (C & E & ~B & ~D) | (E & G & ~B & ~D) | (B & ~C & ~E & ~F) | (D & E & F & ~B & ~C) | (C & ~B & ~D & ~F & ~G) | (D & ~B & ~C & ~E & ~G);
  assign partial_output[5]= (A & B) | (A & C) | (A & D & E) | (A & D & F) | (B & E & ~D) | (B & C & F & ~D) | (B & C & G & ~D) | (C & D & E & ~B) | (C & F & G & ~B) | (B & D & ~E & ~F) | (D & G & ~B & ~C & ~F) | (E & F & ~A & ~D & ~G) | (D & ~A & ~C & ~E & ~F) | (E & G & ~A & ~B & ~C & ~F) | (F & G & ~A & ~B & ~D & ~E) | (C & ~B & ~D & ~E & ~F & ~G);
  assign partial_output[4]= (A & B) | (A & C & D) | (A & ~C & ~D) | (B & D & ~E & ~F) | (B & C & E & F & ~D) | (B & D & E & F & ~C) | (B & F & G & ~C & ~D) | (C & D & F & ~B & ~G) | (C & E & G & ~A & ~D) | (D & E & G & ~A & ~B) | (D & E & G & ~A & ~C) | (B & F & ~C & ~D & ~E) | (D & ~C & ~E & ~F & ~G) | (C & ~A & ~B & ~D & ~E & ~G) | (C & ~A & ~D & ~E & ~F & ~G) | (D & ~A & ~B & ~C & ~E & ~G) | (D & ~A & ~B & ~C & ~F & ~G);
  assign partial_output[3]= (A & B & D) | (A & C & ~D) | (C & F & G & ~D) | (A & E & ~B & ~D) | (B & D & ~E & ~F) | (C & F & ~B & ~D) | (A & E & F & G & ~C) | (B & C & D & G & ~F) | (B & D & F & G & ~C) | (C & D & E & F & ~A) | (E & F & G & ~A & ~B) | (B & C & ~D & ~F & ~G) | (B & G & ~A & ~C & ~E) | (D & G & ~A & ~E & ~F) | (D & ~A & ~C & ~F & ~G) | (D & ~C & ~E & ~F & ~G) | (B & G & ~A & ~C & ~D & ~F) | (D & E & ~A & ~B & ~F & ~G) | (D & F & ~A & ~B & ~E & ~G) | (B & E & F & ~A & ~C & ~D & ~G);
  assign partial_output[2]= (B | C | D | F) & (A | B | C | D | E) & (A | C | D | F | ~E) & (B | C | D | G | ~E) & (B | D | E | G | ~C) & (C | ~A | ~B | ~D) & (A | B | F | ~D | ~E) & (A | B | G | ~C | ~E) & (B | E | F | ~A | ~G) & (B | E | G | ~D | ~F) & (A | C | ~B | ~F | ~G) & (A | D | ~B | ~C | ~G) & (A | F | ~B | ~E | ~G) & (B | E | ~C | ~D | ~F) & (B | F | ~A | ~C | ~D) & (D | E | ~A | ~B | ~C) & (D | F | ~A | ~B | ~C) & (C | E | F | G | ~B | ~D) & (C | ~A | ~D | ~F | ~G) & (C | ~B | ~E | ~F | ~G) & (A | E | G | ~C | ~D | ~F) & (A | D | ~C | ~E | ~F | ~G);
  assign partial_output[1]= (B | D | E | F | G) & (E | G | ~B | ~D) & (A | C | D | F | ~E) & (E | ~B | ~D | ~F) & (G | ~C | ~D | ~F) & (B | C | F | ~D | ~G) & (C | E | F | ~A | ~B) & (A | E | ~C | ~D | ~F) & (B | C | ~D | ~E | ~G) & (E | F | ~A | ~C | ~D) & (F | G | ~A | ~B | ~D) & (A | B | C | E | ~F | ~G) & (A | B | D | G | ~E | ~F) & (A | C | E | G | ~B | ~F) & (B | C | E | G | ~A | ~F) & (B | C | F | G | ~A | ~E) & (D | ~B | ~C | ~E | ~F) & (A | B | F | ~C | ~D | ~E) & (B | D | F | ~A | ~C | ~E) & (~A | ~C | ~D | ~E | ~F) & (C | D | ~A | ~E | ~F | ~G) & (F | ~B | ~C | ~D | ~E | ~G) & (B | D | E | ~A | ~C | ~F | ~G);
  assign partial_output[0]= (A | B | G | ~F) & (B | F | G | ~D) & (A | B | C | E | G) & (E | F | ~A | ~D) & (A | C | D | G | ~F) & (A | C | E | G | ~F) & (B | C | D | F | ~A) & (B | D | E | F | ~G) & (A | B | C | ~D | ~F) & (A | B | F | ~C | ~E) & (A | C | F | ~B | ~G) & (A | C | F | ~D | ~E) & (C | D | E | ~A | ~F) & (E | F | G | ~C | ~D) & (B | E | ~A | ~C | ~G) & (C | F | ~B | ~D | ~G) & (C | D | F | G | ~A | ~E) & (B | ~A | ~D | ~E | ~F) & (C | ~A | ~D | ~E | ~F) & (E | ~A | ~B | ~C | ~D) & (E | ~C | ~D | ~F | ~G) & (A | D | F | ~B | ~E | ~G) & (E | F | G | ~A | ~B | ~C) & (D | G | ~A | ~C | ~E | ~F) & (A | ~B | ~C | ~D | ~E | ~F) & (D | ~A | ~B | ~E | ~F | ~G);

  
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
            if(start) begin
                if(x==32'b0 | x==32'b10000000000000000000000000000000)begin 
                    y=32'b0;
                    done=1;
                    div_valid=0;
                    next_state=Reset;    
                end
                else if(x[31]==0 & x>=32'b01000000010000000000000000000000)begin
                    y=32'b00111111100000000000000000000000;
                    done=1;
                    div_valid=0;
                    next_state=Reset; 
                end
                else if(x[31]==1 & (x&32'b01111111111111111111111111111111)>32'b01000000010000000000000000000000)begin
                    y=32'b10111111100000000000000000000000;
                    done=1;
                    div_valid=0;
                    next_state=Reset;
                end
                else begin
                    div_a=x;
                    done=0;
                    div_valid=1;
                    next_state=Waiting;
                end
            end
            else begin 
                next_state=Reset;
                done=0;
            end
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
                next_state=Waiting;
                div_valid=1;
                done=0;    
            end
        end
        Last: begin
            y={x[31],partial_output,15'b0};
            done=1;
            div_valid=0;
            next_state=Reset;
        end
    endcase
  end

endmodule
