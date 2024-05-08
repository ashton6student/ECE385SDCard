`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2024 11:08:31 PM
// Design Name: 
// Module Name: audio_read_playback_top
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


module audio_read_playback_top(
    input logic clk,
    input logic reset_raw,
    input logic run_i,
    input logic continue_i,
    
    output logic SPKL,
    output logic SPKR,
    
    input  logic SD_D0,
    output logic SD_CLK,
    output logic SD_DI,
    output logic SD_CS,
    
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
    );
    
logic clk_50MHz, clk_25MHz;
logic ram_we;
logic [24:0] ram_address;
logic [15:0] ram_data;
logic ram_op_begun;
logic ram_init_error;
logic ram_init_done;
logic reset, run_s, continue_s;
logic [7:0] audio_left, audio_right;
logic song_data_left, song_data_right;
logic [15:0] audio_full;

assign SPKL = song_data_left;
assign SPKR = song_data_right;

logic [31:0] counter;
logic clk2, old_clk2, take_sample;
parameter FREQUENCY = 44500;
parameter CLK = 100000000;
parameter MAX = (CLK / FREQUENCY) / 2;

assign audio_left = audio_full[15:8];
assign audio_right = audio_full[7:0];
//assign audio_left = ram_data[15:8];
//assign audio_right = ram_data[7:0];

always_ff @(posedge clk) begin
    if(reset) begin
        counter <= 0;
        clk2 <= 1'b0;
    end else begin
        if(counter > MAX) begin
            clk2 <= ~clk2;
            counter <= 0;
        end else begin
            clk2 <= clk2;
            counter <= counter + 1;
        end
    end
end

always_ff @(posedge clk) begin
    old_clk2 <= clk2;
    if(clk2 && !old_clk2 && !reset) begin
        take_sample <= 1'b1;    
    end else begin
        take_sample <= 1'b0;
    end
end   
assign ram_op_begun = take_sample;

sync_debounce button_sync [2:0](
    .clk(clk),
    .d({run_i, continue_i, reset_raw}),
    .q({run_s, continue_s, reset})
);

SD_Card_FIFO FIFO(
    .clk_SD(clk_50MHz),
    .clk_sample(clk2),
    .reset(reset),
    .read_enable(ram_op_begun),
    .SD_data(ram_data),
    .data_out(audio_full),
    .empty(),
    .full()
);

clk_wiz_0 clk_wiz(
    .clk_out1(clk_50MHz),
    .clk_out2(clk_25MHz),
    .reset(reset),
    .clk_in1(clk)
);

sdcard_init SD_card(
    .clk50(clk_50MHz),
	.reset(reset),          
	.ram_we(ram_we),         
	.ram_address(ram_address),
	.ram_data(ram_data),
	.ram_op_begun(ram_op_begun),   
	.ram_init_error(ram_init_error), 
	.ram_init_done(ram_init_done), 
	.cs_bo(SD_CS),          
	.sclk_o(SD_CLK),
	.mosi_o(SD_DI),
	.miso_i(SD_D0)  
);

    HexDriver HexA (
        .clk(clk),
        .reset(reset),
        .in({ram_address[15:12], ram_address[11:8], ram_address[7:4], ram_address[3:0]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    HexDriver HexB (
        .clk(clk),
        .reset(reset),
        .in({ram_data[15:12], ram_data[11:8], ram_data[7:4], ram_data[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
//   ila_0 ILA (
//	.clk(clk), // input wire clk


//	.probe0(reset), // input wire [0:0]  probe0  
//	.probe1(SD_D0), // input wire [0:0]  probe1 
//	.probe2(SD_CLK), // input wire [0:0]  probe2 
//	.probe3(SD_DI), // input wire [0:0]  probe3 
//	.probe4(SD_CS) // input wire [0:0]  probe4
//);

pwm pwm_left(
    .clk(clk),
    .reset(reset),
    .audioData(audio_left), 
    .pwmOut(song_data_left)
);

pwm pwm_right(
    .clk(clk),
    .reset(reset), 
    .audioData(audio_right),
    .pwmOut(song_data_right)
);
    
    
    
    
    
    
endmodule
