`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2026 08:25:02 PM
// Design Name: 
// Module Name: spi
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


module spi(
input clk, start,                                          ///onboard clock and start
input [11:0] din,                                          ///input 12-bit data
output reg cs, mosi, done,                                 ///chip select pin+ master out salve in pin+ done flag to update accordingly
output sclk                                                ///slower clock
);
 
integer count = 0;
reg sclkt = 0;
always@(posedge clk)
begin
    if(count < 10)                                        ///count < (onboard clock / targeted frequency)*2
    count <= count + 1;
    else
    begin
    count  <= 0;
    sclkt  <= ~sclkt;                                     ///generate slower clock accordingly
    end
end
 
/////////////////////////////////////
parameter idle = 0, start_tx = 1, send = 2, end_tx = 3;   ///4 state parameters
reg [1:0] state = idle;
reg [11:0] temp;
integer bitcount = 0;                                    ///reg to update based on number of bits of data transmitted
 
always@(posedge sclkt)
begin
            case(state)
            idle: begin
               mosi <= 1'b0;
               cs   <= 1'b1;
               done <= 1'b0;
               
               if(start)
                 state <= start_tx;
               else
                 state <= idle;
            end
            
            
            start_tx : begin
              cs    <= 1'b0;
              temp  <= din;                              ///temporary reg used because to store the previous input data if the data is changed over next clock tick and to complete transmit the previous one before the new one to make no error 
              state <= send; 
            end
            
            send : 
            begin
               if(bitcount <= 11) 
               begin
                 bitcount <= bitcount + 1;
                 mosi     <= temp[bitcount];             ///keep transmitting the LSB bit of temp reg unless all the bits are transferred
                 state    <= send;
               end
               else
                begin
                bitcount <= 0;
                state    <= end_tx;
                mosi     <= 1'b0; 
                end
            end
            
            end_tx : begin
               cs    <= 1'b1;
               state <= idle;
               done  <= 1'b1;
            end
            
            default : state <= idle;
            endcase
end
 
 
assign sclk = sclkt;
 
endmodule