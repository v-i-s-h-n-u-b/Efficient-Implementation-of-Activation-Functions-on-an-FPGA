`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2024 12:51:40 PM
// Design Name: 
// Module Name: leaky_relu
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


module leaky_relu(
    input logic clk,rst_n,
    input logic [31:0]x,
    output logic [31:0]y,
    input logic start,
    output logic done
    );
    logic [2:0]temp;
    assign done=(temp==2'b01);
    logic [31:0] mul_result;
    parameter [31:0] ALPHA = 32'b00111100001000111101011100001010;
    
    Multiplication M0(ALPHA, x ,,,, mul_result);
    
    always @(posedge(clk)or negedge(rst_n)) begin
        if(!rst_n | temp==2'b01) begin
            temp<=0;
        end
        else if(start) temp<=temp+1;
    end
    assign y = (x[31]==1'b0)? x: mul_result;
    
    
endmodule
