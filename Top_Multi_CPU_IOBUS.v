`timescale 1ns / 1ps
//`define SIM // simulation mode
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:45:59 02/27/2014 
// Design Name: 
// Module Name:    Top_Simple_CPU_App 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Top_Multi_CPU_IOBUS(
	//CLK
	input wire clk_100mhz,

	//INPUT
	input wire [4:0]btn,		//button
	input wire [7:0]switch,		//switch

	//OUTPUT
	output wire [7:0]led,		//[LED]led

	output wire [7:0]seg_out,	//[7SEG]seg_out
	output wire [3:0]anode_out,	//[7SEG]anode
	
	output wire [2:0]vga_red, vga_green,
	output wire [2:1]vga_blue,
	output wire h_sync, v_sync,
	
	input  wire ps2_clk, ps2_data
	);

	wire[31:0]pc,inst, addr_bus, Cpu_data2bus,
					Cpu_data4bus, ram_data_out, ram_data_in,
					counter_out, Peripheral_in, disp_num;
	wire[21:0]GPIOf0;
	wire[15:0]seven_seg_out;
	wire[9:0]rom_addr, ram_addr;
	wire[7:0]switch_out, led_tmp;
	wire[4:0]button_out, state;
	wire[3:0]blinke;
	wire[1:0]Counter_set;
	wire reg_we, mem_we,  data_ram_we, GPIOf0000000_we,GPIOe0000000_we,counter_we;
	wire counter_OUT0,counter_OUT1,counter_OUT2;
	
	
	//********************CLK & RST*********************//

	//[CLK]set CLK - clock
	wire [31:0]clk_div;
	wire clk_CPU, clk_io, clk_m;
	assign clk_io = ~clk_CPU;				//clock for IO device
	assign clk_m = ~clk_100mhz;				//clock for ROM/RAM

	//[RST]set RST - reset button
	wire rst;
	assign rst = button_out[4];				//button_out[4] is the lower button in this ucf
	
	//********************NOT USED YET*********************//
	//[MIO]NOT used yet
