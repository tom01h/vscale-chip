`include "vscale_hasti_constants.vh"

module vscale_xbar
  (
   input                           hclk,
   input                           hresetn,

   input [`HASTI_ADDR_WIDTH-1:0]   im_haddr,
   input                           im_hwrite,
   input [`HASTI_SIZE_WIDTH-1:0]   im_hsize,
   input [`HASTI_BURST_WIDTH-1:0]  im_hburst,
   input                           im_hmastlock,
   input [`HASTI_PROT_WIDTH-1:0]   im_hprot,
   input [`HASTI_TRANS_WIDTH-1:0]  im_htrans,
   input [`HASTI_BUS_WIDTH-1:0]    im_hwdata,
   output [`HASTI_BUS_WIDTH-1:0]   im_hrdata,
   output                          im_hready,
   output                          im_hresp,

   input [`HASTI_ADDR_WIDTH-1:0]   dm_haddr,
   input                           dm_hwrite,
   input [`HASTI_SIZE_WIDTH-1:0]   dm_hsize,
   input [`HASTI_BURST_WIDTH-1:0]  dm_hburst,
   input                           dm_hmastlock,
   input [`HASTI_PROT_WIDTH-1:0]   dm_hprot,
   input [`HASTI_TRANS_WIDTH-1:0]  dm_htrans,
   input [`HASTI_BUS_WIDTH-1:0]    dm_hwdata,
   output [`HASTI_BUS_WIDTH-1:0]   dm_hrdata,
   output                          dm_hready,
   output                          dm_hresp,

   output                          is_hsel,
   output [`HASTI_ADDR_WIDTH-1:0]  is_haddr,
   output                          is_hwrite,
   output [`HASTI_SIZE_WIDTH-1:0]  is_hsize,
   output [`HASTI_BURST_WIDTH-1:0] is_hburst,
   output                          is_hmastlock,
   output [`HASTI_PROT_WIDTH-1:0]  is_hprot,
   output [`HASTI_TRANS_WIDTH-1:0] is_htrans,
   output [`HASTI_BUS_WIDTH-1:0]   is_hwdata,
   input [`HASTI_BUS_WIDTH-1:0]    is_hrdata,
   input                           is_hready,
   input                           is_hresp,

   output                          ds_hsel,
   output [`HASTI_ADDR_WIDTH-1:0]  ds_haddr,
   output                          ds_hwrite,
   output [`HASTI_SIZE_WIDTH-1:0]  ds_hsize,
   output [`HASTI_BURST_WIDTH-1:0] ds_hburst,
   output                          ds_hmastlock,
   output [`HASTI_PROT_WIDTH-1:0]  ds_hprot,
   output [`HASTI_TRANS_WIDTH-1:0] ds_htrans,
   output [`HASTI_BUS_WIDTH-1:0]   ds_hwdata,
   input [`HASTI_BUS_WIDTH-1:0]    ds_hrdata,
   input                           ds_hready,
   input                           ds_hresp,

   output                          ss_hsel,
   output [`HASTI_ADDR_WIDTH-1:0]  ss_haddr,
   output                          ss_hwrite,
   output [`HASTI_SIZE_WIDTH-1:0]  ss_hsize,
   output [`HASTI_BURST_WIDTH-1:0] ss_hburst,
   output                          ss_hmastlock,
   output [`HASTI_PROT_WIDTH-1:0]  ss_hprot,
   output [`HASTI_TRANS_WIDTH-1:0] ss_htrans,
   output [`HASTI_BUS_WIDTH-1:0]   ss_hwdata,
   input [`HASTI_BUS_WIDTH-1:0]    ss_hrdata,
   input                           ss_hready,
   input                           ss_hresp
   );

`define AHB_AREA 14
//`define AHB_AREA 18

   wire [2:0] im_hsel = ((|im_haddr[`HASTI_ADDR_WIDTH-1:`AHB_AREA+1]) ? 3'b100 :   // [2] system
                         ( im_haddr[`AHB_AREA])                       ? 3'b010 :   // [1] data
                                                                        3'b001  )& // [0] inst
                        {3{(im_htrans == `HASTI_TRANS_NONSEQ)}};
   wire [2:0] dm_hsel = ((|dm_haddr[`HASTI_ADDR_WIDTH-1:`AHB_AREA+1]) ? 3'b100 :   // [2] system
                         ( dm_haddr[`AHB_AREA])                       ? 3'b010 :   // [1] data
                                                                        3'b001  )& // [0] inst
                        {3{(dm_htrans == `HASTI_TRANS_NONSEQ)}};
