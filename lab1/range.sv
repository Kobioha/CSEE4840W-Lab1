module range
   #(parameter
     RAM_WORDS = 16,            // Number of counts to store in RAM
     RAM_ADDR_BITS = 4)         // Number of RAM address bits
   (input logic         clk,    // Clock
    input logic 	go,     // Read start and start testing
    input logic [31:0] 	start,  // Number to start from or count to read
    output logic 	done,   // True once memory is filled
    output logic [15:0] count); // Iteration count once finished

   logic 		cgo;    // "go" for the Collatz iterator
   logic                cdone;  // "done" from the Collatz iterator
   logic [31:0] 	n;      // number to start the Collatz iterator

// verilator lint_off PINCONNECTEMPTY
   
   // Instantiate the Collatz iterator
   collatz c1(.clk(clk),
	      .go(cgo),
	      .n(n),
	      .done(cdone),
	      .dout(cdout));

   logic [RAM_ADDR_BITS - 1:0] 	 num;         // The RAM address to write
   logic 			 running = 0; // True during the iterations

   always_ff @(posedge clk) begin
	   if (go) begin
		   running <= 1;
		   n <= start;
		   num <= 0;
		   din <= 1;
		   cgo <= 1;
	   end
	   
	   if (cgo) begin
		   cgo <= 0;
		   din <= 1;
	   end
	   
	   if (~cgo && cdone)
		   din <= din + 1;
	   
	   if ((n > 1 && cdout == 2) || n <= 1)
		   we <= 1;
	   if (we) begin
		   we <= 0;
		   n <= n + 1;
		   if ({1'b0, num} == RAM_WORDS - 1 && running) begin
			   running <= 0;
			   done <= 1;
		   end else begin
			   num <= num + 1;
			   cgo <= 1;
		   end
	   end
	   
	   if (done)
		   done <= 0;
   end
   
   logic 			 we;                    // Write din to addr
   logic [15:0] 		 din;                   // Data to write
   logic [15:0] 		 mem[RAM_WORDS - 1:0];  // The RAM itself
   logic [RAM_ADDR_BITS - 1:0] 	 addr;                  // Address to read/write

   assign addr = we ? num : start[RAM_ADDR_BITS-1:0];
   
   always_ff @(posedge clk) begin
      if (we) mem[addr] <= din;
      count <= mem[addr];      
   end

endmodule
	     
