`include "common.svh"
`include "Myheadfile.svh"
module Mreg(
    input i32 M_pc, M_val3,
    input i6 M_icode, M_acode,
    input i5 M_dst,
    input i1 clk, resetn,

    output i32 m_pc, m_val3, 
    output i5 m_dst,
    output i4 m_write_enable,
    output i6 m_icode, m_acode,

    input i32 m_data
);
    i32 m_tmpval3;

    always_ff @(posedge clk) begin
        if(~resetn) begin
            m_pc <= 0;
            m_icode <= 0;
            m_acode <= 0;
            m_dst <= 0;
            m_tmpval3 <= 0;
            //m_write_enable <= 0;
        end else begin
            m_pc <= M_pc;
            m_icode <= M_icode;
            m_acode <= M_acode;
            m_dst <= M_dst;
            m_tmpval3 <= M_val3;
        end
    end

    always_comb begin
        unique case (m_icode)
            LW: m_val3 = m_data;
            default: m_val3 = m_tmpval3;
        endcase
    end

//transfer the en signal
    always_comb begin 
        if(m_pc === 32'h0000_0000) m_write_enable = 4'b0000; //ensure the bubble come out all 0 results.
        else begin
            unique case (m_icode)
                ADDIU: m_write_enable = 4'b1111;
                ANDI:  m_write_enable = 4'b1111;
                JAL:   m_write_enable = 4'b1111;
                LUI:   m_write_enable = 4'b1111;
                LW:    m_write_enable = 4'b1111;
                ORI:   m_write_enable = 4'b1111;
                SLTI:  m_write_enable = 4'b1111;
                SLTIU: m_write_enable = 4'b1111;
                XORI:  m_write_enable = 4'b1111;
                SPE: begin
                    unique case (m_acode)                        
                        JR:  m_write_enable = 4'b0000;
                        default: m_write_enable = 4'b1111;
                    endcase
                end
                default: m_write_enable = 4'b0000;
            endcase
        end
    end
    
endmodule
