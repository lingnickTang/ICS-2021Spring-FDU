`include "common.svh"
`include "Myheadfile.svh"
module Wreg(
    input i32 W_val3,
    input i5 W_dst,
    input i4 W_write_enable,
    input i1 clk,resetn,

    output i32 w_val3,
    output i5 w_dst,
    output i4 w_write_enable
);

    always_ff @(posedge clk) begin
        if(~resetn)begin
            //w_pc <= 0; 
            //w_acode <= 0;
            //w_icode <= 0;
            w_val3 <= 0;
            w_dst <= 0;
            w_write_enable <= 0;
        end else begin
            //w_pc <= W_pc; 
            //w_acode <= W_acode;
            //w_icode <= W_icode;
            w_val3 <= W_val3;
            w_dst <= W_dst;
            w_write_enable <= W_write_enable;
        end
    end
    
endmodule