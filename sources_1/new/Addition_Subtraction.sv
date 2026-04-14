`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2024 13:09:43
// Design Name: 
// Module Name: Addition_Subtraction
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


module Addition_Subtraction(
input [31:0] a,b,
input add_sub_signal,														// If 1 then addition otherwise subtraction
output exception,
output [31:0] res      
);

wire operation_add_sub_signal;
wire enable;
wire output_sign;

wire [31:0] op_a,op_b;
wire [23:0] significand_a,significand_b;
wire [7:0] exponent_diff;


wire [23:0] significand_b_add_sub;
wire [7:0] exp_b_add_sub;

wire [24:0] significand_add;
wire [30:0] add_sum;

wire [23:0] significand_sub_complement;
wire [24:0] significand_sub;
wire [30:0] sub_diff;
wire [24:0] subtraction_diff; 
wire [7:0] exp_sub;

assign {enable,op_a,op_b} = (a[30:0] < b[30:0]) ? {1'b1,b,a} : {1'b0,a,b};							// For operations always op_a must not be less than b

assign exp_a = op_a[30:23];
assign exp_b = op_b[30:23];

assign exception = (&op_a[30:23]) | (&op_b[30:23]);										// Exception flag sets 1 if either one of the exponent is 255.

assign output_sign = add_sub_signal ? enable ? !op_a[31] : op_a[31] : op_a[31] ;

assign operation_add_sub_signal = add_sub_signal ? op_a[31] ^ op_b[31] : ~(op_a[31] ^ op_b[31]);				// Assign significand values according to Hidden Bit.

assign significand_a = (|op_a[30:23]) ? {1'b1,op_a[22:0]} : {1'b0,op_a[22:0]};							// If exponent is zero,hidden bit = 0,else 1
assign significand_b = (|op_b[30:23]) ? {1'b1,op_b[22:0]} : {1'b0,op_b[22:0]};

assign exponent_diff = op_a[30:23] - op_b[30:23];										// Exponent difference calculation

assign significand_b_add_sub = significand_b >> exponent_diff;

assign exp_b_add_sub = op_b[30:23] + exponent_diff; 

assign perform = (op_a[30:23] == exp_b_add_sub);										// Checking if exponents are same

// Add Block //
assign significand_add = (perform & operation_add_sub_signal) ? (significand_a + significand_b_add_sub) : 25'd0; 

assign add_sum[22:0] = significand_add[24] ? significand_add[23:1] : significand_add[22:0];					// res will be most 23 bits if carry generated, else least 22 bits.

assign add_sum[30:23] = significand_add[24] ? (1'b1 + op_a[30:23]) : op_a[30:23];						// If carry generates in sum value then exponent is added with 1 else feed as it is.

// Sub Block //
assign significand_sub_complement = (perform & !operation_add_sub_signal) ? ~(significand_b_add_sub) + 24'd1 : 24'd0 ; 

assign significand_sub = perform ? (significand_a + significand_sub_complement) : 25'd0;

priority_encoder pe(significand_sub,op_a[30:23],subtraction_diff,exp_sub);

assign sub_diff[30:23] = exp_sub;

assign sub_diff[22:0] = subtraction_diff[22:0];


// Output //
assign res = exception ? 32'b0 : ((!operation_add_sub_signal) ? {output_sign,sub_diff} : {output_sign,add_sum});

endmodule
