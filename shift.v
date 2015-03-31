module shift (d,sa,right,arith,sh); 

	input [31:0] d; 
	input [4:0] sa; 
	input right,arith;
	output [31:0] sh; 	
	reg [31:0] sh; 
	always @* begin
		if (!right) begin 			// shift left
			sh = d << sa;
		end else if (!arith) begin 	// shift right logical 
			sh = d >> sa;
		end else begin 				// shift right arithmetic
			sh = $signed(d) >>> sa;
		end
	end
endmodule
