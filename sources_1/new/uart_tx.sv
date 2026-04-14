`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 05:30:34 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx (
    input  logic        clk,       // System clock
    input  logic        rst,       // Active-high reset
    input  logic [31:0] data,      // Data to be transmitted
    input  logic        send,      // Start transmission signal
    output logic        tx,        // UART TX line
    output logic [31:0] y,
    output logic        done       // Transmission complete signal
);

    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    logic [1:0] state, next_state;
    logic [4:0] bit_count;         // Counts bits (start, data, stop)
    logic [13:0] baud_counter;      // Counts clock cycles for baud rate
    logic [31:0] shift_register;   // Temporary storage for transmitted bits
    logic tx_reg;                  // Internal register for TX line

    // Baud rate parameters (assuming 100 MHz clock and 9600 baud rate)
    logic [13:0] BAUD_DIV;   // 100 MHz / 9600

    assign tx = tx_reg; // Drive TX line
    
    assign tx_reg = (state == IDLE || state == STOP) ? 1 : 
                    (state == START) ? 0 : 
                    shift_register[0];
    // State transition
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            baud_counter <= 0;
            BAUD_DIV <= 'd5208;
            bit_count <= 0;
        end else begin
            state <= next_state;

            if (state != IDLE) begin
                baud_counter <= (baud_counter == BAUD_DIV) ? 0 : baud_counter + 1;
            end else begin
                baud_counter <= 0;
            end

            if (state == DATA && baud_counter == BAUD_DIV) begin
                bit_count <= bit_count + 1;
            end else if (state == IDLE) begin
                bit_count <= 0;
            end
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (send) next_state = START;
            START: if (baud_counter == BAUD_DIV) next_state = DATA;
            DATA: if (bit_count == 31 && baud_counter == BAUD_DIV) next_state = STOP;
            STOP: if (baud_counter == BAUD_DIV) next_state = IDLE;
        endcase
    end

    // Shift register and TX line logic
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            shift_register <= 0;
            //tx_reg <= 1;
        end else begin
            if (state == IDLE && send) begin
                shift_register <= data; // Load new data
            end else if (state == DATA && baud_counter == BAUD_DIV) begin
                //tx_reg <= shift_register[0];
                shift_register <= {tx_reg, shift_register[31:1]}; // Shift data
                 // Transmit LSB
            end else if (state == START && baud_counter == BAUD_DIV) begin
                //tx_reg <= 0; // Start bit
            end else if (state == STOP && baud_counter == BAUD_DIV) begin
                //tx_reg <= 1; // Stop bit
            end
        end
    end

    // Output signals
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            done <= 0;
        end else if (state == STOP && baud_counter == BAUD_DIV) begin
            y <= shift_register; // Capture data
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule
