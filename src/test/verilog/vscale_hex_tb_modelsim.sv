`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"

module vscale_hex_tb();

   localparam hexfile_words = 8192;

   reg clk;
   reg reset;

   reg [255:0]                reason = 0;
   reg [1023:0]               loadmem = 0;
   reg [1023:0]               vpdfile = 0;
   reg [  63:0]               max_cycles = 0;
   reg [  63:0]               trace_count = 0;
   integer                    stderr = 32'h80000002;

   reg [127:0]                hexfile [hexfile_words-1:0];

   vscale_sim_top DUT(
                      .clk(clk),
                      .reset(reset)
                      );

   initial begin
      clk = 0;
      reset = 1;
   end

   always #5 clk = !clk;

   int            fd, i;
   string         str, data;
   int            bytec, rtype;
   logic [15:0]   addr;
   logic [31:0]   op;

   initial begin
      fd = $fopen("loadmem.ihex","r");
      if(fd==0) begin
         $display("ERROR!! loadmem.ihex not found");
         $stop;
      end
      $display("Loading Program");
      while($fgets(str, fd)) begin
         void'($sscanf(str, ":%02h%04h%02h%s", bytec, addr, rtype, data));
         if (rtype==0 &&
             (bytec == 16 || bytec == 12 || bytec == 8 || bytec == 4)) begin
            for (i=0; i<bytec/4; i = i+1) begin
               void'($sscanf(data, "%08h%s", op, str));
               DUT.chip.imem.ram0.ram[addr/4+i] = op[31:24];
               DUT.chip.imem.ram1.ram[addr/4+i] = op[23:16];
               DUT.chip.imem.ram2.ram[addr/4+i] = op[15:8];
               DUT.chip.imem.ram3.ram[addr/4+i] = op[7:0];
               data = str;
            end
         end else if ((rtype==4)|(rtype==5)) begin
         end else if (rtype==1) begin
            $display("Running ...");
         end else begin
            $display("ERROR!! Not support ihex format");
            $display(str);
            $stop;
         end
      end
      #100 reset = 0;
   end

   reg htif_pcr_resp_valid;
   reg [`HTIF_PCR_WIDTH-1:0] htif_pcr_resp_data;

   always @(posedge clk)begin
      htif_pcr_resp_valid <= DUT.chip.vscale.dmem_write & (DUT.chip.vscale.dmem_addr == 32'h00001000);
      htif_pcr_resp_data <= DUT.chip.vscale.dmem_wdata;
   end

   always @(posedge clk) begin
      trace_count = trace_count + 1;

      if (max_cycles > 0 && trace_count > max_cycles)
        reason = "timeout";

      if (!reset) begin
         if (htif_pcr_resp_valid && htif_pcr_resp_data != 0) begin
            if (htif_pcr_resp_data == 1) begin
               $display("*** PASSED *** after %d simulation cycles", trace_count);
               $finish;
            end else begin
               $sformat(reason, "tohost = %d", htif_pcr_resp_data >> 1);
            end
         end
      end


      if (reason) begin
         $display("*** FAILED *** (%s) after %d simulation cycles", reason, trace_count);
         $finish;
      end
   end

endmodule // vscale_hex_tb

