`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2024 11:11:32 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx (
    input  logic        clk,       // System clock
    input  logic        rst,       // Active-high reset
    input  logic        rx,        // UART RX line
    output logic [39:0] data,      // Received 32-bit data
    output logic        valid      // Data ready signal
);

    //localparam IDLE  = 2'b00,
       //        START = 2'b01,
         //      DATA  = 2'b10,
           //    STOP  = 2'b11;
    typedef enum{IDLE,START,DATA,STOP}states;
    states state, next_state;
    logic [5:0] bit_count;         // Counts bits (start, data, stop)
    logic [13:0] baud_counter;      // Counts clock cycles for baud rate
    logic [39:0] shift_register;   // Temporary storage for received bits
    //logic [2:0]trigger_to;
    // Baud rate parameters (assuming 100 MHz clock and 9600 baud rate)
    logic [13:0] BAUD_DIV ;   // 100 MHz / 9600
/*
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) state<=IDLE;
        else state<=next_state;
    end
    
    always @(posedge clk or negedge rst) begin
        case(state)
        IDLE: begin
        $display("IDLE, time=",$time);
            bit_count <= 0;
            baud_counter <= 0;
            valid <= 0;
            BAUD_DIV <= 'd10416;
            if (!rx) next_state <= START;
            else next_state <=IDLE;
        end
        START: begin
            $display("START, B=%d, time=,",baud_counter,$time);
            baud_counter <= (baud_counter+1);
            if(baud_counter==BAUD_DIV) begin 
                next_state <= DATA;
                end
            else next_state <=START;
        end
        DATA: begin
            $display("DATA, time=",$time);
            baud_counter = (baud_counter == BAUD_DIV) ? 0 :(baud_counter + 1);
            if(baud_counter== BAUD_DIV>>1) begin
                shift_register <= {rx, shift_register[31:1]};
                bit_count <= bit_count + 1;
            end
            if(bit_count=='d31 && baud_counter==BAUD_DIV) next_state<=STOP;
            else next_state<=DATA;
        end
        STOP: begin
             $display("STOP, time=",$time);
            baud_counter <= (baud_counter == BAUD_DIV) ? 0 : baud_counter + 1;
            if(baud_counter==BAUD_DIV) begin 
                valid <= 1;
                data <= shift_register;
                next_state <= IDLE;
                end
            else next_state<=STOP;
        end
        endcase
    end
    
*/    
    /*
        always @(posedge clk or negedge rst) begin
        case(state)
        IDLE: begin
        $display("IDLE, time=",$time);
            bit_count <= 0;
            baud_counter <= 0;
            valid <= 0;
            BAUD_DIV= 'd104;
            if (!rx) next_state = START;
            else next_state=IDLE;
        end
        START: begin
            $display("START, B=%d, time=,",baud_counter,$time);
            baud_counter = (baud_counter+1);
            if(baud_counter==BAUD_DIV) begin 
                next_state = DATA;
                end
            else next_state=START;
        end
        DATA: begin
            $display("DATA, time=",$time);
            baud_counter = (baud_counter == BAUD_DIV) ? 0 :(baud_counter + 1);
            if(baud_counter== BAUD_DIV>>1) begin
                shift_register = {rx, shift_register[31:1]};
                bit_count = bit_count + 1;
            end
            if(bit_count=='d31 && baud_counter==BAUD_DIV) next_state=STOP;
            else next_state=DATA;
        end
        STOP: begin
            baud_counter = (baud_counter == BAUD_DIV) ? 0 : baud_counter + 1;
            if(baud_counter==BAUD_DIV) begin 
                valid = 1;
                data = shift_register;
                next_state = IDLE;
                end
            else next_state=STOP;
        end
        endcase
    end
    */

    // State transition
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            bit_count <= 0;
            baud_counter <= 0;
            shift_register <= 0;
            BAUD_DIV <= 'd5208;
            valid <= 0;   
        end else begin
            state <= next_state;

            if (state == DATA && baud_counter == (BAUD_DIV / 'd2)) begin
                // Shift in data bit on the middle of the baud cycle
                shift_register <= {rx, shift_register[39:1]};
                bit_count <= bit_count + 1;
            end

            if (state == STOP && baud_counter == BAUD_DIV) begin
                // Data is ready at the end of the stop bit
                valid <= 1;
                bit_count<=0;
                data <= shift_register;
            end else begin
                valid <= 0;
            end

            if (state != IDLE) begin
                // Increment baud counter during START, DATA, and STOP states
                baud_counter <= (baud_counter == BAUD_DIV) ? 0 : baud_counter + 1;
            end else begin
                baud_counter <= 0;
            end
        end
        //$display("STATE=%d, B=%d time=", state,baud_counter,$time);
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (!rx) next_state = START;   // Detect start bit (low)
            START: if (baud_counter == BAUD_DIV) next_state = DATA;
            DATA: if (bit_count == 'd40 && baud_counter == BAUD_DIV) next_state = STOP;
            STOP: if (baud_counter == BAUD_DIV) next_state = IDLE;
        endcase
    end
  endmodule