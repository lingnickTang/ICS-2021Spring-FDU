`include "common.svh"
`include "Myheadfile.svh"
module Dreg(
    input i32 D_pc,   
    input i6 D_icode, D_acode,
    input i5 D_rt, D_rs, D_rd, D_sa,
    input i1 D_stall, D_bubble, clk, resetn,

    output i32 d_pc, d_val1, d_val2, d_valt, d_jaddr,
    output i6 d_icode, d_acode,
    output i5 d_dst, d_src1, d_src2, d_rt, //to splice into imme
    output i1 d_jump,

    input i32 w_val3, m_val3, e_val3,
    input i5 w_dst, m_dst, e_dst, 
    
    input i32 pred_pc, f_pc, //JAL
    
    input i32 d_regval1, d_regval2,
    output i5 d_regidx1, d_regidx2
);
    //consider the D_stall
    i5 d_rs, d_rd, d_sa;

    always_ff @(posedge clk) begin
        if(~resetn)begin
            d_pc <= '0;
            d_icode <= '0;
            d_acode <= '0;
            d_rt <= '0;
            d_rs <= '0;
            d_rd <= '0;
            d_sa <= '0;
        end else if(D_stall)begin
            
        end else if(D_bubble)begin
            d_pc <= '0;
            d_icode <= '0;
            d_acode <= '0;
            d_rt <= '0;
            d_rs <= '0;
            d_rd <= '0;
            d_sa <= '0;
        end else begin
            d_pc <= D_pc;
            d_icode <= D_icode;
            d_acode <= D_acode;
            d_rt <= D_rt;
            d_rs <= D_rs;
            d_rd <= D_rd;
            d_sa <= D_sa;
        end
    end

//stall and bubble are not proper in combinatorial logic

//link to regfile
    always_comb begin
        d_regidx1 = d_rs;
        d_regidx2 = d_rt;
    end

//select the dst 
    always_comb begin
        unique case (d_icode)
            SPE: begin  //special
                if(d_acode === JR) d_dst = 0; //the zero reg
                else d_dst = d_rd;
            end
            ADDIU: d_dst = d_rt; 
            ANDI:  d_dst = d_rt; 
            JAL:   d_dst = 5'd31;  // GPR 31
            LUI:   d_dst = d_rt;
            LW:    d_dst = d_rt;
            ORI:   d_dst = d_rt;
            SLTI:  d_dst = d_rt;
            SLTIU: d_dst = d_rt;
            XORI:  d_dst = d_rt;
            LB:    d_dst = d_rt;
            LBU:   d_dst = d_rt;
            LH:    d_dst = d_rt;
            LHU:   d_dst = d_rt;
            REGIMM: begin
                unique case (d_rt)
                    BGEZAL: d_dst = 5'd31;
                    BLTZAL: d_dst = 5'd31;
                    default: d_dst = 0;
                endcase
            end
            default: d_dst = 0;
        endcase
    end

//select the d_src1 ans d_src2
    always_comb begin
        d_src1 = d_rs;
        d_src2 = (d_icode === REGIMM) ? 0 : d_rt;  //REGIMM use rt as acode
    end

//forwarding at first
    i32 d_newval1, d_newval2;

    always_comb begin
        if(d_src1 === 0)d_newval1 = 0;
        else if(d_src1 === e_dst)d_newval1 = e_val3;
        else if(d_src1 === m_dst)d_newval1 = m_val3;
        else if(d_src1 === w_dst)d_newval1 = w_val3;
        else d_newval1 = d_regval1;
    end

    always_comb begin
        if(d_src2 === 0)d_newval2 = 0;
        else if(d_src2 === e_dst)d_newval2 = e_val3;
        else if(d_src2 === m_dst)d_newval2 = m_val3;
        else if(d_src2 === w_dst)d_newval2 = w_val3;
        else d_newval2 = d_regval2;
    end

