`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 05:33:54 PM
// Design Name: 
// Module Name: uart_top_tb
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


module tb_uart_top;

    // Parameters
    localparam CLK_PERIOD = 20; // 100 MHz clock, 10 ns period
    localparam BAUD_PERIOD = 104160; // 9600 baud bit time

    // Testbench Signals
    logic clk;
    logic rst_n;
    logic rx;
    logic tx;
    logic btn_tanh, btn_sigmoid, btn_elu, btn_relu, btn_leakyrelu;
    logic done;
    //logic [31:0]out;

    // Instantiate the UART Top module
    uart_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .tx(tx),
        //.btn_tanh(btn_tanh),
        //.btn_sigmoid(btn_sigmoid),
        //.btn_elu(btn_elu),
        //.btn_relu(btn_relu),
        //.btn_leakyrelu(btn_leakyrelu),
        //.out(out),
        .done(done)
    );

    // Clock Generation
  always #10 clk=!clk;

    // UART RX Task (to simulate UART data reception)
    task uart_send(input logic [39:0] data);
        integer i;
        begin
            // Send Start Bit (Low)
            rx <= 0;
            #(BAUD_PERIOD);

            // Send 32-bit Data (LSB first)
            for (i = 0; i < 40; i++) begin
                rx <= data[i];
                #(BAUD_PERIOD);
            end

            // Send Stop Bit (High)
            rx <= 1;
            #(BAUD_PERIOD);
        end
    endtask

    // UART TX Task (to capture UART transmitted data)
    task uart_receive(output logic [31:0] data);
        integer i;
        begin
            data = 0;

            // Wait for Start Bit (Low)
            wait(tx == 0);
            #(BAUD_PERIOD / 2); // Move to the middle of the start bit

            // Sample 32 Data Bits
            for (i = 0; i < 32; i++) begin
                #(BAUD_PERIOD); // Wait for next bit
                data[i] = tx;   // Sample data bit
            end

            // Wait for Stop Bit (High)
            #(BAUD_PERIOD);
        end
    endtask

    // Testbench Variables
    logic [39:0] input_data;
    logic [31:0] captured_tx_data;

    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;
        rx = 1; // Idle state for UART RX
        btn_tanh = 0;
        btn_sigmoid = 0;
        btn_elu = 0;
        btn_relu = 0;
        btn_leakyrelu = 0;

        // Wait for Reset
        #(CLK_PERIOD * 5);
        rst_n = 1;

        // Test Case 1: Send Data and Trigger Tanh
        input_data = {32'b10111111100000000000000000000000,8'b010}; // Example input data
        uart_send(input_data); // Send data via UART RX

        // Simulate button press for Tanh
        //#(CLK_PERIOD * 50); // Wait for data to be received
//btn_elu = 1;
        //#(CLK_PERIOD * 10); // Hold button press for a few cycles
        //btn_elu = 0;

        // Wait for processing to complete
        //wait(done);

        // Capture the TX output
        uart_receive(captured_tx_data);
        $display("Test Case 1: Input = 0x%h, Output = 0x%h", input_data, captured_tx_data);
        
        wait(done);
        //#(CLK_PERIOD * 10)
        
        // Test Case 2: Trigger Sigmoid
        input_data = {32'b00111111100000000000000000000000,8'b001}; // Another example input
        uart_send(input_data);

        //#(CLK_PERIOD * 50); // Wait for data to be received
        //btn_sigmoid = 1;
       // #(CLK_PERIOD * 10); // Hold button press for a few cycles
        //btn_sigmoid = 0;

        //wait(done);
        uart_receive(captured_tx_data);
        $display("Test Case 2: Input = 0x%h, Output = 0x%h", input_data, captured_tx_data);
        
        wait(done);
        //#(CLK_PERIOD * 10)
        
        // Test Case 2: Trigger Sigmoid
        input_data = {32'b10111111100000000000000000000000,8'b000}; // Another example input
        uart_send(input_data);

        //#(CLK_PERIOD * 50); // Wait for data to be received
        //btn_tanh = 1;
        //#(CLK_PERIOD * 10); // Hold button press for a few cycles
        //btn_tanh = 0;

        //wait(done);
        uart_receive(captured_tx_data);
        $display("Test Case 3: Input = 0x%h, Output = 0x%h", input_data, captured_tx_data);
 
        wait(done);
        #(CLK_PERIOD * 10)
        
        // Test Case 4: Trigger Sigmoid
        input_data = {32'b10111111100000000000000000000000,8'b011}; // Another example input
        uart_send(input_data);

        //#(CLK_PERIOD * 50); // Wait for data to be received
       // btn_relu = 1;
        //#(CLK_PERIOD * 10); // Hold button press for a few cycles
       // btn_relu = 0;

        //wait(done);
        uart_receive(captured_tx_data);
        $display("Test Case 4: Input = 0x%h, Output = 0x%h", input_data, captured_tx_data);
 
        wait(done);
        #(CLK_PERIOD * 10)
        
        // Test Case 5: Trigger Sigmoid
        input_data = {32'b10111111100000000000000000000000,8'b100}; // Another example input
        uart_send(input_data);

        //#(CLK_PERIOD * 50); // Wait for data to be received
        //btn_leakyrelu = 1;
        //#(CLK_PERIOD * 10); // Hold button press for a few cycles
        //btn_leakyrelu = 0;

        //wait(done);
        uart_receive(captured_tx_data);
        $display("Test Case 5: Input = 0x%h, Output = 0x%h", input_data, captured_tx_data);                        
        
        // End Simulation
        #(CLK_PERIOD * 10000);
        $stop;
    end
endmodule