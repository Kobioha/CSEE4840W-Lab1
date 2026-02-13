// CSEE 4840 Lab 1: Run and Display Collatz Conjecture Iteration Counts
//
// Spring 2023
//
// By: Kambinachi Obioha and Rohit Biswas
// Uni: kno2117 and rb3908

module lab1( input logic        CLOCK_50,  // 50 MHz Clock input
	     
	     input logic [3:0] 	KEY, // Pushbuttons; KEY[0] is rightmost

	     input logic [9:0] 	SW, // Switches; SW[0] is rightmost

	     // 7-segment LED displays; HEX0 is rightmost
	     output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

	     output logic [9:0] LEDR // LEDs above the switches; LED[0] on right
	     );

   logic 			clk, go, done;   
   logic [31:0] 		start;
   logic [15:0] 		count;

   logic [11:0] 		n;
   
   assign clk = CLOCK_50;
 
   range #(256, 8) // RAM_WORDS = 256, RAM_ADDR_BITS = 8)
         r ( .clk(clk), .go(go), .start(start), .done(done), .count(count)); // Connect everything with matching names

   hex7seg d0(.a(finalout[3:0]), .y(HEX0)),
	   d1(.a(finalout[7:4]), .y(HEX1)),
	   d2(.a(finalout[11:8]), .y(HEX2)),
	   d3(.a(finaln[3:0]), .y(HEX3)),
	   d4(.a(finaln[7:4]), .y(HEX4)),
	   d5(.a(finaln[11:8]), .y(HEX5));

   logic [15:0] finalout = 0;
   logic [11:0] finaln = 0;
   logic [11:0] ogn;
   logic [22:0] counter = 0;
   logic 	finished = 0;
   logic	enforce = 0;

   always_ff @(posedge clk) begin
	   go <= (~KEY[3] ? 1 : 0);

	   if (go) begin
		   finished <= 0;
		   n <= start;
	   end

	   if (done) begin
		   finished <= 1;
		   enforce <= 1;
	   end

	   if (enforce) begin
		   ogn <= n;
		   start <= 0;
	   end
	   
	   if (counter == 0)
		   enforce <= 0;

	   if (finished) begin
		   finaln <= n;
		   finalout <= count;
	   end else begin
		   finaln <= SW;
		   start <= SW;
	   end

	   counter <= counter + 1;

	   if (~KEY[1] && counter == 0 && finished && n > ogn) begin
		   n <= n - 1;
		   start <= start - 1;
	   end

	   if (~KEY[0] && counter == 0 && finished && n < ogn + 255) begin
		   n <= n + 1;
		   start <= start + 1;
	   end

	   if (~KEY[2] && finished) begin
		   n <= ogn;
		   start <= 0;
	   end
   end

   assign LEDR = SW;

endmodule