//produce d_val1
    always_comb begin
        unique case (d_icode)
            J:   d_val1 = 0;  //instructions that ignore d_rs
            LUI: d_val1 = 0;
            SPE: begin
                unique case (d_acode)
                    SRA: d_val1 = d_sa; 
                    SRL: d_val1 = d_sa; 
                    SLLV: d_val1 = d_rs;
                    SRAV: d_val1 = d_rs;
                    default: d_val1 = d_newval1;
                endcase
            end
            default: d_val1 = d_newval1;
        endcase
    end

//produce d_val2
    i16 imme;
    assign imme ={d_rd, d_sa, d_acode};

    i32 immeZE, immeSE, immeZF;
    assign immeZE = {{16{1'b0}},imme};
    assign immeSE = {{16{d_rd[4]}},imme};
    assign immeZF = {imme, 16'h0000};

    i32 instr_idxE;  
    assign instr_idxE = {d_pc[31:28],d_rs, d_rt, d_rd, d_sa, d_acode, 2'b00};
    //though not the branch itself, but they are same in most cases.
    //may occur problems;


    always_comb begin
        unique case (d_icode)
            ADDIU: d_val2 = immeSE;
            ANDI:  d_val2 = immeZE;
            LUI:   d_val2 = immeZF;
            LW:    d_val2 = immeSE;  //offset
            ORI:   d_val2 = immeZE;
            SLTI:  d_val2 = immeSE;
            SLTIU: d_val2 = immeSE;
            SW:    d_val2 = immeSE;  //offset
            XORI:  d_val2 = immeZE;
            JAL:   d_val2 = pred_pc;

            SPE:begin
                unique case (d_acode)
                    JALR: d_val2 = pred_pc; 
                    default: d_val2 = d_newval2;
                endcase
            end
            LB:   d_val2 = immeSE;
            LBU:  d_val2 = immeSE;
            LH:   d_val2 = immeSE;
            LHU:  d_val2 = immeSE;
            SB:   d_val2 = immeSE;
            SH:   d_val2 = immeSE;
            REGIMM:begin
                unique case (d_rt)
                    BGEZAL: d_val2 = pred_pc;
                    BLTZAL: d_val2 = pred_pc;
                    default: d_val2 = 0;
                endcase
            end
            default: d_val2 = 0;
        endcase
    end

//jump address 
//
    i32 immeaddr = {immeSE[29:0],2'b00} + f_pc;
    always_comb begin
        unique case (d_icode)
            J:     d_jaddr = instr_idxE;
            JAL:   d_jaddr = instr_idxE;
            SPE: unique case (d_acode)
                JR:  d_jaddr = d_newval1;
                JALR: d_jaddr = d_newval1;
                default : d_jaddr = immeaddr;
            endcase
            JALR:  d_jaddr = d_newval1;
            default: d_jaddr = immeaddr;
        endcase
    end

//jump or not
    always_comb begin
        unique case (d_icode)
            BEQ: d_jump = (d_newval1 === d_newval2) ? 1 : 0;
            BNE: d_jump = (d_newval1 !== d_newval2) ? 1 : 0;
            J:   d_jump = 1;
            JAL: d_jump = 1;
            SPE: begin
                unique case (d_acode)
                    JR:  d_jump = 1;
                    JALR: d_jump = 1;
                    default: d_jump = 0;
                endcase
            end
            REGIMM: begin  //regard rt as code way
                unique case (d_rt)
                    BGEZ:   d_jump = (d_newval1 >= '0) ? 1 : 0;
                    BGEZAL: d_jump = (d_newval1 >= '0) ? 1 : 0;
                    BLTZ:   d_jump = (d_newval1 < '0) ? 1 : 0;
                    BLTZAL: d_jump = (d_newval1 < '0) ? 1 : 0;
                    default: d_jump = 0;
                endcase
            end
            BGTZ:   d_jump = (d_newval1 > '0) ? 1 : 0;
            BLEZ:   d_jump = (d_newval1 <= '0) ? 1 : 0;
            default: d_jump = 0;
        endcase
    end


//produce d_valt for sw 
    //assign d_valt = d_newval2;
    always_comb begin
        unique case (d_icode)
            SW:   d_valt = d_newval2;
            SB:   d_valt = d_newval2;
            SH:   d_valt = d_newval2;
            default: d_valt = 0;
        endcase
    end

endmodule
