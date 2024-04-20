`default_nettype none
`timescale 1ns/1ns

module pc #(
    parameter DATA_MEM_DATA_BITS,
    parameter PROGRAM_MEM_ADDR_BITS
) (
    input wire clk,
    input wire reset,

    input reg [2:0] core_state,

    input reg [2:0] decoded_nzp,
    input reg [DATA_MEM_DATA_BITS-1:0] decoded_immediate,
    input reg decoded_nzp_write_enable,
    input reg decoded_pc_mux, 
    input reg [DATA_MEM_DATA_BITS-1:0] alu_out,

    input reg [PROGRAM_MEM_ADDR_BITS-1:0] current_pc,
    output reg [PROGRAM_MEM_ADDR_BITS-1:0] next_pc
);
    reg [2:0] nzp;

    always @(posedge clk) begin
        if (reset) begin
            nzp <= 3'b0;
            next_pc <= 0;
        end else begin
            // Update PC when core_state = EXECUTE
            if (core_state == 3'b101) begin 
                if (decoded_pc_mux == 1) begin 
                    if (((nzp & decoded_nzp) != 3'b0)) begin 
                        next_pc <= decoded_immediate;
                    end
                end else begin 
                    next_pc <= current_pc + 1;
                end
            end   

            // Store NZP when core_state = UPDATE   
            if (core_state == 3'b110) begin 
                if (decoded_nzp_write_enable) begin
                    nzp <= alu_out[2:0];
                end
            end      
        end
    end

endmodule
