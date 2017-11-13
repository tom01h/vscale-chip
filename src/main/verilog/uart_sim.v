`include "vscale_hasti_constants.vh"

module uart_sim
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
   output                            resp
   );

   reg                               sel;
   reg [3:2]                         address;
   reg [3:0]                         be;
   reg [31:0]                        d;
   reg                               wr;

   reg [1:0]                         cnt;

   assign ready = 1'b1;
   assign resp = 1'b0;

   always @(posedge clk) begin
      if(read|write)
        if((addr[3:2]==2'b01) & read)
          if(cnt!=0)
            cnt <= cnt-1;
          else
            cnt <= 0;
        else
          cnt <= 3;
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
   reg [7:0] dout_o;
   wire      full_o = 1'b0;
   reg       empty_o;
   
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
//      else if (sel & wr & be[0] & address[3:2] == 2'b10)
//        din_i[7:0] <= d[7:0];

      if (~resetn) begin
         empty_o = 1'b1;
         dout_o = 8'h00;
      end else if (sel & wr & be[0] & address[3:2] == 2'b11) begin //DUMMY//DUMMY//
         empty_o = 1'b0;
         dout_o = d[7:0];
      end else if (sel & ~wr & be[0] & address[3:2] == 2'b10) begin
         empty_o = 1'b1;
      end
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

endmodule
