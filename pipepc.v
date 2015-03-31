module pipepc(npc, pc_we, clk, clrn, pc);
	input [31:0]	npc;
	input 			pc_we, clk, clrn;
	output [31:0] 	pc;

	dffe32 program_counter(npc, clk, clrn, pc_we, pc);
endmodule