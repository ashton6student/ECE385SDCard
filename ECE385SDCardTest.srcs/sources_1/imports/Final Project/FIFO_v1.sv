module SD_Card_FIFO (
    input logic clk_SD,
    input logic clk_sample,
    input logic reset,
    input logic read_enable,
    input logic [15:0] SD_data,
    output logic [15:0] data_out,
    output logic empty,
    output logic full
);

parameter DEPTH = 64; // Depth of the FIFO

logic [15:0] fifo [DEPTH];
logic [6:0] read_ptr = 0;
logic [6:0] write_ptr = 0;

// Flags
logic fifo_empty;
logic fifo_full;

always @(posedge clk_sample) begin
    if (reset) begin
        read_ptr <= 0;
        write_ptr <= 0;
        fifo_empty <= 1;
        fifo_full <= 0;
    end else begin
        if (read_enable && !fifo_empty) begin
            data_out <= fifo[read_ptr];
            if (read_ptr == DEPTH-1)begin
                read_ptr <= 0;
            end else begin
                read_ptr <= read_ptr + 1;
                fifo_empty <= (read_ptr == write_ptr);
                fifo_full <= 0;
            end
        end
    end
end

always @(posedge clk_SD) begin
    if (reset) begin
        fifo[write_ptr] <= 0;
    end else begin
        if (!fifo_full) begin
            fifo[write_ptr] <= SD_data; // Connect data from SD Card to FIFO here
            if (write_ptr == DEPTH-1)begin
                write_ptr <= 0;
            end else begin
                write_ptr <= write_ptr + 1;
            end 
            fifo_empty <= 0;
            fifo_full <= (write_ptr == read_ptr);
        end
    end
end

assign empty = fifo_empty;
assign full = fifo_full;

endmodule
