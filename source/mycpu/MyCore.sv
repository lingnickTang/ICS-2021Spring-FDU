`include "common.svh"
`include "Myheadfile.svh"
module MyCore (
    input logic clk, resetn,

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    /****
     * TODO (Lab1) your code here :)
     ***/
// F
    i32 selpc, pred_pc;
    i1 f_vreq;
    Freg freg(
        .F_pc(selpc), .F_stall,
        .f_pc, .pred_pc,
        .clk, .resetn,
        .*
        );

// D
    i32 f_pc;    
    i6 f_icode, f_acode;
    i5 f_rt, f_rs, f_rd, f_sa;

    i1 d_jump;
    i32 d_jaddr;
    i32 d_pc, d_val1, d_val2, d_valt;   
    i6 d_icode, d_acode;
    i5 d_dst, d_src1, d_src2, d_rt;
    
    Dreg dreg(
        .d_jump,
        .D_pc(f_pc), .D_icode(f_icode), .D_acode(f_acode), 
        .D_rt(f_rt), .D_rs(f_rs), .D_rd(f_rd), .D_sa(f_sa),
        .w_val3, .m_val3, .e_val3,
        .w_dst, .m_dst, .e_dst,
        .pred_pc, .f_pc,
        .clk,
        .*
        );

//E
    i32 e_pc,e_val3;
    i6 e_icode, e_acode;
    i5 e_dst, e_rt;

    i32 e_valt;

    Ereg ereg(
        .E_pc(d_pc), .E_val1(d_val1),
        .E_val2(d_val2), .E_valt(d_valt),
        .E_icode(d_icode), .E_acode(d_acode),
        .E_dst(d_dst), .E_rt(d_rt),
        .E_bubble, .clk,
        .*
        );

//M
    i32 m_pc, m_valt;
    i32 m_val3, m_newval3; 
    i6 m_icode, m_acode;
    i5 m_dst;
    i4 m_write_enable, m_write_data;
    i1 m_vreq;

    i1 unused_ok = &{1'b0, m_pc ,1'b0};  //reduced

    Mreg mreg(
        .M_pc(e_pc), .M_val3(e_val3), .M_icode(e_icode),
        .M_acode(e_acode), .M_dst(e_dst), .clk,
        .M_rt(e_rt), .M_valt(e_valt),
        .*
        );
  
//W
    i32 w_pc;
    i32 w_val3;
    i6 w_acode, w_icode;
    i5 w_dst;
    i4 w_write_enable;

    Wreg wreg(
        .W_pc(m_pc), .W_acode(m_acode), .W_icode(m_icode),
        .W_val3(m_val3), .W_dst(m_dst), 
        .W_write_enable(m_write_enable),
        .clk,
        .*
        );

//regfile
    i32 d_regval1, d_regval2;
    i5 d_regidx1, d_regidx2;

    Regfile regfile(
        .ra1(d_regidx1), .ra2(d_regidx2), .wa3(w_dst),
        .write_enable(w_write_enable), 
        .wd3(w_val3), .rd1(d_regval1), .rd2(d_regval2),
        .clk,
        .*
    );

//PC selection
    always_comb begin
        if(d_jump === 1)selpc = d_val2;
        else selpc = pred_pc;
    end

//My control


//control logic
    i1 conflict1;  //consider the zero register
    always_comb begin
        if(e_icode === LW && (e_dst === d_src1 || e_dst === d_src2)) begin
            unique case (d_icode)
                J:   conflict1 = 0;
                JAL: conflict1 = 0;
                LUI: conflict1 = 0;
                default: conflict1 = '1;
            endcase
        end else conflict1 = 0;
    end

//bubble and stall
    i1 F_stall, D_stall, E_stall, M_stall;
    i1 D_bubble, E_bubble, W_bubble;
    i1 data_stall,instr_stall;

    always_comb begin
        F_stall = conflict1 | instr_stall | data_stall;
        D_stall = conflict1 | instr_stall | data_stall;
        E_stall = data_stall;
        M_stall = data_stall;

        D_bubble = instr_stall;
        E_bubble = conflict1;
        W_bubble = data_stall;
    end

// instruction request and reception
    typedef logic [31:0] paddr_t;
    typedef logic [31:0] vaddr_t;
    //translation for dreq

    paddr_t paddrD; // physical address
    vaddr_t vaddrD; // virtual address

    assign paddrD[27:0] = vaddrD[27:0];
    always_comb begin
        unique case (vaddrD[31:28])
            4'h8: paddrD[31:28] = 4'b0; // kseg0
            4'h9: paddrD[31:28] = 4'b1; // kseg0
            4'ha: paddrD[31:28] = 4'b0; // kseg1
            4'hb: paddrD[31:28] = 4'b1; // kseg1
            default: paddrD[31:28] = vaddrD[31:28]; // useg, ksseg, kseg3
        endcase
    end
    assign dreq.addr = paddrD;

//translation for ireq            
    paddr_t paddrI; // physical address
    vaddr_t vaddrI; // virtual address

    assign paddrI[27:0] = vaddrI[27:0];
    always_comb begin
        unique case (vaddrI[31:28])
            4'h8: paddrI[31:28] = 4'b0; // kseg0
            4'h9: paddrI[31:28] = 4'b1; // kseg0
            4'ha: paddrI[31:28] = 4'b0; // kseg1
            4'hb: paddrI[31:28] = 4'b1; // kseg1
            default: paddrI[31:28] = vaddrI[31:28]; // useg, ksseg, kseg3
        endcase
    end
    assign ireq.addr = paddrI;

//request
    always_comb begin
        vaddrI = f_pc;
        ireq.valid = '1;    
    end
    
//reception
    i32 instr;
    i1 i_resp;

    always_comb begin
        i_resp = iresp.data_ok & iresp.addr_ok;
        instr_stall = ~i_resp & f_vreq;

        if(i_resp)instr = iresp.data;
        else instr = '0;

        f_icode = instr[31:26];
        f_rs = instr[25:21];
        f_rt = instr[20:16];
        f_rd = instr[15:11];
        f_sa = instr[10:6];
        f_acode = instr[5:0];
    end

// data request and reception

//request
    always_comb begin
        dreq.valid = m_vreq;
        vaddrD = m_newval3;
        dreq.size = MSIZE4;      //problem1: which size?
        dreq.strobe = m_write_data; //
        dreq.data = m_valt;
    end

//reception
    i32 m_data;
    i1 d_resp;
    always_comb begin
        d_resp = dresp.data_ok & dresp.addr_ok;
        if(d_resp)m_data = dresp.data;
        else m_data = '0;
        data_stall = m_vreq && ~d_resp && ~m_write_data[0]; //data need
    end
    
    /*
    logic _unused_ok = &{iresp, dresp};
    */
endmodule
