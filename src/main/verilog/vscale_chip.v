`include "vscale_hasti_constants.vh"
`include "vscale_platform_constants.vh"

module vscale_chip
  (
   input  clk,
   input  rstn,
   input  RXD,
   output TXD
   );

   wire   reset = ~rstn;
   wire   resetn;

   wire [`HASTI_ADDR_WIDTH-1:0]  im_haddr;
   wire                          im_hwrite;
   wire [`HASTI_SIZE_WIDTH-1:0]  im_hsize;
   wire [`HASTI_BURST_WIDTH-1:0] im_hburst;
   wire                          im_hmastlock;
   wire [`HASTI_PROT_WIDTH-1:0]  im_hprot;
   wire [`HASTI_TRANS_WIDTH-1:0] im_htrans;
   wire [`HASTI_BUS_WIDTH-1:0]   im_hwdata;
   wire [`HASTI_BUS_WIDTH-1:0]   im_hrdata;
   wire                          im_hready;
   wire [`HASTI_RESP_WIDTH-1:0]  im_hresp;

   wire [`HASTI_ADDR_WIDTH-1:0]  dm_haddr;
   wire                          dm_hwrite;
   wire [`HASTI_SIZE_WIDTH-1:0]  dm_hsize;
   wire [`HASTI_BURST_WIDTH-1:0] dm_hburst;
   wire                          dm_hmastlock;
   wire [`HASTI_PROT_WIDTH-1:0]  dm_hprot;
   wire [`HASTI_TRANS_WIDTH-1:0] dm_htrans;
   wire [`HASTI_BUS_WIDTH-1:0]   dm_hwdata;
   wire [`HASTI_BUS_WIDTH-1:0]   dm_hrdata;
   wire                          dm_hready;
   wire [`HASTI_RESP_WIDTH-1:0]  dm_hresp;

   wire                          is_hsel;
   wire [`HASTI_ADDR_WIDTH-1:0]  is_haddr;
   wire                          is_hwrite;
   wire [`HASTI_SIZE_WIDTH-1:0]  is_hsize;
   wire [`HASTI_BURST_WIDTH-1:0] is_hburst;
   wire                          is_hmastlock;
   wire [`HASTI_PROT_WIDTH-1:0]  is_hprot;
   wire [`HASTI_TRANS_WIDTH-1:0] is_htrans;
   wire [`HASTI_BUS_WIDTH-1:0]   is_hwdata;
   wire [`HASTI_BUS_WIDTH-1:0]   is_hrdata;
   wire                          is_hready;
   wire [`HASTI_RESP_WIDTH-1:0]  is_hresp;

   wire                          ds_hsel;
   wire [`HASTI_ADDR_WIDTH-1:0]  ds_haddr;
   wire                          ds_hwrite;
   wire [`HASTI_SIZE_WIDTH-1:0]  ds_hsize;
   wire [`HASTI_BURST_WIDTH-1:0] ds_hburst;
   wire                          ds_hmastlock;
   wire [`HASTI_PROT_WIDTH-1:0]  ds_hprot;
   wire [`HASTI_TRANS_WIDTH-1:0] ds_htrans;
   wire [`HASTI_BUS_WIDTH-1:0]   ds_hwdata;
   wire [`HASTI_BUS_WIDTH-1:0]   ds_hrdata;
   wire                          ds_hready;
   wire [`HASTI_RESP_WIDTH-1:0]  ds_hresp;

   wire                          ss_hsel;
   wire [`HASTI_ADDR_WIDTH-1:0]  ss_haddr;
   wire                          ss_hwrite;
   wire [`HASTI_SIZE_WIDTH-1:0]  ss_hsize;
   wire [`HASTI_BURST_WIDTH-1:0] ss_hburst;
   wire                          ss_hmastlock;
   wire [`HASTI_PROT_WIDTH-1:0]  ss_hprot;
   wire [`HASTI_TRANS_WIDTH-1:0] ss_htrans;
   wire [`HASTI_BUS_WIDTH-1:0]   ss_hwdata;
   wire [`HASTI_BUS_WIDTH-1:0]   ss_hrdata;
   wire                          ss_hready;
   wire [`HASTI_RESP_WIDTH-1:0]  ss_hresp;

   assign resetn = ~reset;

   vscale_core vscale(
                      .clk(clk),
                      .reset(reset),
                      .ext_interrupts(`N_EXT_INTS'b0),
                      .imem_haddr(im_haddr),
                      .imem_hwrite(im_hwrite),
                      .imem_hsize(im_hsize),
                      .imem_hburst(im_hburst),
                      .imem_hmastlock(im_hmastlock),
                      .imem_hprot(im_hprot),
                      .imem_htrans(im_htrans),
                      .imem_hwdata(im_hwdata),
                      .imem_hrdata(im_hrdata),
                      .imem_hready(im_hready),
                      .imem_hresp(im_hresp),
                      .dmem_haddr(dm_haddr),
                      .dmem_hwrite(dm_hwrite),
                      .dmem_hsize(dm_hsize),
                      .dmem_hburst(dm_hburst),
                      .dmem_hmastlock(dm_hmastlock),
                      .dmem_hprot(dm_hprot),
                      .dmem_htrans(dm_htrans),
                      .dmem_hwdata(dm_hwdata),
                      .dmem_hrdata(dm_hrdata),
                      .dmem_hready(dm_hready),
                      .dmem_hresp(dm_hresp)
                      );

   vscale_xbar vscale_xbar(
                           .hclk(clk),
                           .hresetn(resetn),

                           .im_haddr(im_haddr),
                           .im_hwrite(im_hwrite),
                           .im_hsize(im_hsize),
                           .im_hburst(im_hburst),
                           .im_hmastlock(im_hmastlock),
                           .im_hprot(im_hprot),
                           .im_htrans(im_htrans),
                           .im_hwdata(im_hwdata),
                           .im_hrdata(im_hrdata),
                           .im_hready(im_hready),
                           .im_hresp(im_hresp),

                           .dm_haddr(dm_haddr),
                           .dm_hwrite(dm_hwrite),
                           .dm_hsize(dm_hsize),
                           .dm_hburst(dm_hburst),
                           .dm_hmastlock(dm_hmastlock),
                           .dm_hprot(dm_hprot),
                           .dm_htrans(dm_htrans),
                           .dm_hwdata(dm_hwdata),
                           .dm_hrdata(dm_hrdata),
                           .dm_hready(dm_hready),
                           .dm_hresp(dm_hresp),

                           .is_hsel(is_hsel),
                           .is_haddr(is_haddr),
                           .is_hwrite(is_hwrite),
                           .is_hsize(is_hsize),
                           .is_hburst(is_hburst),
                           .is_hmastlock(is_hmastlock),
                           .is_hprot(is_hprot),
                           .is_htrans(is_htrans),
                           .is_hwdata(is_hwdata),
                           .is_hrdata(is_hrdata),
                           .is_hready(is_hready),
                           .is_hresp(is_hresp),
      
                           .ds_hsel(ds_hsel),
                           .ds_haddr(ds_haddr),
                           .ds_hwrite(ds_hwrite),
                           .ds_hsize(ds_hsize),
                           .ds_hburst(ds_hburst),
                           .ds_hmastlock(ds_hmastlock),
                           .ds_hprot(ds_hprot),
                           .ds_htrans(ds_htrans),
                           .ds_hwdata(ds_hwdata),
                           .ds_hrdata(ds_hrdata),
                           .ds_hready(ds_hready),
                           .ds_hresp(ds_hresp),
      
                           .ss_hsel(ss_hsel),
                           .ss_haddr(ss_haddr),
                           .ss_hwrite(ss_hwrite),
                           .ss_hsize(ss_hsize),
                           .ss_hburst(ss_hburst),
                           .ss_hmastlock(ss_hmastlock),
                           .ss_hprot(ss_hprot),
                           .ss_htrans(ss_htrans),
                           .ss_hwdata(ss_hwdata),
                           .ss_hrdata(ss_hrdata),
                           .ss_hready(ss_hready),
                           .ss_hresp(ss_hresp)
                           );

   ahbmem imem(
               .hclk(clk),
               .hresetn(resetn),
               .hsel(is_hsel),
               .haddr(is_haddr),
               .hwrite(is_hwrite),
               .hsize(is_hsize),
               .hburst(is_hburst),
               .hmastlock(is_hmastlock),
               .hprot(is_hprot),
               .htrans(is_htrans),
               .hwdata(is_hwdata),
               .hrdata(is_hrdata),
               .hready(is_hready),
               .hresp(is_hresp)
               );

   ahbmem dmem(
               .hclk(clk),
               .hresetn(resetn),
               .hsel(ds_hsel),
               .haddr(ds_haddr),
               .hwrite(ds_hwrite),
               .hsize(ds_hsize),
               .hburst(ds_hburst),
               .hmastlock(ds_hmastlock),
               .hprot(ds_hprot),
               .htrans(ds_htrans),
               .hwdata(ds_hwdata),
               .hrdata(ds_hrdata),
               .hready(ds_hready),
               .hresp(ds_hresp)
               );

   uart uart(
             .hclk(clk),
             .hresetn(resetn),
//             .hsel(ss_hsel&~ss_haddr[4]),
             .hsel(1'b0),
             .haddr(ss_haddr),
             .hwrite(ss_hwrite),
             .hsize(ss_hsize),
             .hburst(ss_hburst),
             .hmastlock(ss_hmastlock),
             .hprot(ss_hprot),
             .htrans(ss_htrans),
             .hwdata(ss_hwdata),
//             .hrdata(ss_hrdata),
             .hrdata(),
             .hready(ss_hready),
             .hresp(ss_hresp),
             .RXD(RXD),
             .TXD(TXD)
             );

   uart_sim uart_sim(
             .hclk(clk),
             .hresetn(resetn),
//             .hsel(ss_hsel&ss_haddr[4]),
             .hsel(ss_hsel),
             .haddr(ss_haddr),
             .hwrite(ss_hwrite),
             .hsize(ss_hsize),
             .hburst(ss_hburst),
             .hmastlock(ss_hmastlock),
             .hprot(ss_hprot),
             .htrans(ss_htrans),
             .hwdata(ss_hwdata),
             .hrdata(ss_hrdata),
//             .hrdata(),
             .hready(),
             .hresp()
             );

endmodule // vscale_sim_top
