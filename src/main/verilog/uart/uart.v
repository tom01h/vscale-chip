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
   input                             clk,
   input                             resetn,
   input [`HASTI_ADDR_WIDTH-1:0]     addr,
   input                             read,
   input                             write,
   input [`HASTI_SIZE_WIDTH-1:0]     size,
   input [`HASTI_BURST_WIDTH-1:0]    burst,
   input                             mastlock,
   input [`HASTI_PROT_WIDTH-1:0]     prot,
   input [`HASTI_BUS_WIDTH-1:0]      wdata,
   output reg [`HASTI_BUS_WIDTH-1:0] rdata,
   output                            ready,
   output                            resp,
   input                             RXD,
   output                            TXD
   );

   reg                               sel;
   reg [3:2]                         address;
   reg [3:0]                         be;
   reg [31:0]                        d;
   reg                               wr;

   assign ready = 1'b1;
   assign resp = 1'b0;

   always @(posedge clk) begin
      sel     <= (read|write);
      address <=  addr[3:2];
      casez({size[2:0], addr[1:0]})
        5'b000_11 : be <= 4'b1000;
        5'b000_10 : be <= 4'b0100;
        5'b000_01 : be <= 4'b0010;
        5'b000_00 : be <= 4'b0001;
        5'b001_1? : be <= 4'b1100;
        5'b001_0? : be <= 4'b0011;
        5'b010_?? : be <= 4'b1111;
        default   : be <= 4'b1111;
      endcase
      wr      <= write;
      d       <= wdata;
   end

   reg [7:0] div0, div1, din_i;
   wire [7:0] dout_o;
   wire      full_o,empty_o;
   
   always @(posedge clk) begin
      if (~resetn)
        div0[7:0] <= 8'h00;
      else if (sel & wr & be[0] & address[3:2] == 2'b00)
        div0[7:0] <= d[7:0];

      if (~resetn)
        div1[7:0] <= 8'h00;
      else if (sel & wr & be[1] & address[3:2] == 2'b00)
        div1[7:0] <= d[15:8];

//      if (~resetn)
//        din_i[7:0] <= 8'h00;
//      else if (sel & wr & be[1] & address[3:2] == 2'b00)
//        din_i[7:0] <= d[7:0];
   end
   always @(*) begin
      din_i[7:0] <= d[7:0];
   end
   always @(*) begin
      case(address[3:2])
        2'b00 : rdata = {{16{1'b0}},div1,div0};
        2'b01 : rdata = {{24{1'b0}},6'h00,full_o,empty_o};
        2'b10 : rdata = {{24{1'b0}},dout_o};
        default : rdata = {32{1'bx}};
      endcase
   end   

   wire re_i = sel & ~wr & (address[3:2] == 2'b10);
   wire we_i = sel &  wr & (address[3:2] == 2'b10) & be[0];
   
// sasc from cpen core
   wire sio_ce, sio_ce_x4;
   
   sasc_top top
     (
      .clk(clk),
      .rst(resetn),
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
      .clk(clk),
      .rst(resetn),
      .div0(div0),
      .div1(div1),
      .sio_ce(sio_ce),
      .sio_ce_x4(sio_ce_x4)
      );
endmodule
