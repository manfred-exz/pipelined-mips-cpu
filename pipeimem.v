module pipeimem(address, inst);
	input	[31:0]	address;
	output	[31:0]	inst;
	
	localparam ROM_DEPTH = 6;
	localparam ROM_WIDTH = 32;
	localparam ROM_SIZE  = 2 ** ROM_DEPTH;
//	(* brom_map = "yes" *)
	reg		[ROM_WIDTH-1:0]	rom[0:ROM_SIZE-1]; 
	wire	[ROM_DEPTH-1:0]	index_in_rom = address[ROM_DEPTH+1:2];
	assign	inst = rom[index_in_rom];
	
	initial begin
		$readmemh("codes/rom.dat", rom);
	end

//	defparam 	lpm_rom_component.lpm_width 			= 32,
//				lpm_rom_component.lpm_widthad			= 6,
//				lpm_rom_component.lpm_numwords			= "unused",
//				lpm_rom_component.lpm_file				= "pipeimem.mif",
//				lpm_rom_component.lpm_indata			= "unused",
//				lpm_rom_component.lpm_outdata			= "unregistered",
//				lpm_rom_component.lpm_address_control	= "unregistered";
				
endmodule
