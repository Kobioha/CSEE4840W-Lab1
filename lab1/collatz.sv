module collatz( input logic         clk,   // Clock
		input logic 	    go,    // Load value from n; start iterating
		input logic  [31:0] n,     // Start value; only read when go = 1
		output logic [31:0] dout,  // Iteration value: true after go = 1
		output logic 	    done); // True when dout reaches 1


   logic default0;

   always_ff @(posedge clk) begin
	   default0 <= 1;
	   if (go) begin
		   dout <= n;
		   done <= 0;
	   end else begin
		   if (dout >= 2) begin
			   if (dout == 2)
				   done <= 1;
			   if (dout % 2 == 1)
				   dout <= 3 * dout + 1;
			   else
				   dout <= dout / 2;
		   end
		   if (dout == 1 || (default0 && dout == 0)) begin
			   dout <= 1;
			   done <= 1;
		   end
	   end
   end

endmodule
