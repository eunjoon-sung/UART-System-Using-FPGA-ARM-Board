`timescale 1ns / 1ps
// UART Rx data 랑 LED 매핑하기 ->  데이터 확인

module led_control(
    input [7:0] rx_data,
    input rst,
    input clk,
    output reg [3:0] led_cmd
    );
    reg [3:0] REG0;

    // assign led_cmd = REG0;
    always @(posedge clk) begin
    if (rst) begin
        REG0 <= 4'b0000;
    end else begin
            case (rx_data)
                8'h0x80: begin 
                    REG0 <= 4'b0000;
                end
                8'h0x81: begin 
                    REG0 <= 4'b0001;
                end
                8'h0x82: begin 
                    REG0 <= 4'b0010;
                end
                8'h0x83: begin 
                    REG0 <= 4'b0011;
                end
                8'h0x84: begin 
                    REG0 <= 4'b0100;
                end
                8'h0x85: begin 
                    REG0 <= 4'b0101;
                end
                default: REG0 <= REG0;
            endcase 
        end
    end
    
    always @(*) begin
    if (rst) begin
        led_cmd = 4'b0000;
    end else begin
           case (REG0)
               4'b0000:begin
                    led_cmd = 4'b0000;
               end
               4'b0001:begin 
                    led_cmd = 4'b0001;
               end
               4'b0010:begin
                    led_cmd = 4'b0010;
               end
               4'b0011:begin
                    led_cmd = 4'b0100;
               end
               4'b0100:begin 
                    led_cmd = 4'b1000;
               end
               4'b0101:begin
                    led_cmd = 4'b1111;
               end
               default: begin
                   led_cmd = led_cmd;
               end
           endcase
        end
    end
endmodule
