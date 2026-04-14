`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2024 11:19:17 PM
// Design Name: 
// Module Name: uart_top
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

/*
module uart_top(
    input logic clk,            // System clock
    input logic rst_n,          // Reset (active low)
    input logic rx,             // UART RX input
    output logic tx,            // UART TX output
    input logic btn_tanh,       // Button for Tanh
    input logic btn_sigmoid,    // Button for Sigmoid
    input logic btn_elu,        // Button for ELU
    input logic btn_relu,       // Button for ReLU
    input logic btn_leakyrelu,  // Button for Leaky ReLU
    output logic done           // Done signal (optional for debugging)
);

    // UART signals
    wire [31:0] received_data;  // Data received via UART
    wire [31:0] processed_data; // Data processed by top module
    wire start;                 // Start signal for UART TX
    reg send;                   // Internal send signal
    reg [31:0] tx_data;         // Data to transmit

    // Top module signals
    wire valid;
    reg start_tanh, start_sigmoid, start_elu, start_relu, start_leakyrelu;
    reg [31:0] x;

    // Instantiate UART Receiver
    uart_rx uart_rx_inst (
        .clk(clk),
        .rst(rst_n),           // Active-high reset
        .rx(rx),                // UART RX line
        .data(received_data),   // Received data (32-bit)
        .valid(start)           // Start processing when data is received
    );

    // Instantiate UART Transmitter
    uart_tx uart_tx_inst (
        .clk(clk),
        .rst(rst_n),           // Active-high reset
        .data(tx_data),         // Data to transmit (32-bit)
        .send(send),            // Send signal
        .tx(tx),                // UART TX line
        .done(done)             // Transmission complete
    );

    // Instantiate Top Module
    top activation_top (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .start_tanh(start_tanh),
        .start_sigmoid(start_sigmoid),
        .start_elu(start_elu),
        .start_relu(start_relu),
        .start_leakyrelu(start_leakyrelu),
        .done(valid),
        .y(processed_data)
    );

    // Control Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all control signals
            send <= 0;
            x <= 0;
            start_tanh <= 0;
            start_sigmoid <= 0;
            start_elu <= 0;
            start_relu <= 0;
            start_leakyrelu <= 0;
            tx_data <= 0;
        end else begin
            // UART RX: Load input data when received
            if (start) begin
                x <= received_data;
            end

            // Trigger appropriate activation function based on button input
            start_tanh <= btn_tanh;
            start_sigmoid <= btn_sigmoid;
            start_elu <= btn_elu;
            start_relu <= btn_relu;
            start_leakyrelu <= btn_leakyrelu;

            // When processing is complete, prepare UART TX
            if (valid) begin
                tx_data <= processed_data; // Output data from top module
                send <= 1;                 // Trigger UART transmission
            end else if (send) begin
                send <= 0;                 // Clear send signal after transmission
            end
        end
    end
endmodule
*/
module uart_top(
    input logic clk,            // System clock
    input logic rst_n,          // Reset (active low)
    input logic rx,             // UART RX input
    output logic tx,            // UART TX output
   // input logic btn_tanh,       // Button for Tanh
    //input logic btn_sigmoid,    // Button for Sigmoid
    //input logic btn_elu,        // Button for ELU
    //input logic btn_relu,       // Button for ReLU
    //input logic btn_leakyrelu,  // Button for Leaky ReLU
    //output logic [31:0]out,
    output logic done           // Done signal (optional for debugging)
);

    // UART signals
    wire [39:0] received_data;  // Data received via UART
    wire [31:0] processed_data; // Data processed by top module
    wire start;                 // Start signal for UART TX
    reg send;                   // Internal send signal
    reg [31:0] tx_data;         // Data to transmit
    reg [31:0] out_data;
    // Top module signals
    wire valid;
    logic start_tanh, start_sigmoid, start_elu, start_relu, start_leakyrelu;
    reg [31:0] x;
    logic [7:0]trigger_to;
    
    assign trigger_to = received_data[7:0];
    // Instantiate UART Receiver
    uart_rx uart_rx_inst (
        .clk(clk),
        .rst(rst_n),           // Active-high reset
        .rx(rx),                // UART RX line
        .data(received_data),   // Received data (32-bit)
        .valid(start)           // Start processing when data is received
    );

    // Instantiate UART Transmitter
    uart_tx uart_tx_inst (
        .clk(clk),
        .rst(rst_n),           // Active-high reset
        .data(tx_data),         // Data to transmit (32-bit)
        .send(send),            // Send signal
        .tx(tx),
        .y(out_data),              // UART TX line
        .done(done)             // Transmission complete
    );

    // Instantiate Activation Top Module
    top activation_top (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .start_tanh(start_tanh),
        .start_sigmoid(start_sigmoid),
        .start_elu(start_elu),
        .start_relu(start_relu),
        .start_leakyrelu(start_leakyrelu),
        .done(valid),
        .y(processed_data)
    );
/*
    // Instantiate btn_to_start modules for each button
    btn_to_start btn_tanh_inst (
        .clk(clk),
        .reset(rst_n),         // Active-high reset
        .btn(btn_tanh),
        .done(valid),           // 'done' signal from activation_top
        .start(start_tanh)      // Start signal for Tanh
    );

    btn_to_start btn_sigmoid_inst (
        .clk(clk),
        .reset(rst_n),
        .btn(btn_sigmoid),
        .done(valid),
        .start(start_sigmoid)
    );

    btn_to_start btn_elu_inst (
        .clk(clk),
        .reset(rst_n),
        .btn(btn_elu),
        .done(valid),
        .start(start_elu)
    );

    btn_to_start btn_relu_inst (
        .clk(clk),
        .reset(rst_n),
        .btn(btn_relu),
        .done(valid),
        .start(start_relu)
    );

    btn_to_start btn_leakyrelu_inst (
        .clk(clk),
        .reset(rst_n),
        .btn(btn_leakyrelu),
        .done(valid),
        .start(start_leakyrelu)
    );
*/
    // Control Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all control signals
            send <= 0;
            x <= 0;
            tx_data <= 0;
        end else begin
            // UART RX: Load input data when received
            if (start) begin
                x <= received_data[39:8];
                case(trigger_to)
                    'd0: {start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu}<=5'b10000;
                    'd1: {start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu}<=5'b01000;
                    'd2: {start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu}<=5'b00100;
                    'd3: {start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu}<=5'b00010;
                    'd4: {start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu}<=5'b00001; 
                    default:{start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu}<=5'b00000;
                endcase
            end

            // When processing is complete, prepare UART TX
            if (valid) begin
                {start_tanh,start_sigmoid,start_elu,start_relu,start_leakyrelu}<=5'b00000;
                tx_data <= processed_data; // Output data from top module
                send <= 1;                 // Trigger UART transmission
            end else if (send) begin
                send <= 0;                 // Clear send signal after transmission
            end
        end
    end
endmodule