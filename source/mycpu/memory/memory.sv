`include "common.svh"
`include "Myheadfile.svh"
module Mreg(
    input i32 M_pc, M_val3,
    input i6 M_icode, M_acode,
    input i5 M_dst,
    input i1 clk, resetn,

    output i32 m_pc, m_val3,
    output i6 m_icode, m_acode,
    output i5 m_dst,
    output i4 m_write_enable,

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
        if(m_pc === 32'h0000_0000) m_write_enable = '0; //ensure the bubble come out all 0 results.
        else begin
            unique case (m_icode)
                ADDIU: m_write_enable = '1;
                ANDI:  m_write_enable = '1;
                JAL:   m_write_enable = '1;
                LUI:   m_write_enable = '1;
                LW:    m_write_enable = '1;
                ORI:   m_write_enable = '1;
                SLTI:  m_write_enable = '1;
                SLTIU: m_write_enable = '1;
                XORI:  m_write_enable = '1;
                SPE: begin
                    unique case (m_acode)                        
                        JR:  m_write_enable = '0;
                        default: m_write_enable = '1;
                    endcase
                end
                default: m_write_enable = '0;
            endcase
        end
    end
    
endmodule