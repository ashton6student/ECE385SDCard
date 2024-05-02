`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2024 03:14:46 PM
// Design Name: 
// Module Name: testbench
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


module testbench(

    );
audio_read_playback_top audio_read_playback_top(.*);

logic clk;
logic reset;
logic spkl;
logic spkr;
logic SD_D0;
logic SD_CLK;
logic SD_DI;
logic SD_CS;

logic [7:0] D0_SEG;
logic [3:0] D0_AN;
logic [7:0] D1_SEG;
logic [3:0] D1_AN;

initial begin
    clk = 1'b0;
    forever clk = #1ns ~clk;
end

initial begin
    reset <= 1'b1;
    repeat (5) @(posedge clk);
    reset <= 1'b0;
    repeat (100) @(posedge clk);
    $finish;
end

endmodule
