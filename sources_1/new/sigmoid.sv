`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.11.2024 12:20:22
// Design Name: 
// Module Name: sigmoid
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


module sigmoid(
    input logic clk,
    input logic  rst_n,
    input logic  start,
    output logic  done,
    input logic  [31:0]x,
    output logic  [31:0]y,
    output logic tanh_valid,
    input logic tanh_done,
    output logic [31:0]tanh_input,
    input logic [31:0]tanh_output
    );
    logic sign;
    logic [7:0] exponent;
    logic [22:0] mantissa;
        
    logic [31:0]b=32'b00111111100000000000000000000000;
    logic [31:0]add_out;

    assign sign=x[31];
    assign exponent=(x==32'b0)?0:(x[30:23]-1'b1);        // x/2
    assign mantissa=x[22:0];
    assign tanh_input={sign, exponent, mantissa};
    
    typedef enum {Reset, Compute, Waiting,Last} States;
      States present_state=Reset;
      States next_state=Reset;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) present_state<=Reset;
        else present_state<=next_state;
    end
    
    Addition_Subtraction A_S(.a(tanh_output), .b(b),.add_sub_signal(1'b0) ,.res(add_out));
    
    always_comb begin
        case(present_state)
            Reset: begin
                done=0;
                tanh_valid=0;
                if(start) next_state=Compute;
                else next_state=Reset;
            end
            Compute: begin
                done=0;
                if(start) begin
                    tanh_valid=1;
                    next_state=Waiting;
                end
                else next_state=Reset;
            end
            Waiting: begin
                if(!tanh_done) begin
                    next_state=Waiting;
                    done=0;
                    end
                 else begin
                    tanh_valid=0;
                    done=0;
                    next_state=Last;
                 end
            end
            Last: begin
                done=1;
                y={add_out[31],(add_out[31:23]-1'b1),add_out[22:0]};
                next_state=Reset;
                tanh_valid=0;
            end            
        endcase
    end
endmodule