//	wire MIO_ready;
//	assign MIO_ready = ~button_out[1];

	wire CPU_MIO;

	
	
	
	
	
	//*********************7-SEG**********************//
	//[IN]显示模式 - switch 
	//[IN]显示内容 - disp_num -> digit or graph
	//[OUT]7段数码管输出
	hex7seg U6(
		.disp_num(disp_num),
		.rst(button_out[0]),
		.switch(switch[1:0]),
		//.scanning_clk(clk_div[2:1]),		//used for simulation
		.scanning_clk(clk_div[19:18]),		//speed of changing anode, too slow will cause flash

		//signals sent to physical device
		.seg_out(seg_out),
		.anode_out(anode_out)
		);
	
	//************************CLOCK DEVIDER**********************//
	//[IN]cpu时钟模式 switch[2]正常0/调试1
	//[OUT]clk_div
	//[OUT]clk_CPU
	clk_div U8(
		//CLK & RST
		.clk(clk_100mhz),
		.rst(rst),
		
		//INPUT
		.cpu_clk_switch(switch[2]),

		//OUTPUT
		.clk_div(clk_div),					//clock divider: provide different clock speed, NOTE that clk_div[0] is slower then clk_100mhz
		.clk_CPU(clk_CPU)					//clk for cpu: 25mhz or (25m/2^23)hz
		);
		
	//**************************ANTI JITTER***********************//
	//[OUT]稳定的button/switch信号
	BTN_Anti_jitter BTN_OK (
		//CLK
		.clk(clk_100mhz),
		
		//INPUT
		.button(btn),
		.switch(switch),

		//OUTPUT
		.button_out(button_out),
		.switch_out(switch_out)
		);
	

	//顶层调用模块（CPU 及应用模块调用）
	//******************************ROM**************************//
	//[IN]	rom addr - 地址
	//[OUT]	Instructions - 命令
	
	/*
	rom_block IRom(
		.clka(clk_m),
		.addra(rom_addr),
		.douta(inst)
		);
		*/
	pipeimem instance_name (
	    .address(pc), 
	    .inst(inst)
	    );

	//******************************RAM**************************//
	//[IN]	写入使能/写入内容/写入地址
	//[OUT]	ram输出
	/*
	ram_block DRam(
		.clka(clk_m),
		.wea(data_ram_we),
		.addra(ram_addr),
		.dina(ram_data_in),
		.douta(ram_data_out)
		);
		*/
		
	ram_block RAM_I_D(
		.clka(clk_m),
		.wea(data_ram_we),
		.addra(ram_addr),
		.dina(ram_data_in),
		.douta(ram_data_out)
		);
		
		
		

	//******************************CPU**************************//
	//[IN]	cpu时钟
	//[IN]	指令内容
	//[OUT]	指令地址
	//[
	// multi_cycle_Cpu MCpu(
	// 	//CLK & RST
	// 	.clk(clk_CPU),
	// 	.reset(rst),
	// 	.MIO_ready(MIO_ready),

	// 	//INPUT
	// 	.inst(inst),				//[IN]	instructions CPU need to do
	// 	.data_in(Cpu_data4bus),		//[IN]	data from [bus]

	// 	//OUTPUT
	// 	.Addr_out(addr_bus),		//[OUT]	Accessing what [device]?
	// 	.mem_we(mem_we),			//[OUT] Write to that [device]?
	// 	.data_out(Cpu_data2bus),	//[OUT] What to write to?

	// 	//Others
	// 	.pc_out(pc),				//[OUT]	instruction address
	// 	.CPU_MIO(CPU_MIO),
	// 	.state(state)
		
	// 	);
		
	pipelinedcpu my_pipeline_cpu (
	    .clock(clk_CPU), 
	    .memclock(clk_m), 
	    .resetn(~rst), 
		//INST
	    .pc(pc), 					//[OUT]	instruction address
	    .inst(inst),				//[IN]	instructions CPU need to do
		//
		.MEM_we(mem_we),
		.MEM_address(addr_bus),
		.MEM_w_data(Cpu_data2bus),
		.MEM_r_data(Cpu_data4bus)
	    );
		
	
		
	//------Peripheral Driver-----------------------------------
	/* GPIO out use on LEDs & Counter-Controler read and write addre=f0000000-ffffffff0 */
	//assign led = {led_tmp[7] | clk_CPU, led_tmp[6:0]};
	assign led = led_tmp;
	
	Device_GPIO_led Device_led( 
		clk_io,
		rst,
		GPIOf0000000_we,
		Peripheral_in,
		Counter_set,
		led_tmp,
		GPIOf0
		);
		
//		wire [7:0]data_from_ps2;

		
//	reg [7:0]rgb = 8'b11100000;
	wire [7:0]rgb = {8{mono}};
	reg vga_enable = 1;
	wire vga_rdn;
	wire mono;
	wire [8:0]row_addr;
	wire [9:0]col_addr;


	vga_controller vgac(
		.d_in(rgb),
		.vga_clk(clk_div[1]),
		.clrn(vga_enable),
		.row_addr(row_addr),
		.col_addr(col_addr),
		.r(vga_red),
		.g(vga_green),
		.b(vga_blue),
		.rdn(vga_rdn),
		.hs(h_sync),
		.vs(v_sync)
		);
	
//	wire vga_read_enable;
//	
//	assign vga_read_enable = ~pixel_dont_display;
	wire vram_write_enable;
	wire [12:0]vram_write_addr;
	wire [6:0]vram_write_data;

	vram_controller vramc(
		.clk(clk_100mhz),
		
		.cpu_write_enable(vram_write_enable),
		.cpu_write_addr(vram_write_addr),
		.cpu_write_data(vram_write_data),
		.rdn(vga_rdn),
		.row(row_addr),
		.col(col_addr),
		.mono(mono)
		);
		
	reg [31:0]key_d;
	reg ps2_rdn;
	wire [7:0]key;
	wire [7:0]ps2_key;
	always @(posedge clk_io or posedge rst)
		if(rst) begin
			ps2_rdn <= 1;
			key_d <= 0;
		end
		else if(ps2_rd && ps2_ready) begin
			key_d <= {key_d[23:0], ps2_key};
			ps2_rdn <= ~ps2_rd | ~ps2_ready;
		end
		else 
			ps2_rdn <= 1;
	
	assign key = (ps2_rd && ps2_ready) ? ps2_key : 8'haa;
		
