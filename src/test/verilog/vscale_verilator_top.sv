`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"

module vscale_verilator_top(
                            input                        clk,
                            input                        reset
                            );

   localparam hexfile_words = 8192;

   reg [  63:0]               max_cycles;
   reg [  63:0]               trace_count;
   reg [255:0]                reason;
   reg [1023:0]               loadmem;
   integer                    stderr = 32'h80000002;

   reg [127:0]                hexfile [hexfile_words-1:0];

   vscale_sim_top DUT(
                      .clk(clk),
                      .reset(reset)
                      );

   reg                        dmy;
   
   initial begin
      reason = 0;
      max_cycles = 0;
      trace_count = 0;
      dmy = $value$plusargs("max-cycles=%d", max_cycles);
   end // initial begin

   reg htif_pcr_resp_valid;
   reg [`HTIF_PCR_WIDTH-1:0] htif_pcr_resp_data;

   always @(posedge clk)
     htif_pcr_resp_valid <= DUT.chip.vscale.dmem_en & (DUT.chip.vscale.dmem_addr == 32'h00001000)& DUT.chip.vscale.dmem_wen;
   always @ (DUT.chip.vscale.dmem_wdata_delayed)
     htif_pcr_resp_data = DUT.chip.vscale.dmem_wdata_delayed;

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
