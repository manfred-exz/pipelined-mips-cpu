module pipeir(pc_plus_4, IF_inst, we, clk, clrn, ID_pc_plus_4, ID_inst);
	input	[31:0]	pc_plus_4, IF_inst;
	input			we, clk, clrn;
	output	[31:0] ID_pc_plus_4, ID_inst;

	dffe32 	pc_plus4(pc_plus_4, clk, clrn, we, ID_pc_plus_4);
	dffe32 instruction(IF_inst, clk, clrn, we, ID_inst);
endmodule