//	reg ps2_rdn = 0;
	wire ps2_rd;
//	wire [7:0]data_from_ps2;
	wire ps2_ready, ps2_overflow;
	reg keyboard_enable = 1;
	ps2_keyboard ps2(
		.clk(clk_div[1]),
		.clrn(~rst),
		.ps2_clk(ps2_clk),
		.ps2_data(ps2_data),
//		.rdn(~ps2_rd), 
		.rdn(ps2_rdn),
		.data(ps2_key),
		.ready(ps2_ready),
		.overflow(ps2_overflow)
		);
		
		
		
	/*Simple Counter Addre =f0000004-fffffff4 */
	
	 Counter_x Counter_xx(
		.clk( clk_io),
		.rst(rst),
		.clk0(clk_div[9]),
		.clk1(clk_div[10]),
		.clk2(clk_div[10]),
		.counter_we(counter_we),
		.counter_val(Peripheral_in),
		.counter_ch(Counter_set),
		
		.counter0_OUT(counter_OUT0),
		.counter1_OUT(counter_OUT1),
		.counter2_OUT(counter_OUT2),
		.counter_out(counter_out)
	);
	
		/*GPIO out use on 7-seg display & CPU state display addre=e0000000-efffffff */
	Device_GPIO_7seg Device_7seg( 
		.clk(clk_io),
		.rst(rst),
		.GPIOe0000000_we(GPIOe0000000_we),
		.Test(switch_out[7:5]),
		.disp_cpudata(Peripheral_in), 
		//CPU data output
		.Test_data0({2'b00,pc[31:2]}),
		//pc[31:2]
		.Test_data1(counter_out),
		//counter
		.Test_data2(inst), 			//inst
		.Test_data3(addr_bus), 		//addr_bus
		.Test_data4(Cpu_data2bus),	//Cpu_data2bus;
		.Test_data5(Cpu_data4bus),	//Cpu_data4bus;
		.Test_data6(state), //pc;
		.disp_num(disp_num)
		);
	
	
	//Simple BUS Interface
	//++++++++++++++++++++++++
	MIO_BUS MIO_interface( 
		//CLK & RST
		.clk( clk_100mhz),
		.rst(rst),

		//CONNECT
		.addr_bus(addr_bus),
		.ram_addr(ram_addr),
		//	WRITE ENABLE
		.mem_we(mem_we),
		.GPIOf0000000_we(GPIOf0000000_we),
		.GPIOe0000000_we(GPIOe0000000_we),
		.counter_we(counter_we),
		.data_ram_we(data_ram_we),
		
		//DATA to CPU
		.Cpu_data4bus(Cpu_data4bus),

		.btn(button_out[3:0]),
		.led(led),
		.switch(switch_out),
		.counter_out(counter_out),
		.counter0_out(counter_OUT0),
		.counter1_out(counter_OUT1),
		.counter2_out(counter_OUT2),
		.ram_data_out(ram_data_out),
//		.ps2_out( {ps2_ready, ps2_overflow, data_from_ps2}),
		
		//DATA to DEVICE
		.Peripheral_in(Peripheral_in),
		.ram_data_in(ram_data_in),

		.Cpu_data2bus(Cpu_data2bus),
		
		.vga_rdn(vga_rdn),
		.ps2_ready(ps2_ready),
		.key(key),
//		.key(ps2_key),
		.vga_addr(),
		.vram_out(),
		.vram_write_data(vram_write_data),
		.vram_write_addr(vram_write_addr),
		.vram_write_enable(vram_write_enable),
		.ps2_rd(ps2_rd)

		);
	
	
	

endmodule
