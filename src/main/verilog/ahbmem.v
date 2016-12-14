`include "vscale_hasti_constants.vh"
module ahbmem
  (
   input                          hclk,
   input                          hresetn,
   input                          hsel,
   input [`HASTI_ADDR_WIDTH-1:0]  haddr,
   input                          hwrite,
   input [`HASTI_SIZE_WIDTH-1:0]  hsize,
   input [`HASTI_BURST_WIDTH-1:0] hburst,
   input                          hmastlock,
   input [`HASTI_PROT_WIDTH-1:0]  hprot,
   input [`HASTI_TRANS_WIDTH-1:0] htrans,
   input [`HASTI_BUS_WIDTH-1:0]   hwdata,
   output [`HASTI_BUS_WIDTH-1:0]  hrdata,
   output                         hready,
   output                         hresp
   );

   assign hready = 1'b1;
   assign hresp  = 1'b0;

   reg                            cs_i;
   reg [13:2]                     addr_h;
   reg [3:0]                      we_h;
   reg [31:0]                     wdata_h;
   reg                            wd;

   always @ (posedge hclk) begin
      if(~hresetn) begin
         we_h <= 4'b0000;
         wd <= 1'b0;
      end else if(cs_i&hwrite) begin
         casez({hsize[2:0], haddr[1:0]})
           5'b000_11 : we_h <= 4'b1000;
           5'b000_10 : we_h <= 4'b0100;
           5'b000_01 : we_h <= 4'b0010;
           5'b000_00 : we_h <= 4'b0001;
           5'b001_1? : we_h <= 4'b1100;
           5'b001_0? : we_h <= 4'b0011;
           5'b010_?? : we_h <= 4'b1111;
           default   : we_h <= 4'b1111;
         endcase
         addr_h <= haddr[13:2];
         wd <= 1'b1;
      end else if(~cs_i) begin
         we_h <= 4'b0000;
         wd <= 1'b0;
      end else begin
         wd <= 1'b0;
      end
      if(wd) begin
         wdata_h <= hwdata;
      end
   end

   reg                            cs;
   reg [13:2]                     addr;
   reg [3:0]                      we;
   reg [31:0]                     wdata;
   wire [31:0]                    q;

   always @ (*) begin
      cs_i = (htrans == `HASTI_TRANS_NONSEQ) & hsel;
      cs = (cs_i & ~hwrite) | (|we_h);
      if (~(cs_i & ~hwrite) & (|we_h)) begin
         addr = addr_h[13:2];
         we = we_h;
      end else begin
         addr = haddr[13:2];
         we = 4'b0000;
      end
      if(wd)
        wdata = hwdata;
      else
        wdata = wdata_h;
   end

   reg [3:0]                      hit;

   always @ (posedge hclk) begin
      if(~hresetn)
        hit <= 4'h0;
      else
        hit <= {4{cs_i & ~hwrite & (addr==addr_h)}} & we_h;
   end

   assign hrdata[ 7: 0] = (hit[0]) ? wdata_h[ 7: 0] : q[ 7: 0];
   assign hrdata[15: 8] = (hit[1]) ? wdata_h[15: 8] : q[15: 8];
   assign hrdata[23:16] = (hit[2]) ? wdata_h[23:16] : q[23:16];
   assign hrdata[31:24] = (hit[3]) ? wdata_h[31:24] : q[31:24];

   v_rams_20c ram0 (.clk(hclk),
                    .we(we[0]),
                    .addr(addr[13:2]),
                    .din(wdata[7:0]),
                    .dout(q[7:0]));

   v_rams_21c ram1 (.clk(hclk),
                    .we(we[1]),
                    .addr(addr[13:2]),
                    .din(wdata[15:8]),
                    .dout(q[15:8]));

   v_rams_22c ram2 (.clk(hclk),
                    .we(we[2]),
                    .addr(addr[13:2]),
                    .din(wdata[23:16]),
                    .dout(q[23:16]));

   v_rams_23c ram3 (.clk(hclk),
                    .we(we[3]),
                    .addr(addr[13:2]),
                    .din(wdata[31:24]),
                    .dout(q[31:24]));

endmodule

module v_rams_20c (clk, we, addr, din, dout);
   input clk;
   input we;
   input [11:0] addr;
   input [7:0] din;
   output [7:0] dout;
   reg [7:0]    ram [0:4095];
   reg [7:0]    dout;
   initial
     begin
        $readmemh("ram.data0",ram);
     end
   always @(posedge clk)
     begin
        if (we)
          ram[addr] <= din;
        dout <= ram[addr];
     end
endmodule

module v_rams_21c (clk, we, addr, din, dout);
   input clk;
   input we;
   input [11:0] addr;
   input [7:0] din;
   output [7:0] dout;
   reg [7:0]    ram [0:4095];
   reg [7:0]    dout;
   initial
     begin
        $readmemh("ram.data1",ram);
     end
   always @(posedge clk)
     begin
        if (we)
          ram[addr] <= din;
        dout <= ram[addr];
     end
endmodule

module v_rams_22c (clk, we, addr, din, dout);
   input clk;
   input we;
   input [11:0] addr;
   input [7:0] din;
   output [7:0] dout;
   reg [7:0]    ram [0:4095];
   reg [7:0]    dout;
   initial
     begin
        $readmemh("ram.data2",ram);
     end
   always @(posedge clk)
     begin
        if (we)
          ram[addr] <= din;
        dout <= ram[addr];
     end
endmodule

module v_rams_23c (clk, we, addr, din, dout);
   input clk;
   input we;
   input [11:0] addr;
   input [7:0] din;
   output [7:0] dout;
   reg [7:0]    ram [0:4095];
   reg [7:0]    dout;
   initial
     begin
        $readmemh("ram.data3",ram);
     end
   always @(posedge clk)
     begin
        if (we)
          ram[addr] <= din;
        dout <= ram[addr];
     end
endmodule
