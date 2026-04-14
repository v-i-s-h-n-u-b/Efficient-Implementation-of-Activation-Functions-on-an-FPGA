`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2024 11:39:56 AM
// Design Name: 
// Module Name: btn_to_start
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


module btn_to_start (
    input wire clk,       // System clock
    input wire reset,     // Active-high reset
    input wire btn,       // Asynchronous external button signal
    input wire done,      // Synchronous done signal
    output reg start      // Start signal
);

    // Registers for edge detection of btn
    reg btn_sync_0, btn_sync_1;
    reg btn_prev;

    // Synchronize btn to clk domain
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end else begin
            btn_sync_0 <= btn;          // First stage of synchronization
            btn_sync_1 <= btn_sync_0;  // Second stage of synchronization
        end
    end

    // Edge detection logic for btn
    wire btn_posedge = (btn_sync_1 && ~btn_prev);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            btn_prev <= 1'b0;
        end else begin
            btn_prev <= btn_sync_1; // Update previous value
        end
    end

    // Start signal logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            start <= 1'b0; // Reset start signal
        end else if (done) begin
            start <= 1'b0; // Clear start when done is high
        end else if (btn_posedge) begin
            start <= 1'b1; // Set start on button posedge
        end
    end

endmodule
