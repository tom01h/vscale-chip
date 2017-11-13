`include "vscale_hasti_constants.vh"

module vscale_xbar
  (
   input                           clk,
   input                           resetn,

   input [`HASTI_ADDR_WIDTH-1:0]   im_addr,
   input                           im_read,
   input                           im_write,
   input [`HASTI_SIZE_WIDTH-1:0]   im_size,
   input [`HASTI_BUS_WIDTH-1:0]    im_wdata,
   output [`HASTI_BUS_WIDTH-1:0]   im_rdata,
   output                          im_ready,
   output                          im_resp,

   input [`HASTI_ADDR_WIDTH-1:0]   dm_addr,
   input                           dm_read,
   input                           dm_write,
   input [`HASTI_SIZE_WIDTH-1:0]   dm_size,
   input [`HASTI_BUS_WIDTH-1:0]    dm_wdata,
   output [`HASTI_BUS_WIDTH-1:0]   dm_rdata,
   output                          dm_ready,
   output                          dm_resp,

   output                          is_sel,
   output [`HASTI_ADDR_WIDTH-1:0]  is_addr,
   output                          is_read,
   output                          is_write,
   output [`HASTI_SIZE_WIDTH-1:0]  is_size,
   output [`HASTI_BUS_WIDTH-1:0]   is_wdata,
   input [`HASTI_BUS_WIDTH-1:0]    is_rdata,

   output                          ds_sel,
   output [`HASTI_ADDR_WIDTH-1:0]  ds_addr,
   output                          ds_read,
   output                          ds_write,
   output [`HASTI_SIZE_WIDTH-1:0]  ds_size,
   output [`HASTI_BUS_WIDTH-1:0]   ds_wdata,
   input [`HASTI_BUS_WIDTH-1:0]    ds_rdata,

   output                          ss_sel,
   output [`HASTI_ADDR_WIDTH-1:0]  ss_addr,
   output                          ss_read,
   output                          ss_write,
   output [`HASTI_SIZE_WIDTH-1:0]  ss_size,
   output [`HASTI_BURST_WIDTH-1:0] ss_burst,
   output                          ss_mastlock,
   output [`HASTI_PROT_WIDTH-1:0]  ss_prot,
   output [`HASTI_BUS_WIDTH-1:0]   ss_wdata,
   input [`HASTI_BUS_WIDTH-1:0]    ss_rdata,
   input                           ss_ready,
   input                           ss_resp
   );

`define AHB_AREA 14
//`define AHB_AREA 18

   wire [2:0] im_sel = ((|im_addr[`HASTI_ADDR_WIDTH-1:`AHB_AREA+1]) ? 3'b100 :   // [2] system
                        ( im_addr[`AHB_AREA])                       ? 3'b010 :   // [1] data
                                                                      3'b001  )& // [0] inst
                       {3{(im_read|im_write)}};
   wire [2:0] dm_sel = ((|dm_addr[`HASTI_ADDR_WIDTH-1:`AHB_AREA+1]) ? 3'b100 :   // [2] system
                        ( dm_addr[`AHB_AREA])                       ? 3'b010 :   // [1] data
                                                                      3'b001  )& // [0] inst
                       {3{(dm_read|dm_write)}};

   assign is_sel = im_sel[0]|dm_sel[0];
   assign ds_sel = im_sel[1]|dm_sel[1];
   assign ss_sel = im_sel[2]|dm_sel[2];
  
   reg [2:0]  im_sel_l, dm_sel_l, sm_sel_l;

   always @ (posedge clk)
     if(~resetn) im_sel_l <= 3'b000;
     else if(im_ready) im_sel_l <= im_sel;
   always @ (posedge clk)
     if(~resetn) dm_sel_l <= 3'b000;
     else if(dm_ready) dm_sel_l <= dm_sel;

   assign is_addr     = (~dm_sel[0]) ? im_addr     : dm_addr;
   assign is_read     = (~dm_sel[0]) ? im_read     : dm_read;
   assign is_write    = (~dm_sel[0]) ? im_write    : dm_write;
   assign is_size     = (~dm_sel[0]) ? im_size     : dm_size;
   assign is_wdata    = (~dm_sel[0]) ? im_wdata    : dm_wdata;
   
   assign ds_addr     = (~dm_sel[1]) ? im_addr     : dm_addr;
   assign ds_read     = (~dm_sel[1]) ? im_read     : dm_read;
   assign ds_write    = (~dm_sel[1]) ? im_write    : dm_write;
   assign ds_size     = (~dm_sel[1]) ? im_size     : dm_size;
   assign ds_wdata    = (~dm_sel[1]) ? im_wdata    : dm_wdata;
   
   assign ss_addr     = (~dm_sel[2]) ? im_addr     : dm_addr;
   assign ss_read     = (~dm_sel[2]) ? im_read     : dm_read;
   assign ss_write    = (~dm_sel[2]) ? im_write    : dm_write;
   assign ss_size     = (~dm_sel[2]) ? im_size     : dm_size;
   assign ss_burst    = `HASTI_BURST_SINGLE;
   assign ss_mastlock = `HASTI_MASTER_NO_LOCK;
   assign ss_prot     = `HASTI_NO_PROT;
   assign ss_wdata    = (~dm_sel[2]) ? im_wdata    : dm_wdata;
   
   assign im_rdata = (im_sel_l[2]) ? ss_rdata : (im_sel_l[1]) ? ds_rdata : is_rdata;
   assign im_ready = ~((im_sel[0] & dm_sel[0])|(im_sel[1] & dm_sel[1]));
   assign im_resp  = 1'b0;

   assign dm_rdata = (dm_sel_l[2]) ? ss_rdata : (dm_sel_l[1]) ? ds_rdata : is_rdata;
   assign dm_ready = 1'b1;
   assign dm_resp  = 1'b0;
   
endmodule // vscale_xbar
