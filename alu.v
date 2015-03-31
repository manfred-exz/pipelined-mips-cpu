module alu (a,b,aluc,r,z); 
	input [31:0] a,b; 									// aluc [3:0] 
	input [3:0] aluc; 									// 
	output [31:0] r; 									// X 0 0 0 ADD 
	output z; 											// X 1 0 0 SUB 
	wire [31:0] d_and = a & b; 							// X 0 0 1 AND 
	wire [31:0] d_or = a | b; 							// X 1 0 1 OR 
	wire [31:0] d_xor = a ^ b; 							// X 0 1 0 XOR 
	wire [31:0] d_lui = {b[15:0],16'h0};				// X 1 1 0 LUI 
	wire [31:0] d_and_or = aluc[2] ? d_or : d_and; 		// 0 0 1 1 SLL 
	wire [31:0] d_xor_lui = aluc[2] ? d_lui : d_xor; 	// 0 1 1 1 SRL 
	wire [31:0] d_as, d_sh; 							// 1 1 1 1 SRA 

	addsub32 as32 (a, b, aluc[2], d_as); 
	shift shifter (b, a[4:0], aluc[2], aluc[3], d_sh); 
	mux4x32 select (d_as, d_and_or, d_xor_lui, d_sh, aluc[1:0],r); 
	
	assign z = ~|r; 

endmodule
