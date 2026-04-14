`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2024 19:29:22
// Design Name: 
// Module Name: top
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


module top(
    input logic clk,
    input logic rst_n,
    input logic [31:0]x,
    input logic start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu,
    output logic done,valid,
    output logic [31:0]y
    );
    
    logic done_tanh,done_sigmoid,done_elu,done_relu,done_leakyrelu;
    logic [31:0]tanh_x, sigmoid_x,elu_x,relu_x,leakyrelu_x;
    logic [31:0]div_a,div_a_tanh,div_a_exp;
    logic [31:0]div_b,div_b_tanh,div_b_exp;
    logic div_valid,div_valid_tanh,div_valid_exp;
    logic div_done,div_done_tanh,div_done_exp;
    logic [31:0]div_data,div_data_tanh,div_data_exp;
    logic exception;
    logic tanh_valid,tanh_trigger;
    logic tanh_done,done_t;
    logic [31:0]tanh_input,tanh_i;
    logic [31:0]tanh_output,tanh_o;
    logic start_exp,done_exp;
    logic [31:0]exp_input,exp_x;
    
    always_comb begin
        if(start_tanh) begin
            done=done_tanh;
            y=tanh_x;
        end
        else if(start_sigmoid)begin
            done=done_sigmoid;
            y=sigmoid_x;
        end
        else if(start_elu)begin
            done=done_elu;
            y=elu_x;
        end
        else if(start_relu)begin
            done=done_relu;
            y=relu_x;
        end
        else if(start_leakyrelu)begin
            done=done_leakyrelu;
            y=leakyrelu_x;
        end
        else begin
            done=0;
        end
    end
    assign valid=done;
    
    always_comb begin
        if(div_valid_tanh) begin
            div_valid=1;
            div_a=div_a_tanh;
            div_b=div_b_tanh;
            div_done_tanh=div_done;
            div_data_tanh=div_data;
        end
        else if(div_valid_exp)begin
            div_valid=1;
            div_a=div_a_exp;
            div_b=div_b_exp;
            div_done_exp=div_done;
            div_data_exp=div_data;
        end
        else begin
            div_valid=0;
        end    
    end
    always_comb begin
        if(start_tanh) begin
            tanh_trigger=start_tanh;
            tanh_i=x;
            done_tanh=done_t;
            tanh_x=tanh_o;
        end
        else if(tanh_valid) begin
            tanh_trigger=tanh_valid;
            tanh_i=tanh_input;
            tanh_output=tanh_o;
            tanh_done=done_t;
        end
        else begin
            tanh_trigger=0;
        end
    end
    
    sigmoid s1(.clk(clk), .rst_n(rst_n),.start(start_sigmoid),.done(done_sigmoid),.x(x),.y(sigmoid_x),.tanh_valid(tanh_valid),.tanh_done(tanh_done),.tanh_input(tanh_input),.tanh_output(tanh_output));
    tanh t1(.clk(clk), .rst_n(rst_n), .start(tanh_trigger), .done(done_t), .x(tanh_i), .y(tanh_o), .div_a(div_a_tanh) ,.div_b(div_b_tanh), .div_valid(div_valid_tanh), .div_done(div_done_tanh), .div_data(div_data_tanh));
    division d1(.div_valid(div_valid), .div_done(div_done), .exception(exception), .a(div_a), .b(div_b), .res(div_data));
    exp e1(.clk(clk), .rst_n(rst_n), .start(start_exp), .done(done_exp),.x(exp_input),.y(exp_x),.div_a(div_a_exp),.div_b(div_b_exp),.div_valid(div_valid_exp),.div_done(div_done_exp),.div_data(div_data_exp));
    relu r1(.clk(clk),.rst_n(rst_n),.x(x),.y(relu_x),.start(start_relu),.done(done_relu));
    leaky_relu l_r1(.clk(clk),.rst_n(rst_n),.x(x),.y(leakyrelu_x),.start(start_leakyrelu),.done(done_leakyrelu));
    exp_relu e_r1(.clk(clk),.rst_n(rst_n),.x(x),.start(start_elu),.done(done_elu),.y(elu_x),.exp_valid(start_exp),.exp_done(done_exp),.exp_input(exp_input),.exp_output(exp_x));
 endmodule
