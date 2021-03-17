`include "common.svh"
`include "Myheadfile.svh"
module Wreg(
    input i32 W_pc, W_val3,
    input i6 W_icode, W_acode,
    input i5 W_dst,
    input i1 clk,

    output i32 w_pc,
    output i32 w_val3,
    output i32 w_dst,
    output i1 w_write_enable
);
    
    i6 w_acode, w_icode;

    always_ff @(posedge clk) begin
        w_pc <= W_pc; 
        w_acode <= W_acode;
        w_icode <= W_icode;
        w_val3 <= W_val3;
        w_dst <= W_dst;
    end

    always_comb begin 
        unique case (w_icode)
            BEQ: w_write_enable = 0;
            BNE: w_write_enable = 0;
            J:   w_write_enable = 0;
            JAL: w_write_enable = 0;
            SW:  w_write_enable = 0;
            SPE: begin
                unique case (w_acode)
                    JR: w_write_enable = 0;
                endcase
            end
            default: w_write_enable = 1;  
        endcase
    end
    
endmodule