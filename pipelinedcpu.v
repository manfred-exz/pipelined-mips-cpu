module pipelinedcpu(clock, memclock, resetn, pc, inst, EXE_alu, MEM_alu, WB_alu);
	input clock, memclock, resetn;
	output [31:0] pc, inst, EXE_alu, MEM_alu, WB_alu;	//exe_alu, mem_alu, wb_alu

	wire [31:0] branch_pc, jump_pc, next_pc, pc_plus_4, ID_pc_plus_4, IF_inst, ID_inst,
				 ID_a, ID_b, ID_imm, EXE_a, EXE_b, EXE_imm;

	wire [31:0] epc_plus_4, MEM_b, MEM_mem_data, WB_mem_data, WB_reg_w_data;		//???

	//register number to write, NOTE that EXE_reg_w_num_jal take jal instruction into consideration, while EXE_reg_w_num doesn't.
	wire [4:0]	ID_reg_w_num, EXE_reg_w_num_jal, EXE_reg_w_num, MEM_reg_w_num, WB_reg_w_num;		
	wire [3:0]	ID_aluc, EXE_aluc;					//alu controller
	wire [1:0] 	pc_source;
	wire pc_we;									//wb_pc_ir
	wire ID_reg_we, ID_reg_w_src, ID_mem_we, ID_alu_imm, ID_shift, ID_jal;		//control signal at ID stage
	wire EXE_reg_we, EXE_reg_w_src, EXE_mem_we, EXE_alu_imm, EXE_shift, EXE_jal;		//control signal at EXE stage
	wire MEM_reg_we, MEM_reg_w_src, MEM_mem_we;								//control signal at MEM stage
	wire WB_reg_we, WB_reg_w_src;										//control signal at WB stage
	
	wire [31:0] inst = IF_inst;

	pipepc prog_cnt(next_pc, pc_we, clock, resetn, pc);

	// instruction fetch stage 				// INPUT
	pipeif if_stage(.pc_source(pc_source),	
					.pc(pc),
					.branch_pc(branch_pc),
					.register_pc(ID_a),
					.jump_pc(jump_pc),
											// OUTPUT
					.next_pc(next_pc),
					.pc_plus_4(pc_plus_4),
					.inst(IF_inst)
					);

	pipeir in_streg(.pc_plus_4(pc_plus_4),
					.IF_inst(IF_inst),
					.we(pc_we),
					.clk(clock),
					.clrn(resetn),
											// OUTPUT
					.ID_pc_plus_4(ID_pc_plus_4),
					.ID_inst(ID_inst)
					);


	pipeid id_stage(.MEM_reg_we(MEM_reg_we),
					.MEM_reg_w_num(MEM_reg_w_num),
					.EXE_reg_w_num(EXE_reg_w_num),
					.EXE_reg_we(EXE_reg_we),
					.EXE_reg_w_src(EXE_reg_w_src),
					.MEM_reg_w_src(MEM_reg_w_src),
					.ID_pc_plus_4(ID_pc_plus_4),
					.inst(ID_inst),
					.WB_reg_w_num(WB_reg_w_num),
					.WB_reg_w_data(WB_reg_w_data),
					.EXE_alu(EXE_alu),
					.MEM_alu(MEM_alu),
					.MEM_mem_data(MEM_mem_data),
					.WB_reg_we(WB_reg_we),
					.clk(clock),
					.clrn(resetn), 
											// OUTPUT
					.branch_pc(branch_pc),
					.jump_pc(jump_pc),
					.pc_source(pc_source),
					.nostall(pc_we),
					.reg_we(ID_reg_we),
					.reg_w_src(ID_reg_w_src),
					.mem_we(ID_mem_we),
					.aluc(ID_aluc),
					.alu_imm(ID_alu_imm),
					.a(ID_a),
					.b(ID_b),
					.imm(ID_imm),
					.reg_w_num(ID_reg_w_num),
					.shift(ID_shift),
					.jal(ID_jal)
					);




	pipedereg de_reg(ID_reg_we, ID_reg_w_src, ID_mem_we, ID_aluc, ID_alu_imm, ID_a, ID_b, ID_imm,
					ID_reg_w_num, ID_shift, ID_jal, ID_pc_plus_4, clock, resetn, 
					EXE_reg_we, EXE_reg_w_src, EXE_mem_we, EXE_aluc, EXE_alu_imm, EXE_a, EXE_b, EXE_imm,
					EXE_reg_w_num_jal, EXE_shift, EXE_jal, epc_plus_4);

	pipeexe	exe_stage(EXE_aluc, EXE_alu_imm, EXE_a, EXE_b, EXE_imm, EXE_shift, EXE_reg_w_num_jal, epc_plus_4, EXE_jal, EXE_reg_w_num, EXE_alu);

	pipeemreg em_reg(EXE_reg_we, EXE_reg_w_src, EXE_mem_we, EXE_alu, EXE_b, EXE_reg_w_num, clock, resetn,
					MEM_reg_we, MEM_reg_w_src, MEM_mem_we, MEM_alu, MEM_b, MEM_reg_w_num);

	pipemem mem_stage(MEM_mem_we, MEM_alu, MEM_b, clock, memclock, memclock, MEM_mem_data);

	pipemwreg mw_reg(MEM_reg_we, MEM_reg_w_src, MEM_mem_data, MEM_alu, MEM_reg_w_num, clock, resetn, 
					WB_reg_we, WB_reg_w_src, WB_mem_data, WB_alu, WB_reg_w_num);
	
	mux2x32 wb_stage(WB_alu, WB_mem_data, WB_reg_w_src, WB_reg_w_data);
endmodule
