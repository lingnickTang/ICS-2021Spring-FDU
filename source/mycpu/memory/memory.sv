`include "common.svh"
`include "Myheadfile.svh"
module Mreg(
    input i32 M_pc, M_val3,
    input i6 M_icode, M_acode,
    input i5 M_dst,
    input i1 clk,

    output i32 m_pc, m_val3,
    output i6 m_icode, m_acode,
    output i5 m_dst,

    input i32 m_data
);
    i32 m_tmpval3;

    always_ff @(posedge clk) begin
        m_pc <= M_pc;
        m_icode <= M_icode;
        m_acode <= M_acode;
        m_dst <= M_dst;
        m_tmpval3 <= M_val3;
    end

    always_comb begin
        unique case (m_icode)
            LW: m_val3 = m_data;
            default: m_val3 = m_tmpval3;
        endcase
    end
    
endmodule