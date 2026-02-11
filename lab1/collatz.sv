module collatz(
    input  logic        clk,   // Clock
    input  logic        go,    // Load value from n; start iterating
    input  logic [31:0] n,     // Start value; only read when go = 1
    output logic [31:0] dout,  // Iteration value
    output logic        done   // True when dout reaches 1
);

    always_ff @(posedge clk) begin
        logic [31:0] next;

        if (go) begin
            dout <= n;
            done <= (n <= 32'd1);
        end 
        else if (!done) begin
            next = dout[0] ? (dout * 32'd3 + 32'd1)
                           : (dout >> 1);

            dout <= next;
            done <= (next == 32'd1);
        end
    end

endmodule