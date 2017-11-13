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

   wire [`HASTI_ADDR_WIDTH-1:0]  im_addr;
   wire                          im_read;
   wire                          im_write;
   wire [`HASTI_SIZE_WIDTH-1:0]  im_size;
   wire [`HASTI_BUS_WIDTH-1:0]   im_wdata;
   wire [`HASTI_BUS_WIDTH-1:0]   im_rdata;
   wire                          im_ready;
   wire [`HASTI_RESP_WIDTH-1:0]  im_resp;

   wire [`HASTI_ADDR_WIDTH-1:0]  dm_addr;
   wire                          dm_read;
   wire                          dm_write;
   wire [`HASTI_SIZE_WIDTH-1:0]  dm_size;
   wire [`HASTI_BUS_WIDTH-1:0]   dm_wdata;
   wire [`HASTI_BUS_WIDTH-1:0]   dm_rdata;
   wire                          dm_ready;
   wire [`HASTI_RESP_WIDTH-1:0]  dm_resp;

   wire                          is_sel;
   wire [`HASTI_ADDR_WIDTH-1:0]  is_addr;
   wire                          is_read;
   wire                          is_write;
   wire [`HASTI_SIZE_WIDTH-1:0]  is_size;
   wire [`HASTI_BUS_WIDTH-1:0]   is_wdata;
   wire [`HASTI_BUS_WIDTH-1:0]   is_rdata;

   wire                          ds_sel;
   wire [`HASTI_ADDR_WIDTH-1:0]  ds_addr;
   wire                          ds_read;
   wire                          ds_write;
   wire [`HASTI_SIZE_WIDTH-1:0]  ds_size;
   wire [`HASTI_BUS_WIDTH-1:0]   ds_wdata;
   wire [`HASTI_BUS_WIDTH-1:0]   ds_rdata;

   wire                          ss_sel;
   wire [`HASTI_ADDR_WIDTH-1:0]  ss_addr;
   wire                          ss_read;
   wire                          ss_write;
   wire [`HASTI_SIZE_WIDTH-1:0]  ss_size;
   wire [`HASTI_BURST_WIDTH-1:0] ss_burst;
   wire                          ss_mastlock;
   wire [`HASTI_PROT_WIDTH-1:0]  ss_prot;
   wire [`HASTI_BUS_WIDTH-1:0]   ss_wdata;
   wire [`HASTI_BUS_WIDTH-1:0]   ss_rdata;
   wire                          ss_ready;
   wire [`HASTI_RESP_WIDTH-1:0]  ss_resp;

   assign resetn = ~reset;

   vscale_core vscale(
                      .clk(clk),
                      .reset(reset),
                      .ext_interrupts(`N_EXT_INTS'b0),
                      .imem_addr(im_addr),
                      .imem_read(im_read),
                      .imem_write(im_write),
                      .imem_size(im_size),
                      .imem_wdata(im_wdata),
                      .imem_rdata(im_rdata),
                      .imem_ready(im_ready),
                      .imem_resp(im_resp),
                      .dmem_addr(dm_addr),
                      .dmem_read(dm_read),
                      .dmem_write(dm_write),
                      .dmem_size(dm_size),
                      .dmem_wdata(dm_wdata),
                      .dmem_rdata(dm_rdata),
                      .dmem_ready(dm_ready),
                      .dmem_resp(dm_resp)
                      );

   vscale_xbar vscale_xbar(
                           .clk(clk),
                           .resetn(resetn),

                           .im_addr(im_addr),
                           .im_read(im_read),
                           .im_write(im_write),
                           .im_size(im_size),
                           .im_wdata(im_wdata),
                           .im_rdata(im_rdata),
                           .im_ready(im_ready),
                           .im_resp(im_resp),

                           .dm_addr(dm_addr),
                           .dm_read(dm_read),
                           .dm_write(dm_write),
                           .dm_size(dm_size),
                           .dm_wdata(dm_wdata),
                           .dm_rdata(dm_rdata),
                           .dm_ready(dm_ready),
                           .dm_resp(dm_resp),

                           .is_sel(is_sel),
                           .is_addr(is_addr),
                           .is_read(is_read),
                           .is_write(is_write),
                           .is_size(is_size),
                           .is_wdata(is_wdata),
                           .is_rdata(is_rdata),
      
                           .ds_sel(ds_sel),
                           .ds_addr(ds_addr),
                           .ds_read(ds_read),
                           .ds_write(ds_write),
                           .ds_size(ds_size),
                           .ds_wdata(ds_wdata),
                           .ds_rdata(ds_rdata),
      
                           .ss_sel(ss_sel),
                           .ss_addr(ss_addr),
                           .ss_read(ss_read),
                           .ss_write(ss_write),
                           .ss_size(ss_size),
                           .ss_burst(ss_burst),
                           .ss_mastlock(ss_mastlock),
                           .ss_prot(ss_prot),
                           .ss_wdata(ss_wdata),
                           .ss_rdata(ss_rdata),
                           .ss_ready(ss_ready),
                           .ss_resp(ss_resp)
                           );

   timem imem(
               .clk(clk),
               .addr(is_addr),
               .read(is_read&is_sel),
               .write(is_write&is_sel),
               .size(is_size),
               .wdata(is_wdata),
               .rdata(is_rdata)
               );

   timem dmem(
               .clk(clk),
               .addr(ds_addr),
               .read(ds_read&ds_sel),
               .write(ds_write&ds_sel),
               .size(ds_size),
               .wdata(ds_wdata),
               .rdata(ds_rdata)
               );

   wire [`HASTI_BUS_WIDTH-1:0]   uart_rdata;
   wire [`HASTI_BUS_WIDTH-1:0]   uart_sim_rdata;
   reg                           uart_sel;
   always @ (posedge clk) //TEMP//TEMP//hready
     uart_sel <= ss_addr[4];
   assign ss_rdata = (uart_sel) ? uart_sim_rdata : uart_rdata ;

   uart uart(
             .clk(clk),
             .resetn(resetn),
             .addr(ss_addr),
             .read(ss_read&ss_sel&~ss_addr[4]),
             .write(ss_write&ss_sel&~ss_addr[4]),
             .size(ss_size),
             .burst(ss_burst),
             .mastlock(ss_mastlock),
             .prot(ss_prot),
             .wdata(ss_wdata),
             .rdata(uart_rdata),
             .ready(ss_ready),
             .resp(ss_resp),
             .RXD(RXD),
             .TXD(TXD)
             );

   uart_sim uart_sim(
             .clk(clk),
             .resetn(resetn),
             .addr(ss_addr),
             .read(ss_read&ss_sel&ss_addr[4]),
             .write(ss_write&ss_sel&ss_addr[4]),
             .size(ss_size),
             .burst(ss_burst),
             .mastlock(ss_mastlock),
             .prot(ss_prot),
             .wdata(ss_wdata),
             .rdata(uart_sim_rdata),
             .ready(),
             .resp()
             );

endmodule // vscale_sim_top
