`include "common.svh"
`include "Myheadfile.svh"
module Freg(
    input i32 F_pc,
    input i1 F_stall, clk, resetn,

    output i32 f_pc, pred_pc,
    output i1 f_vreq
);

    always_ff @(posedge clk) begin
        if(~resetn)begin
            //f_pc <= F_pc;
            pred_pc <= 32'hbfc0_0000;
            f_vreq <= 0;
        end else if(~F_stall)begin
            f_pc <= F_pc;
            pred_pc <= F_pc + 4;
            f_vreq <= 1;
        end else begin
            //stay the same value
        end
    end
endmodule