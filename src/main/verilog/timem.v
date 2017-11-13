`include "vscale_hasti_constants.vh"
module timem
  (
   input                          clk,
   input [`HASTI_ADDR_WIDTH-1:0]  addr,
   input                          read,
   input                          write,
   input [`HASTI_SIZE_WIDTH-1:0]  size,
   input [`HASTI_BUS_WIDTH-1:0]   wdata,
   output [`HASTI_BUS_WIDTH-1:0]  rdata
   );

   reg [3:0]                      we;
   always @ (*) begin
      if(write)
        casez({size[2:0], addr[1:0]})
          5'b000_11 : we = 4'b1000;
          5'b000_10 : we = 4'b0100;
          5'b000_01 : we = 4'b0010;
          5'b000_00 : we = 4'b0001;
          5'b001_1? : we = 4'b1100;
          5'b001_0? : we = 4'b0011;
          5'b010_?? : we = 4'b1111;
          default   : we = 4'b1111;
        endcase
      else
        we = 4'b0000;
   end

   v_rams_20c ram0 (.clk(clk),
                    .we(we[0]),
                    .addr(addr[13:2]),
                    .din(wdata[7:0]),
                    .dout(rdata[7:0]));

   v_rams_21c ram1 (.clk(clk),
                    .we(we[1]),
                    .addr(addr[13:2]),
                    .din(wdata[15:8]),
                    .dout(rdata[15:8]));

   v_rams_22c ram2 (.clk(clk),
                    .we(we[2]),
                    .addr(addr[13:2]),
                    .din(wdata[23:16]),
                    .dout(rdata[23:16]));

   v_rams_23c ram3 (.clk(clk),
                    .we(we[3]),
                    .addr(addr[13:2]),
                    .din(wdata[31:24]),
                    .dout(rdata[31:24]));

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
