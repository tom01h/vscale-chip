// 4'h0 Baud Rate
//      [15:8] div1
//      [7:0]  div0
//      9600bps @ 50MHz
//      50MHz/9600/4 = 1302 = 20*65 = (div0+2) * div1
//      div1=65, div0=18
// 4'h4 Status
//      [1] TXF (TX Full)
//      [0] RXE (RX Empty)
// 4'h8 Data
//      [7:0] Data

`include "vscale_hasti_constants.vh"

module uart
  (
   input                             hclk,
   input                             hresetn,
   input                             hsel,
   input [`HASTI_ADDR_WIDTH-1:0]     haddr,
   input                             hwrite,
   input [`HASTI_SIZE_WIDTH-1:0]     hsize,
   input [`HASTI_BURST_WIDTH-1:0]    hburst,
   input                             hmastlock,
   input [`HASTI_PROT_WIDTH-1:0]     hprot,
   input [`HASTI_TRANS_WIDTH-1:0]    htrans,
   input [`HASTI_BUS_WIDTH-1:0]      hwdata,
   output reg [`HASTI_BUS_WIDTH-1:0] hrdata,
   output                            hready,
   output                            hresp,
   input                             RXD,
   output                            TXD
   );

   reg                               sel;
   reg [3:2]                         address;
   reg [3:0]                         be;
   reg [31:0]                        d;
   reg                               wr;

   assign hready = 1'b1;
   assign hresp = 1'b0;

   always @(posedge hclk) begin
      sel     <= (htrans == `HASTI_TRANS_NONSEQ) & hsel;
      address <=  haddr[3:2];
      casez({hsize[2:0], haddr[1:0]})
        5'b000_11 : be <= 4'b1000;
        5'b000_10 : be <= 4'b0100;
        5'b000_01 : be <= 4'b0010;
        5'b000_00 : be <= 4'b0001;
        5'b001_1? : be <= 4'b1100;
        5'b001_0? : be <= 4'b0011;
        5'b010_?? : be <= 4'b1111;
        default   : be <= 4'b1111;
      endcase
      wr      <= hwrite;
   end
   always @(*) begin
      d        = hwdata;
   end

   reg [7:0] div0, div1, din_i;
   wire [7:0] dout_o;
   wire      full_o,empty_o;
   
   always @(posedge hclk) begin
      if (~hresetn)
        div0[7:0] <= 8'h00;
      else if (sel & wr & be[0] & address[3:2] == 2'b00)
        div0[7:0] <= d[7:0];
      if (~hresetn)
        div1[7:0] <= 8'h00;
      else if (sel & wr & be[1] & address[3:2] == 2'b00)
        div1[7:0] <= d[15:8];
//      if (~hresetn)
//        din_i[7:0] <= 8'h00;
//      else if (sel & wr & be[1] & address[3:2] == 2'b00)
//        din_i[7:0] <= d[7:0];
   end
   always @(*) begin
      din_i[7:0] <= d[7:0];
   end
   always @(*) begin
      case(address[3:2])
        2'b00 : hrdata = {{16{1'b0}},div1,div0};
        2'b01 : hrdata = {{24{1'b0}},6'h00,full_o,empty_o};
        2'b10 : hrdata = {{24{1'b0}},dout_o};
        default : hrdata = {32{1'bx}};
      endcase
   end   

   wire re_i = sel & ~wr & (address[3:2] == 2'b10);
   wire we_i = sel &  wr & (address[3:2] == 2'b10) & be[0];
   
// sasc from cpen core
   wire sio_ce, sio_ce_x4;
   
   sasc_top top
     (
      .clk(hclk),
      .rst(hresetn),
      .rxd_i(RXD),
      .txd_o(TXD),
      .cts_i(1'b0),
      .rts_o(),
      .sio_ce(sio_ce),
      .sio_ce_x4(sio_ce_x4),
      .din_i(din_i),
      .dout_o(dout_o),
      .re_i(re_i),
      .we_i(we_i),
      .full_o(full_o),
      .empty_o(empty_o)
      );

   sasc_brg brg
     (
      .clk(hclk),
      .rst(hresetn),
      .div0(div0),
      .div1(div1),
      .sio_ce(sio_ce),
      .sio_ce_x4(sio_ce_x4)
      );
endmodule