//   wire [2:0] sm_hsel = {sm_haddr[`AHB_AREA] == 1'b1,
//                         sm_haddr[`AHB_AREA:`AHB_AREA-1] == 2'b01,
//                         sm_haddr[`AHB_AREA:`AHB_AREA-1] == 2'b00}&
//                        {3{(sm_htrans == `HASTI_TRANS_NONSEQ)}};
   
   assign is_hsel = im_hsel[0]&(im_htrans == `HASTI_TRANS_NONSEQ)|
                    dm_hsel[0]&(dm_htrans == `HASTI_TRANS_NONSEQ);
   assign ds_hsel = im_hsel[1]&(im_htrans == `HASTI_TRANS_NONSEQ)|
                    dm_hsel[1]&(dm_htrans == `HASTI_TRANS_NONSEQ);
   assign ss_hsel = im_hsel[2]&(im_htrans == `HASTI_TRANS_NONSEQ)|
                    dm_hsel[2]&(dm_htrans == `HASTI_TRANS_NONSEQ);
  
   reg [2:0]  im_hsel_l, dm_hsel_l, sm_hsel_l;

   always @ (posedge hclk)
     if(~hresetn) im_hsel_l <= 1'b0;
     else if(im_hready) im_hsel_l <= im_hsel;
   always @ (posedge hclk)
     if(~hresetn) dm_hsel_l <= 1'b0;
     else if(dm_hready) dm_hsel_l <= dm_hsel;
//   always @ (posedge hclk)
//     if(~hresetn) sm_hsel_l <= 1'b0;
//     else if(~sm_hready) sm_hsel_l <= sm_hsel;

   assign is_haddr     = (~dm_hsel[0]) ? im_haddr     : dm_haddr;
   assign is_hwrite    = (~dm_hsel[0]) ? im_hwrite    : dm_hwrite;
   assign is_hsize     = (~dm_hsel[0]) ? im_hsize     : dm_hsize;
   assign is_hburst    = (~dm_hsel[0]) ? im_hburst    : dm_hburst;
   assign is_hmastlock = (~dm_hsel[0]) ? im_hmastlock : dm_hmastlock;
   assign is_hprot     = (~dm_hsel[0]) ? im_hprot     : dm_hprot;
   assign is_htrans    = (~dm_hsel[0]) ? im_htrans    : dm_htrans;
   assign is_hwdata    = (~dm_hsel_l[0]) ? im_hwdata  : dm_hwdata;
   
   assign ds_haddr     = (~dm_hsel[1]) ? im_haddr     : dm_haddr;
   assign ds_hwrite    = (~dm_hsel[1]) ? im_hwrite    : dm_hwrite;
   assign ds_hsize     = (~dm_hsel[1]) ? im_hsize     : dm_hsize;
   assign ds_hburst    = (~dm_hsel[1]) ? im_hburst    : dm_hburst;
   assign ds_hmastlock = (~dm_hsel[1]) ? im_hmastlock : dm_hmastlock;
   assign ds_hprot     = (~dm_hsel[1]) ? im_hprot     : dm_hprot;
   assign ds_htrans    = (~dm_hsel[1]) ? im_htrans    : dm_htrans;
   assign ds_hwdata    = (~dm_hsel_l[1]) ? im_hwdata  : dm_hwdata;
   
   assign ss_haddr     = (~dm_hsel[2]) ? im_haddr     : dm_haddr;
   assign ss_hwrite    = (~dm_hsel[2]) ? im_hwrite    : dm_hwrite;
   assign ss_hsize     = (~dm_hsel[2]) ? im_hsize     : dm_hsize;
   assign ss_hburst    = (~dm_hsel[2]) ? im_hburst    : dm_hburst;
   assign ss_hmastlock = (~dm_hsel[2]) ? im_hmastlock : dm_hmastlock;
   assign ss_hprot     = (~dm_hsel[2]) ? im_hprot     : dm_hprot;
   assign ss_htrans    = (~dm_hsel[2]) ? im_htrans    : dm_htrans;
   assign ss_hwdata    = (~dm_hsel_l[2]) ? im_hwdata  : dm_hwdata;
   
   assign im_hrdata = (im_hsel_l[2]) ? ss_hrdata : (im_hsel_l[1]) ? ds_hrdata : is_hrdata;
   assign im_hready = is_hready & ~(im_hsel_l[0] & dm_hsel_l[0]);  //TEMP//TEMP//
   assign im_hresp  = is_hresp & im_hsel_l[0];

   assign dm_hrdata = (dm_hsel_l[2]) ? ss_hrdata : (dm_hsel_l[1]) ? ds_hrdata : is_hrdata;
   assign dm_hready = is_hready;
   assign dm_hresp  = is_hresp & im_hsel_l[1];
   
endmodule // vscale_xbar
