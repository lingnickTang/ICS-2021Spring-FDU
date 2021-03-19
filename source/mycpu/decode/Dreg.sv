`include "common.svh"
`include "Myheadfile.svh"
module Dreg(
    input i32 D_pc,   
    input i6 D_icode, D_acode,
    input i5 D_rt, D_rs, D_rd, D_sa,
    input i1 D_stall, clk, resetn,

    output i32 d_pc, d_val1, d_val2, d_valt,   
    output i6 d_icode, d_acode,
    output i5 d_dst, d_src1, d_src2, d_sa, //to splice into imme
    output i1 d_jump,

    input i32 w_val3, m_val3, e_val3,
    input i5 w_dst, m_dst, e_dst, 
    
    input i32 pred_pc, f_pc, //JAL
    
    input i32 d_regval1, d_regval2,
    output i5 d_regidx1, d_regidx2
);
    //consider the D_stall
    i5 d_rt, d_rs, d_rd;

    always_ff @(posedge clk) begin
        if(~D_stall | resetn)d_pc <= D_pc;
    end

//stall and bubble are not proper in combinatorial logic
    always_comb begin
        //if(~D_stall)begin
        d_icode = D_icode;
        d_acode = D_acode;
        d_rd = D_rd;
        d_sa = D_sa;

        d_rt = D_rt;
        d_rs = D_rs;
        //end
    end

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
            default: d_dst = 0;
        endcase
    end

//select the d_src1 ans d_src2
    always_comb begin
        d_src1 = d_rs;
        d_src2 = d_rt;
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
            JAL: d_val1 = pred_pc;  //
            LUI: d_val1 = 0;
            SPE: begin
                unique case (d_acode)
                    SRA: d_val1 = 0; //the normal rs is 0 which lead the d_val1 to 0 too.
                    SRL: d_val1 = 0; //so can these two lines be ignored?
                    default: d_val1 = d_newval1;
                endcase
            end
            default: d_val1 = d_newval1;
        endcase
    end

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

//produce d_val2
    always_comb begin
        unique case (d_icode)
            ADDIU: d_val2 = immeSE;
            ANDI:  d_val2 = immeZE;
            J:     d_val2 = instr_idxE;
            JAL:   d_val2 = instr_idxE;
            LUI:   d_val2 = immeZF;
            LW:    d_val2 = immeSE;  //offset
            ORI:   d_val2 = immeZE;
            SLTI:  d_val2 = immeSE;
            SLTIU: d_val2 = immeSE;
            SW:    d_val2 = immeSE; //offset
            XORI:  d_val2 = immeZE;

            SPE:begin
                unique case (d_acode)
                    JR: d_val2 = d_newval1; //special JR, using GPR[rs]
                    default: d_val2 = d_newval2;
                endcase
            end

            BEQ: begin
                if(d_newval1 === d_newval2) begin
                    d_val2 = {immeSE[29:0],2'b00} + f_pc;
                end else d_val2 = 0;
            end 
            BNE: begin
                if(d_newval1 !== d_newval2) begin
                    d_val2 = {immeSE[29:0],2'b00} + f_pc;
                end else d_val2 = 0;
            end
            default: d_val2 = 0;
        endcase
    end

//jump or not
    always_comb begin
        unique case (d_icode)
            BEQ: begin 
                if(d_newval1 === d_newval2) begin
                    d_jump = 1;
                end else d_jump = 0;
            end
            BNE: begin 
                if(d_newval1 !== d_newval2) begin
                    d_jump = 1;
                end else d_jump = 0;
            end
            J:   d_jump = 1;
            JAL: d_jump = 1;
            SPE: begin
                if(d_acode === JR)d_jump = 1;
                else d_jump = 0;   // confirm that the bubble set all signals to 0
            end
            default: d_jump = 0;
        endcase
    end

//produce d_valt only for sw
    assign d_valt = d_newval2;

endmodule
