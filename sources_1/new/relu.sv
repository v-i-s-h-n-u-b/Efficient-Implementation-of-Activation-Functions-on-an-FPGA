`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2024 12:31:57 PM
// Design Name: 
// Module Name: relu
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


module relu(
    input clk,rst_n,
    input logic [31:0]x,
    output logic [31:0]y,
    input logic start,
    output logic done
    );
    logic [1:0]temp;
    always @(posedge(clk) or negedge(rst_n)) begin
        if(!rst_n | temp==2'b01) begin 
            temp<=0;
        end
        else if(start) begin
            temp<=temp+1;
        end
    end
    assign done=(temp==2'b01);
    assign y= (x[31]==1'b0)? x : 32'b0;
    
endmodule

