`include "common.svh"
`include "Myheadfile.svh"
module Ereg(
    input i32 E_pc, E_val1, E_val2, E_valt,
    input i6 E_icode, E_acode,
    input i5 E_dst, E_src1, E_src2, E_rd, E_sa,  
    input i1 E_bubble, clk, resetn,

    output i32 e_pc,e_val3,
    output i6 e_icode, e_acode,
    output i5 e_dst,

    output i32 e_valt,
    output i4 e_req
);
//don't forget the bubble!
    
    i32 e_val1, e_val2;

    i5 e_sa,e_rd;

    always_ff @(posedge clk) begin
        if(E_bubble | ~resetn) begin
            e_pc <= 0;
            e_acode <= 0;
            e_icode <= 0;
            e_sa <= 0;
            e_rd <= 0;
            e_dst <= 0;
            e_val1 <= 0;
            e_val2 <= 0;
            e_valt <= 0;
        end else begin
            e_pc <= E_pc;
            e_icode <= E_icode;
            e_acode <= E_acode;
            e_sa <= E_sa;
            e_rd <= E_rd;
            e_dst <= E_dst;
            e_val1 <= E_val1;
            e_val2 <= E_val2;
            e_valt <= E_valt;
        end
    end
    

//ALU
    always_comb begin
        unique case (e_icode)
            ADDIU: e_val3 = e_val1 + e_val2;
            ANDI:  e_val3 = e_val1 & e_val2;
            JAL:   e_val3 = e_val1;          //f_pc
            LUI:   e_val3 = e_val2;          //immeZF
            LW:    e_val3 = e_val1 + e_val2;
            ORI:   e_val3 = e_val1 | e_val2;
            SLTI:  e_val3 = $signed(e_val1) < $signed(e_val2);
            SLTIU: e_val3 = (e_val1 < e_val2);
            SW:    e_val3 = e_val1 + e_val2;
            XORI:  e_val3 = e_val1 ^ e_val2;
            SPE:begin
                unique case (e_acode)
                    XOR_:   e_val3 = e_val1 ^ e_val2;
                    SUBU:  e_val3 = e_val1 - e_val2;            
                    SRL:   e_val3 = e_val2 >> e_sa;
                    SRA:   e_val3 = $signed(e_val2) >>> e_sa;
                    SLTU:  e_val3 = (e_val1 < e_val2);
                    SLT:   e_val3 = $signed(e_val1) < $signed(e_val2);
                    SLL:   e_val3 = e_val2 << e_sa;   // the bubble selection, making sure it becomes 0.
                    OR_:    e_val3 = e_val1 | e_val2;
                    NOR_:   e_val3 = ~(e_val1 | e_val2);
                    AND_:   e_val3 = e_val1 & e_val2;
                    ADDU:  e_val3 = e_val1 + e_val2;
                    default: e_val3 = 0;
                endcase
            end
            default: e_val3 = 0;
        endcase        
    end

//request for Data memory
    always_comb begin
        if(e_icode === SW) e_req = 4'b1111;
        else e_req = 4'b0000;
    end
endmodule
