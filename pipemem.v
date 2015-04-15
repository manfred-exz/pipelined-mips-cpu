module pipemem(we, addr, datain, clk, inclk, outclk, dataout);
	
	input 	[31:0]	addr, datain;
	input			clk, we, inclk, outclk;

	output	[31:0]	dataout;

	wire	write_enable = we & ~clk;
					
	ip_ram ram( .clka(inclk),
				.wea(write_enable),
				.addra(addr[6:2]),
				.dina(datain),
				.douta(dataout)
				);
				
//	defparam ram.lpm_width				= 32;
//	defparam ram.lpm_widthad			= 5;
//	defparam ram.lpm_indata				= "registered";
//	defparam ram.lpm_outdata			= "registered";
//	defparam ram.lpm_file				= "pipedmem.mif";
//	defparam ram.lpm_address_control	= " registered";

endmodule
