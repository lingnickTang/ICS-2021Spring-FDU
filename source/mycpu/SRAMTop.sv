`include "common.svh"
`include "sramx.svh"

module SRAMTop(
    input logic clk, resetn,

    output logic        inst_sram_en,
    output logic [3 :0] inst_sram_wen,
    output logic [31:0] inst_sram_addr,
    output logic [31:0] inst_sram_wdata,
    
    input  logic [31:0] inst_sram_rdata,
    
    output logic        data_sram_en,
    output logic [3 :0] data_sram_wen,
    output logic [31:0] data_sram_addr,
    output logic [31:0] data_sram_wdata,
    
    input  logic [31:0] data_sram_rdata,

    input i6 ext_int
);
    ibus_req_t   ireq;
    ibus_resp_t  iresp;
    dbus_req_t   dreq;
    dbus_resp_t  dresp;
    sramx_req_t  isreq,  dsreq;
    sramx_resp_t isresp, dsresp;

    MyCore core(.*);
    IBusToSRAMx icvt(.*);
    DBusToSRAMx dcvt(.*);

    /**
     * TODO (optional) add address translations for isreq.addr & dsreq.addr :)
     */
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
    assign vaddrD = dreq.addr;
    assign dsreq.addr = paddrD;

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
    assign vaddrI = ireq.addr;
    assign isreq.addr = paddrI;



    assign inst_sram_en    = isreq.en;
    assign inst_sram_wen   = isreq.wen;
    assign inst_sram_addr  = isreq.addr;
    assign inst_sram_wdata = isreq.wdata;
    assign isresp.rdata    = inst_sram_rdata;

    assign data_sram_en    = dsreq.en;
    assign data_sram_wen   = dsreq.wen;
    assign data_sram_addr  = dsreq.addr;
    assign data_sram_wdata = dsreq.wdata;
    assign dsresp.rdata    = data_sram_rdata;

    logic _unused_ok = &{ext_int};
endmodule
