module pipeexe(EXE_aluc, EXE_alu_imm, EXE_a, EXE_b, EXE_imm, EXE_shift, EXE_reg_w_num_jal, EXE_pc_plus_4, EXE_jal, EXE_reg_w_num, EXE_alu);

	input	[31:0]	EXE_a, EXE_b, EXE_imm, EXE_pc_plus_4;
	input	[4:0]	EXE_reg_w_num_jal;
	input 	[3:0] 	EXE_aluc;
	input			EXE_alu_imm, EXE_shift, EXE_jal;

	output	[31:0] 	EXE_alu;
	output 	[4:0]	EXE_reg_w_num;

	wire	[31:0]	alu_a, alu_b, sa, EXE_alu_res, EXE_pc_plus_8;
	wire			z;

	assign sa = {EXE_imm[5:0], EXE_imm[31:6]};	//shift amount, TODO:好像有哪里不太对..
	cla32	ret_addr(EXE_pc_plus_4, 32'h4, 1'b0, EXE_pc_plus_8);
	// pick a source for alu.input.a: whether to "shift"
	mux2x32	alu_ina(EXE_a, sa, EXE_shift, alu_a);
	// pick a source for alu.input.b: whether to "imm" 
	mux2x32	alu_inb(EXE_b, EXE_imm, EXE_alu_imm, alu_b);
	// pick a source for alu.output.res: whether to jal
	mux2x32 save_pc8(EXE_alu_res, EXE_pc_plus_8, EXE_jal, EXE_alu);
	assign EXE_reg_w_num = EXE_reg_w_num_jal | {5{EXE_jal}};

	alu al_unit(alu_a, alu_b, EXE_aluc, EXE_alu_res, z);

endmodule

