// CSEE 4840 Lab 1: Run and Display Collatz Conjecture Iteration Counts
//
// Spring 2023
//
// By: <your name here>
// Uni: <your uni here>

module lab1(
    input  logic        CLOCK_50,  // 50 MHz Clock input
    input  logic [3:0]   KEY,       // Pushbuttons; KEY[0] is rightmost
    input  logic [9:0]   SW,        // Switches; SW[0] is rightmost

    // 7-segment LED displays; HEX0 is rightmost
    output logic [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

    output logic [9:0]   LEDR       // LEDs above the switches; LEDR[0] on right
);

    // Core signals
    logic        clk, go, done;
    logic [31:0] start;
    logic [15:0] count;

    // Display/control
    logic [9:0]  base;
    logic [7:0]  offset;
    logic [11:0] n;
    logic [11:0] count12;

    // Button handling
    logic [21:0] hold_ctr;
    logic        repeat_tick;
    logic        key0_pressed, key1_pressed, key2_pressed, key3_pressed;
    logic        key0_prev,    key1_prev,    key2_prev,    key3_prev;

    // Status
    logic        run_complete;
    logic        run_active;

    assign clk = CLOCK_50;

    // Range module: 256 words, 8-bit address
    range #(256, 8) r (
        .clk   (clk),
        .go    (go),
        .start (start),
        .done  (done),
        .count (count)
    );

    // Active-low pushbuttons
    assign key0_pressed = ~KEY[0];
    assign key1_pressed = ~KEY[1];
    assign key2_pressed = ~KEY[2];
    assign key3_pressed = ~KEY[3];

    // Hold repeat tick (about 50 MHz / 2^22 ≈ 12 Hz; tweak if desired)
    assign repeat_tick = (hold_ctr == 22'd0);

    // Switch-set base value and offset-selected displayed value
    assign base    = SW;
    assign n       = {2'b00, base} + {4'b0000, offset};
    assign count12 = count[11:0];

    // start is base when pulsing go, otherwise it's the RAM read address (offset)
    assign start = go ? {22'd0, base} : {24'd0, offset};

    initial begin
        go           = 1'b0;
        offset       = 8'd0;
        hold_ctr     = 22'd0;
        key0_prev    = 1'b0;
        key1_prev    = 1'b0;
        key2_prev    = 1'b0;
        key3_prev    = 1'b0;
        run_complete = 1'b0;
        run_active   = 1'b0;
    end

    always_ff @(posedge clk) begin
        hold_ctr <= hold_ctr + 22'd1;
        go       <= 1'b0;

        // Run finished
        if (done) begin
            run_complete <= 1'b1;
            run_active   <= 1'b0;
        end

        // Start run on KEY[3] press edge
        if (key3_pressed && !key3_prev) begin
            go           <= 1'b1;
            run_complete <= 1'b0;
            run_active   <= 1'b1;
        end

        // Reset offset on KEY[2] press edge
        if (key2_pressed && !key2_prev) begin
            offset <= 8'd0;

        // Increment/decrement offset (one key at a time), with hold-repeat
        end else if (key0_pressed ^ key1_pressed) begin
            if ((key0_pressed && !key0_prev) || (key0_pressed && repeat_tick)) begin
                if (offset != 8'hff) offset <= offset + 8'd1;

            end else if ((key1_pressed && !key1_prev) || (key1_pressed && repeat_tick)) begin
                if (offset != 8'h00) offset <= offset - 8'd1;
            end
        end

        // Save previous key states for edge detect
        key0_prev <= key0_pressed;
        key1_prev <= key1_pressed;
        key2_prev <= key2_pressed;
        key3_prev <= key3_pressed;
    end

    // Seven-seg outputs: right 3 = count, left 3 = n
    hex7seg h0(.a(count12[3:0]),  .y(HEX0));
    hex7seg h1(.a(count12[7:4]),  .y(HEX1));
    hex7seg h2(.a(count12[11:8]), .y(HEX2));
    hex7seg h3(.a(n[3:0]),        .y(HEX3));
    hex7seg h4(.a(n[7:4]),        .y(HEX4));
    hex7seg h5(.a(n[11:8]),       .y(HEX5));

    // Debug LEDs
    assign LEDR[3:0] = count[15:12];
    assign LEDR[7:4] = offset[3:0];
    assign LEDR[8]   = run_active;
    assign LEDR[9]   = run_complete;

endmodule