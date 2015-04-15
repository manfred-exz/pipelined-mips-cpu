module dffe32(d, clk, clrn, e, q);

	input	[31:0]	d;
	input			clk, clrn, e;

	output	[31:0]	q;

	reg	[31:0]	q;
	
	initial begin
		q = 0;
	end

	always @(posedge clk or negedge clrn) begin
		if (clrn == 0) begin
			// reset
			q <= 0;
		end
		else begin
			if(e)
				q <= d;
//				q <= 0;
		end
	end
endmodule
