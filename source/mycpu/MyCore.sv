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
    i5 d_dst, d_src1, d_src2, d_rd, d_sa; 
    
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
    i1 E_bubble;

    Ereg ereg(
        .E_pc(d_pc), .E_val1(d_val1),
        .E_val2(d_val2), .E_valt(d_valt),
        .E_icode(d_icode), .E_acode(d_acode),
        .E_dst(d_dst), .E_src1(d_src1), .E_src2(d_src2), 
        .E_rd(d_rd), .E_sa(d_sa),
        .E_bubble, .clk,
        .e_req,
        .*
        );

//M
    i32 m_pc, m_val3;
    i6 m_icode, m_acode;
    i5 m_dst;
    i4 m_write_enable;

    Mreg mreg(
        .M_pc(e_pc), .M_val3(e_val3), .M_icode(e_icode),
        .M_acode(e_acode), .M_dst(e_dst), .clk,
        .*
        );
  
//W
    i32 w_pc;
    i32 w_val3;
    i5 w_dst;
    i4 w_write_enable;
    

    Wreg wreg(
        .W_pc(m_pc), .W_val3(m_val3), .W_icode(m_icode),
        .W_acode(m_acode), .W_dst(m_dst), .W_write_enable(m_write_enable),
        .clk,
        .*
        );

//regfile
    i32 d_regval1, d_regval2;
    i5 d_regidx1, d_regidx2;

    Regfile regfile(
        .ra1(d_regidx1), .ra2(d_regidx2), .wa3(w_dst),
        .write_enable(w_write_enable[0]), 
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
    //Controlreg controlreg(.*);  //is it written by me?
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

//request
    always_comb begin
        ireq.valid = ~D_stall;    
        ireq.addr = f_pc;
    end
    
//reception
    i32 instr;

    always_comb begin
        instr = iresp.data;
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
        dreq.valid = '1;
        dreq.addr = e_val3;
        dreq.size = MSIZE4;      //problem1: which size?
        dreq.strobe = e_req; //
        dreq.data = e_valt;
    end

//reception
    i32 m_data;

    always_comb begin
        m_data = dresp.data;
    end

//initialize the PC value
    i1 test;
    always_ff @(posedge clk) begin
        if (~resetn) begin
            // AHA!
            pred_pc <= 32'hbfc0_0000; 
        end else begin

        end
            // reset
            // NOTE: if resetn is X, it will be evaluated to false.
    end

    // remove following lines when you start
    /*
    assign ireq = 0;
    assign dreq = 0;
    logic _unused_ok = &{iresp, dresp};
    */
endmodule
