`include "common.svh"
`include "Myheadfile.svh"
module Ereg(
    input i32 E_pc, E_val1, E_val2, E_valt,
    input i6 E_icode, E_acode,
    input i5 E_dst, E_rt,//for icode about REGIMM 
    input i1 E_bubble, E_stall, clk, resetn,

    output i32 e_pc,e_val3,
    output i6 e_icode, e_acode,
    output i5 e_dst, e_rt,

    output i32 e_valt
);
//don't forget the bubble!
    
    i32 e_val1, e_val2;

    always_ff @(posedge clk) begin
        if(~resetn) begin
            e_pc <= 0;
            e_acode <= 0;
            e_icode <= 0;
            e_dst <= 0;
            e_val1 <= 0;
            e_val2 <= 0;
            e_valt <= 0;
            e_rt <= 0;
        end else if(E_stall) begin

        end else if(E_bubble) begin
            e_pc <= 0;
            e_acode <= 0;
            e_icode <= 0;
            e_dst <= 0;
            e_val1 <= 0;
            e_val2 <= 0;
            e_valt <= 0;
            e_rt <= 0;
        end else begin
            e_pc <= E_pc;
            e_icode <= E_icode;
            e_acode <= E_acode;
            e_dst <= E_dst;
            e_val1 <= E_val1;
            e_val2 <= E_val2;
            e_valt <= E_valt;
            e_rt <= E_rt;
        end
    end
    
//ALU
    always_comb begin
        unique case (e_icode)
            ADDIU: e_val3 = e_val1 + e_val2;
            ANDI:  e_val3 = e_val1 & e_val2;
            JAL:   e_val3 = e_val2;          //f_pc
            LUI:   e_val3 = e_val2;          //immeZF
            LW:    e_val3 = e_val1 + e_val2;
            ORI:   e_val3 = e_val1 | e_val2;
            SLTI:  e_val3 = ($signed(e_val1) < $signed(e_val2)) ? 32'h0000_0001 : 32'h0000_0000;
            SLTIU: e_val3 = (e_val1 < e_val2) ? 32'h0000_0001 : 32'h0000_0000;
            SW:    e_val3 = e_val1 + e_val2;
            XORI:  e_val3 = e_val1 ^ e_val2;
            SPE:begin
                unique case (e_acode)
                    XOR_:  e_val3 = e_val1 ^ e_val2;
                    SUBU:  e_val3 = e_val1 - e_val2;            
                    SRL:   e_val3 = e_val2 >> e_val1[4:0];
                    SRA:   e_val3 = $signed(e_val2) >>> e_val1[4:0];
                    SLTU:  e_val3 = (e_val1 < e_val2) ? 32'h0000_0001 : 32'h0000_0000;
                    SLT:   e_val3 = ($signed(e_val1) < $signed(e_val2)) ? 32'h0000_0001 : 32'h0000_0000;
                    SLL:   e_val3 = e_val2 << e_val1[4:0];   // the bubble selection, making sure it becomes 0.
                    OR_:   e_val3 = e_val1 | e_val2;
                    NOR_:  e_val3 = ~(e_val1 | e_val2);
                    AND_:  e_val3 = e_val1 & e_val2;
                    ADDU:  e_val3 = e_val1 + e_val2;

                    JALR:  e_val3 = e_val2;
                    SLLV:  e_val3 = e_val2 << e_val1[4:0];
                    SRAV:  e_val3 = $signed(e_val2) >>> e_val1[4:0];
                    SRLV:  e_val3 = e_val2 >> e_val1[4:0];
                    default: e_val3 = 0;
                endcase
            end
            REGIMM: begin
                unique case (e_rt)
                    BGEZAL: e_val3 = e_val2;
                    BLTZAL: e_val3 = e_val2;
                    default: e_val3 = 0;
                endcase
            end
            
            LB:   e_val3 = e_val1 + e_val2;
            LBU:  e_val3 = e_val1 + e_val2;
            LH:   e_val3 = e_val1 + e_val2;
            LHU:  e_val3 = e_val1 + e_val2;
            SB:   e_val3 = e_val1 + e_val2;
            SH:   e_val3 = e_val1 + e_val2; 
            default: e_val3 = 0;
        endcase        
    end

endmodule
