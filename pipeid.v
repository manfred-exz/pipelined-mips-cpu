module pipeid(MEM_reg_we, MEM_reg_w_num, EXE_reg_w_num, EXE_reg_we, EXE_reg_w_src, MEM_reg_w_src, ID_pc_plus_4, inst, WB_reg_w_num, 
			WB_reg_w_data, EXE_alu, MEM_alu, MEM_mem_data, WB_reg_we, clk, clrn, branch_pc, jump_pc, pc_source,
			nostall, reg_we, reg_w_src, mem_we, aluc, alu_imm, a, b, imm, reg_w_num,
			shift, jal);

	input	[31:0] 	ID_pc_plus_4, inst, WB_reg_w_data, EXE_alu, MEM_alu, MEM_mem_data;
	input	[4:0] 	EXE_reg_w_num, MEM_reg_w_num, WB_reg_w_num;
	input			MEM_reg_we, EXE_reg_we, EXE_reg_w_src, MEM_reg_w_src, WB_reg_we;
	input			clk, clrn;

	output	[31:0] 	branch_pc, jump_pc, a, b, imm;
	output	[4:0]	reg_w_num;
	output	[3:0] 	aluc;
	output	[1:0]	pc_source;
	output 			nostall, reg_we, reg_w_src, mem_we, alu_imm, shift, jal;

	wire	[5:0]	op, func;
	wire	[4:0]	rs, rt, rd;
	wire 	[31:0]	qa,qb,br_offset;
	wire 	[15:0]	ext16;
	wire 	[1:0]	fwda, fwdb;
	wire			regrt, sext, rsrtequ, e;


	assign func = inst[5:0];
	assign op = inst[31:26];
	assign rs = inst[25:21];
	assign rt = inst[20:16];
	assign rd = inst[15:11];


	//set jump_pc to 0 when it's actually not jump instruction kind.
	assign jump_pc = {16{pc_source[1]}} & {ID_pc_plus_4[31:28], inst[25:0], 2'b00};	
	//	assign jump_pc = {ID_pc_plus_4[31:28], inst[25:0], 2'b00};

	pipeidcu cu(MEM_reg_we, MEM_reg_w_num, EXE_reg_w_num, EXE_reg_we, EXE_reg_w_src, MEM_reg_w_src, rsrtequ, func, 
				op, rs, rt, reg_we, reg_w_src, mem_we, aluc, regrt, alu_imm, 
				fwda, fwdb, nostall, sext, pc_source, shift, jal);
	regfile rf(rs, rt, WB_reg_w_data, WB_reg_w_num, WB_reg_we, ~clk, clrn, qa, qb);	//not sure about the ~ operator
	mux2x5	des_reg_no(rd, rt, regrt, reg_w_num);
	mux4x32 alu_a(qa, EXE_alu, MEM_alu, MEM_mem_data, fwda, a);
	mux4x32 alu_b(qb, EXE_alu, MEM_alu, MEM_mem_data, fwdb, b);

	assign rsrtequ = ~|(a^b);	// rsrtequ = (a == b)
	assign e = sext & inst[15];	
	assign ext16 = {16{e}};
	assign imm = {ext16, inst[15:0]};
	assign br_offset = {imm[29:0], 2'b00};
	cla32 br_addr(ID_pc_plus_4, br_offset, 1'b0, branch_pc);	//branch pc

endmodule
