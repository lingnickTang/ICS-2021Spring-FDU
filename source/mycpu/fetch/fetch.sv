`include "common.svh"
module Freg(
    input i32 F_pc,
    input i1 F_stall,clk,
    
    output i32 f_pc, pred_pc
);
//pay attention to the stall
    always_ff @(posedge clk) begin
        if(~F_stall)begin
            f_pc <= F_pc;
            pred_pc <= F_pc+4;
        end
    end
endmodule