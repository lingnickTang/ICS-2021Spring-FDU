`include "common.svh"
`include "Myheadfile.svh"
module Freg(
    input i32 F_pc,
    input i1 F_stall, clk, resetn,
    
    output i32 f_pc, pred_pc
);

    always_ff @(posedge clk) begin
        if(~resetn)begin
            //f_pc <= F_pc;
            //pred_pc <= 32'hbfc0_0000;
        end else if(~F_stall)begin
            f_pc <= F_pc;
            pred_pc <= F_pc + 4;
        end
    end
endmodule