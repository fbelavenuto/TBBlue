//
// TBBlue / ZX Spectrum Next project
// Copyright (c) 2015 - Fabio Belavenuto & Victor Trucco
//
// All rights reserved
//
// Redistribution and use in source and synthezised forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in synthesized form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// Neither the name of the author nor the names of other contributors may
// be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// You are responsible for any legal issues arising from your use of this code.
//

module dp_memory 
(
    input wire clk,  // 28MHz
    input wire [18:0] a1,
    input wire [18:0] a2,
    input wire oe1_n,
    input wire oe2_n,
    input wire we1_n,
    input wire we2_n,
    input wire [7:0] din1,
    input wire [7:0] din2,
    output wire [7:0] dout1,
    output wire [7:0] dout2,
    
    output wire [17:0] sram_a_o,
    inout wire [15:0] sram_d_io,
    output reg sram_ce_n_o,
    output reg sram_oe_n_o,
    output reg sram_we_n_o,
	output wire sram_ub_o,
	output wire sram_lb_o
);

   parameter
		ACCESO_M1 = 1,
		READ_M1   = 2,
		WRITE_M1  = 3,
		ACCESO_M2 = 4,
		READ_M2   = 5,
		WRITE_M2  = 6;		

    reg [7:0] data_to_write;
	reg enable_input_to_sram;
	
	reg [18:0] sram_a_s;
	reg [7:0] doutput1;
	reg [7:0] doutput2;
	reg write_in_dout1;
	reg write_in_dout2;

	reg [2:0] state = ACCESO_M1;
	reg [2:0] next_state;
	
	always @(posedge clk) begin
		state <= next_state;
	end

	always @* begin
		sram_a_s = 0;
		sram_oe_n_o = 0;
		sram_we_n_o = 1;
		sram_ce_n_o = 0;
		enable_input_to_sram = 0;
		next_state = ACCESO_M1;
		data_to_write = 8'h00;
		write_in_dout1 = 0;
		write_in_dout2 = 0;
		
		case (state)
			ACCESO_M1: begin
					 		 sram_a_s = a1;
							 if (we1_n == 1) begin	
									
								write_in_dout1 = 1;							 
								 next_state = ACCESO_M2;
							 end
							 else begin
								 sram_oe_n_o = 1;
								 enable_input_to_sram = 1;
								data_to_write = din1;
								sram_oe_n_o = 1;
								sram_we_n_o = 0;
								 next_state = ACCESO_M2;
							 end
						  end
						  
	//		READ_M1:   begin
	//						if (we1_n == 1) begin
	//							sram_a_s = a1;
	//							write_in_dout1 = 1;
	//						  end
	//						next_state = ACCESO_M2;
	//					  end
	//					  
	//		WRITE_M1:  begin
    //                  if (we1_n == 0) begin
 	//		               sram_a_s = a1;
    //                    enable_input_to_sram = 1;
    //                    data_to_write = din1;
    //                    sram_oe_n_o = 1;
    //                    sram_we_n_o = 0;
    //                  end
	//						 next_state = ACCESO_M2;
	//					  end
	
			ACCESO_M2: begin
							 sram_a_s = a2;
							 if (we2_n == 1) begin
								write_in_dout2 = 1;
							    next_state = ACCESO_M1;
							 end
							 else begin
								 sram_a_s = a2;
								enable_input_to_sram = 1;
								data_to_write = din2;
								sram_oe_n_o = 1;
								sram_we_n_o = 0;
								 next_state = ACCESO_M1;
							 end
						  end
		//	READ_M2:   begin
        //              if (we2_n == 1) begin
        //                sram_a_s = a2;
        //                write_in_dout2 = 1;
        //              end
        //              next_state = ACCESO_M1;
		//				  end
		//	WRITE_M2:  begin
        //              if (we2_n == 0) begin
        //                sram_a_s = a2;
        //                enable_input_to_sram = 1;
        //                data_to_write = din2;
        //                sram_oe_n_o = 1;
        //                sram_we_n_o = 0;
        //              end
		//					 next_state = ACCESO_M1;
		//				  end
       endcase
	 end

    // assign sram_d_io = (enable_input_to_sram)? data_to_write : 8'hZZ;
	  assign sram_d_io = ( sram_a_s[0] == 1'b0 && enable_input_to_sram ) ? { 8'hZZ, data_to_write } : ( sram_a_s[0] == 1'b1 && enable_input_to_sram ) ? { data_to_write, 8'hZZ } :  16'hZZ;
	//  assign sram_d_io = ( sram_a_s[0] == 1'b0 ) ? { 8'hZZ, data_to_write } : { data_to_write, 8'hZZ };
	 
	 assign dout1 = (oe1_n)? 8'hZZ : doutput1;
	 assign dout2 = (oe2_n)? 8'hZZ : doutput2;
	 assign sram_a_o = sram_a_s[18:1];
	 assign sram_ub_o = !sram_a_s[0];		// UB = 0 ativa bits 15..8
	 assign sram_lb_o = sram_a_s[0];			// LB = 0 ativa bits 7..0
	 
	 always @(posedge clk) begin
	 
		if (write_in_dout1) begin
		
			if (sram_a_s[0] == 1'b0) begin
				doutput1 <= sram_d_io[7:0];
			end
			else begin
				doutput1 <= sram_d_io[15:8];
			end
			
		end
		else if (write_in_dout2) begin
		
			if (sram_a_s[0] == 1'b0) begin
				doutput2 <= sram_d_io[7:0];
			end
			else begin
				doutput2 <= sram_d_io[15:8];
			end
			
		end 
	
	end
		
		


endmodule
