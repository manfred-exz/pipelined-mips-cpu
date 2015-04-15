module pipeidcu(mwreg, mrn, ern, ewreg, em2reg, mm2reg, rsrtequ, func, op, rs, rt,
				wreg, m2reg, wmem, aluc, regrt, aluimm, fwda, fwdb, nostall, sext, 
				pcsource, shift, jal);
	input	mwreg, ewreg, em2reg, mm2reg, rsrtequ;
	input	[4:0]	mrn, ern, rs, rt;
	input	[5:0]	func, op;

	output			wreg, m2reg, wmem, regrt, aluimm, sext, shift, jal;
	output 	[3:0]	aluc;
	output	[1:0]	pcsource;
	output 			fwda, fwdb;	//forwarding
	output			nostall;	//stall pipeline due to lw dependent

	reg 	[1:0]	fwda, fwdb;

	wire r_type = (op == 0);
	// instruction decode
	wire i_add  = (r_type == 1) & (func == 6'h20);  // add
	wire i_sub  = (r_type == 1) & (func == 6'h22);  // sub
	wire i_and  = (r_type == 1) & (func == 6'h24);  // and
	wire i_or   = (r_type == 1) & (func == 6'h25);  // or
	wire i_xor  = (r_type == 1) & (func == 6'h26);  // xor
	wire i_sll  = (r_type == 1) & (func == 6'h00);  // sll
	wire i_srl  = (r_type == 1) & (func == 6'h02);  // srl
	wire i_sra  = (r_type == 1) & (func == 6'h03);  // sra
	wire i_jr   = (r_type == 1) & (func == 6'h08);  // jr
	wire i_addi = (op == 6'h08);                    // addi
	wire i_andi = (op == 6'h0c);                    // andi
	wire i_ori  = (op == 6'h0d);                    // ori
	wire i_xori = (op == 6'h0e);                    // xori
	wire i_lw   = (op == 6'h23);                    // lw
	wire i_sw   = (op == 6'h2b);                    // sw
	wire i_beq  = (op == 6'h04);                    // beq
	wire i_bne  = (op == 6'h05);                    // bne
	wire i_lui  = (op == 6'h0f);                    // lui
	wire i_j    = (op == 6'h02);                    // j
	wire i_jal  = (op == 6'h03);                    // jal
	
	//my extra instructions, REMEMBER to UPDATE the INFOs below when new instructions are added.
	//TODO: INFOs NOT fully updated now for extra inst.
	wire i_slt  = (r_type == 1) & (func == 6'h2a);	//slt
	wire i_slti = (op == 6'h0a);					//slti
	wire i_addiu= (op == 6'h09);
	wire i_addu = (r_type == 1) & (func == 6'h21);	//addu
	wire i_lx = i_lb|i_lbu|i_lw;
	wire i_lb	= (op == 6'h20);					//lb
	wire i_lbu	= (op == 6'h24);					//lbu
	
	wire i_rs = i_add | i_sub | i_and | i_or | i_xor |i_jr | i_addi |
				i_andi| i_ori | i_xori| i_lw | i_sw  |i_beq| i_bne;
	wire i_rt = i_add | i_sub | i_and | i_or  |i_xor  |i_sll| i_srl  |
				i_sra | i_sw  | i_beq | i_bne;

	//controls
	assign wreg = (	i_add | i_sub | i_and | i_or | i_xor | i_sll | 
					i_srl | i_sra | i_addi| i_andi|i_ori | i_xori|
					i_lw  | i_lui | i_jal) & nostall;
	assign regrt = |{i_addi, i_andi, i_ori, i_xori, i_lw, i_lui};
	assign jal = i_jal;
	assign m2reg = |{i_lb, i_lbu, i_lw};
	assign shift = |{i_sll, i_srl, i_sra};
	assign aluimm =|{i_addi, i_andi, i_ori, i_xori, i_lw, i_lui, i_sw};
	assign sext  = |{i_addi, i_lw, i_sw, i_beq, i_bne};
	//alu control
	assign aluc[3] = i_sra;
	assign aluc[2] = |{i_sub, i_or, i_srl, i_sra, i_ori, i_lui};
	assign aluc[1] = |{i_xor, i_sll, i_srl, i_sra, i_xori, i_beq, i_bne, i_lui};
	assign aluc[0] = |{i_and, i_or, i_sll, i_srl, i_sra, i_andi, i_ori};
	assign wmem = i_sw & nostall;
	assign pcsource[1] = |{i_jr, i_j, i_jal};
	assign pcsource[0] = i_beq	& rsrtequ | i_bne & ~rsrtequ | i_j | i_jal;


	/************Control Bypass from EXE/MEM**************/
	// if the MEM-Bypass isn't needed, then no stall.
	assign nostall = ~(ewreg & em2reg & (ern != 0)   & (i_rs & (ern == rs) | 
														i_rt & (ern == rt)));


	// determine bypass for RS register
	always @(*) begin
		fwda = 2'b00;	//reset to defaut(no bypass)
		// Bypass from Last_Inst.EXE
		if (ewreg & (ern != 0) & (ern == rs) & ~em2reg) begin
			fwda = 2'b01;	//select exe_alu
		end
		//Bypass from Penultimate_Inst.MEM
		else if(mwreg & (mrn != 0) & (mrn == rs) & ~mm2reg) begin
				fwda = 2'b10;	//select mem_lw
		end
		//Bypass from Last_Inst.EXE
		else if(mwreg & (mrn != 0) & (mrn == rs) & mm2reg) begin
			fwda = 2'b11;
		end
		/*TODO: it seems that change the order of the last two if clause doesn't matter, CHECK it later.*/
	end


	// determine bypass for RT register
	always @(*) begin
		fwdb = 2'b00;	//reset to defaut(no bypass)
		// Bypass from Last_Inst.EXE
		if (ewreg & (ern != 0) & (ern == rt) & ~em2reg) begin
			fwdb = 2'b01;	//select exe_alu
		end
		//Bypass from Penultimate_Inst.MEM
		else if(mwreg & (mrn != 0) & (mrn == rt) & ~mm2reg) begin
				fwdb = 2'b10;	//select mem_lw
		end
		//Bypass from Last_Inst.EXE
		else if(mwreg & (mrn != 0) & (mrn == rt) & mm2reg) begin
			fwdb = 2'b11;
		end
		/*TODO: it seems that change the order of the last two if clause doesn't matter, CHECK it later.*/
	end



endmodule
