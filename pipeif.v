module pipeif(pc_source, pc, branch_pc, register_pc, jump_pc, next_pc, pc_plus_4, inst);
	input	[31:0]	pc, branch_pc, register_pc, jump_pc;
	input	[1:0]	pc_source;

	output	[31:0]	next_pc, pc_plus_4, inst;

	mux4x32 update_next_pc(pc_plus_4, branch_pc, register_pc, jump_pc, pc_source, next_pc);
	cla32 pc_plus4(pc, 32'h4, 1'b0, pc_plus_4);
	pipeimem inst_mem(pc, inst);

endmodule
