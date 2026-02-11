module range
#(
    parameter RAM_WORDS     = 16,  // Number of counts to store in RAM
    parameter RAM_ADDR_BITS = 4    // Number of RAM address bits
)
(
    input  logic         clk,     // Clock
    input  logic         go,      // Read start and start testing
    input  logic [31:0]  start,   // Number to start from or count to read
    output logic         done,    // True once memory is filled
    output logic [15:0]  count    // Iteration count once finished
);

    // Last RAM address
    localparam logic [RAM_ADDR_BITS-1:0] LAST_ADDR =
        RAM_ADDR_BITS'(RAM_WORDS - 1);

    // Collatz interface
    logic        cgo;     // "go" for Collatz iterator
    logic        cdone;   // "done" from Collatz iterator
    logic [31:0] n;       // Current number being tested

    // Instantiate Collatz iterator
    // verilator lint_off PINCONNECTEMPTY
    collatz c1 (
        .clk  (clk),
        .go   (cgo),
        .n    (n),
        .done (cdone),
        .dout ()
    );
    // verilator lint_on PINCONNECTEMPTY

    // Control state
    logic [RAM_ADDR_BITS-1:0] num;     // RAM write address
    logic                     running; // True during iteration phase

    // RAM + write path
    logic                     we;      // Write enable
    logic [15:0]              din;     // Data to write
    logic [15:0]              mem [RAM_WORDS-1:0];
    logic [RAM_ADDR_BITS-1:0] addr;    // RAM address (read/write)

    // Write occurs when Collatz finishes for current n
    assign we = running && cdone && !cgo;

    // Optional initialization (tool-dependent but fine for this lab)
    initial begin
        done    = 1'b0;
        cgo     = 1'b0;
        n       = 32'd0;
        num     = '0;
        running = 1'b0;
        din     = 16'd0;
        count   = 16'd0;
    end

    // Main control logic
    always_ff @(posedge clk) begin
        done <= 1'b0;  // default: done pulses one cycle

        if (go) begin
            // Start new range run
            running <= 1'b1;
            cgo     <= 1'b1;
            n       <= start;
            num     <= '0;
            din     <= 16'd1;

        end else if (running) begin

            if (cgo) begin
                // Deassert cgo after one cycle (pulse)
                cgo <= 1'b0;

            end else if (cdone) begin
                // Finished current n

                if (num == LAST_ADDR) begin
                    // Last address written
                    running <= 1'b0;
                    done    <= 1'b1;
                end else begin
                    // Move to next n
                    num <= num + 1'b1;
                    n   <= n + 32'd1;
                    din <= 16'd1;
                    cgo <= 1'b1;
                end

            end else begin
                // Still iterating for current n
                din <= din + 16'd1;
            end

        end else begin
            cgo <= 1'b0;
        end
    end

    // RAM address selection:
    // - During write: use num
    // - During read: use start as read address
    assign addr = we ? num : start[RAM_ADDR_BITS-1:0];

    // RAM write + synchronous read
    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= din;

        count <= mem[addr];
    end

endmodule