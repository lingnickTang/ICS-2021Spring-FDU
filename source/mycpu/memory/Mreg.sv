`include "common.svh"
`include "Myheadfile.svh"
module Mreg(
    input i32 M_pc, M_val3, M_valt, 
    input i6 M_icode, M_acode,
    input i5 M_dst, M_rt,
    input i1 M_stall ,clk, resetn,

    output i32 m_pc, m_val3, m_valt, m_newval3,
    output i6 m_icode, m_acode,
    output i5 m_dst,
    output i4 m_write_enable, m_write_data,
    output i1 m_vreq, //need data

    input i32 m_data
);
    i5 m_rt;
    always_ff @(posedge clk) begin
        if(~resetn) begin
            m_pc <= 0;
            m_icode <= 0;
            m_acode <= 0;
            m_dst <= 0;
            m_newval3 <= 0;
            m_valt <= '0;
            m_rt <= 0;
        end else if(M_stall)begin
            
        end else begin
            m_pc <= M_pc;
            m_icode <= M_icode;
            m_acode <= M_acode;
            m_dst <= M_dst;
            m_newval3 <= M_val3;
            m_valt <= M_valt;
            m_rt <= M_rt;
        end
    end

    always_comb begin
        unique case (m_icode)
            LW:  m_val3 = m_data;
            LB:  m_val3 = {{24{m_data[7]}}, m_data[7:0]};
            LBU: m_val3 = {{24{1'b0}}, m_data[7:0]};
            LH:  m_val3 = {{16{m_data[15]}}, m_data[15:0]};
            LHU: m_val3 = {{16{1'b0}}, m_data[15:0]};
            default: m_val3 = m_newval3;
        endcase
    end

//transfer the en signal
    always_comb begin 
        if(m_pc === 32'h0000_0000) m_write_enable = '0; //ensure the bubble come out all 0 results.
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

                REGIMM: begin
                    unique case (m_rt)
                        BGEZAL: m_write_enable = 4'b1111;
                        BLTZAL: m_write_enable = 4'b1111;
                        default: m_write_enable = 4'b0000;
                    endcase
                end
                LB:   m_write_enable = 4'b1111;
                LBU:  m_write_enable = 4'b1111;
                LH:   m_write_enable = 4'b1111;
                LHU:  m_write_enable = 4'b1111;

                default: m_write_enable = 4'b0000;
            endcase
        end
    end

//request for Data memory
    always_comb begin
        unique case (m_icode)
            SW:  m_write_data = 4'b1111;
            SB:  m_write_data = 4'b1111;
            SH:  m_write_data = 4'b1111;
            default: m_write_data = 4'b0000;
        endcase
    end

    always_comb begin
        if(m_icode === SW || m_icode === LW)m_vreq = 1;
        else m_vreq = 0;
        unique case (m_icode)
            SW:  m_vreq = 1;
            LW:  m_vreq = 1;
            LB:  m_vreq = 1;
            LBU: m_vreq = 1;
            LH:  m_vreq = 1;
            LHU: m_vreq = 1;
            SB:  m_vreq = 1;
            SH:  m_vreq = 1;
            default: m_vreq = 0;
        endcase
    end
endmodule