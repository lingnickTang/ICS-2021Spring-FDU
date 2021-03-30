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
    i1 F_stall;
    i32 selpc, pred_pc;

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
    i1 D_stall;

    i1 d_jump;
    i32 d_pc, d_val1, d_val2, d_valt;   
    i6 d_icode, d_acode;
    i5 d_dst, d_src1, d_src2, d_sa;
    
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
    i5 e_dst;

    i32 e_valt;
    i4 e_req;
    i1 E_bubble, e_vreq;

    Ereg ereg(
        .E_pc(d_pc), .E_val1(d_val1),
        .E_val2(d_val2), .E_valt(d_valt),
        .E_icode(d_icode), .E_acode(d_acode),
        .E_dst(d_dst),
        .E_sa(d_sa),
        .E_bubble, .clk,
        .e_req,
        .*
        );

//M
    i32 m_pc; /* verilator lint_off UNUSED */
    i32 m_val3; 
    i6 m_icode, m_acode; /* verilator lint_off UNUSED */
    i5 m_dst;
    i4 m_write_enable;

    i1 unused_ok = &{1'b0, m_pc ,1'b0};  //reduced

    Mreg mreg(
        .M_pc(e_pc), .M_val3(e_val3), .M_icode(e_icode),
        .M_acode(e_acode), .M_dst(e_dst), .clk,
        .*
        );
  
//W
    //i32 w_pc;
    i32 w_val3;
    i5 w_dst;
    i4 w_write_enable;
    
    Wreg wreg(
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

    always_comb begin
        F_stall = conflict1;
        D_stall = conflict1;
        E_bubble = conflict1;
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
    //ibus_req_t tmpi /* verilator split_var */; 
    always_comb begin
        vaddrI = f_pc;
        ireq.valid = ~D_stall;    
    end
    //assign  ireq.addr = tmpi.addr;
    //assign  ireq.valid = tmpi.valid;
    
//reception
    i32 instr;
    i1 i_data_ok, i_addr_ok;
    

    always_comb begin
        i_data_ok = iresp.data_ok;
        i_addr_ok = iresp.addr_ok;

        if(i_data_ok && i_addr_ok)instr = iresp.data;
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
        dreq.valid = e_vreq;
        vaddrD = e_val3;
        dreq.size = MSIZE4;      //problem1: which size?
        dreq.strobe = e_req; //
        dreq.data = e_valt;
    end

//reception
    i32 m_data;
    i1 m_data_ok, m_addr_ok;
    always_comb begin
        m_data_ok = dresp.data_ok;
        m_addr_ok = dresp.addr_ok;

        if(m_data_ok && m_addr_ok)m_data = dresp.data;
        else m_data = '0;
    end

//initialize the PC value
    always_ff @(posedge clk) begin
        if (~resetn) begin
            // AHA!
            //pred_pc <= 32'hbfc0_0000; 
        end else begin

        end
            // reset
            // NOTE: if resetn is X, it will be evaluated to false.
    end

    // remove following lines when you start
<<<<<<< HEAD
    /*
    assign ireq = 0;
    assign dreq = 0;
    logic _unused_ok = &{iresp, dresp};
    */
=======
    assign ireq = '0;
    assign dreq = '0;
    `UNUSED_OK({iresp, dresp});
>>>>>>> upstream/master
endmodule
