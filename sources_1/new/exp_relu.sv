`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2024 11:46:54
// Design Name: 
// Module Name: exp_relu
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


module exp_relu(
    input logic clk,
    input logic rst_n,
    input logic [31:0]x,
    input logic start,
    output logic done,
    output logic [31:0]y,
    output logic exp_valid,
    input logic exp_done,
    output logic [31:0]exp_input,
    input logic [31:0]exp_output
    );
    
    logic [31:0]add_res;
    
    typedef enum {Reset, Compute, Waiting,Last} States;
      States present_state=Reset;
      States next_state=Reset;
      
    always @(posedge(clk) or negedge(rst_n))
    begin
        if(!rst_n) present_state<=Reset;
        else present_state<=next_state;
    end
    
    Addition_Subtraction A5(exp_output,32'b10111111100000000000000000000000,1'b0,,add_res);
    always_comb begin
        case(present_state)
            Reset: begin
                done=0;
                exp_valid=0;
                if(start)next_state=Compute;
                else next_state=Reset;
            end
            Compute: begin
              if(start) begin
                if(x[31]==0) begin
                    y=x;
                    done=1;
                    next_state=Reset;
                    exp_valid=0;
                end
                else begin
                    exp_valid=1;
                    exp_input=x;
                    next_state=Waiting;
                end
              end
              else begin
                next_state=Reset;
                done=0;
              end
            end
            Waiting: begin        
                if(exp_done) begin
                    next_state=Last;
                    exp_valid=0;
                    done=0;
                end
                else begin
                    next_state=Waiting;
                    done=0;
                    exp_valid=1;
                end
            end
            Last: begin
                next_state=Reset;
                y=add_res;
                done=1;
                exp_valid=0;
            end
        endcase
    end
endmodule
