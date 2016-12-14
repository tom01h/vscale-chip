`include "vscale_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"
`include "vscale_hasti_constants.vh"
`include "vscale_platform_constants.vh"

module vscale_sim_top(
                      input clk,
                      input reset
                      );

   wire                     resetn;

   assign resetn = ~reset;

   vscale_chip chip(
                    .clk(clk),
                    .rstn(~reset),
                    .RXD(),
                    .TXD()
                    );

endmodule // vscale_sim_top
