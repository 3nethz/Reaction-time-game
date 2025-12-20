`timescale 1ns / 1ps

module reactionTimer(
    input  wire clk,
    input  wire clear,
    input  wire start,
    input  wire stop,
    output wire led,
    output wire [3:0] an,
    output wire [7:0] sseg,
    output wire [3:0] bcd3,
    output wire [3:0] bcd2,
    output wire [3:0] bcd1,
    output wire [3:0] bcd0,
    output reg [1:0] state_out  // expose FSM state for VGA background
);

    // internal registers
    reg [16:0] ms_counter_reg;          // 1ms counter
    reg [13:0] reaction_timer_reg;      // reaction timer in ms
    reg [28:0] countdown_timer_reg;     // random countdown timer
    reg ms_go;
    reg countdown_go;
    wire ms_tick;
    wire countdown_done;
    reg bin2bcd_start;
    
    // FSM states
    localparam [1:0] idle = 2'b00, load = 2'b01, timing = 2'b10, w2c = 2'b11;

    reg [1:0] state_reg, state_next;

    // --- Millisecond tick generation ---
    always @(posedge clk or posedge clear) begin
        if(clear)
            ms_counter_reg <= 0;
        else if(ms_go) begin
            if(ms_counter_reg == 17'd99999)
                ms_counter_reg <= 0;
            else
                ms_counter_reg <= ms_counter_reg + 1;
        end
    end
    assign ms_tick = (ms_counter_reg == 17'd99999);

    // --- Reaction timer counting ---
    always @(posedge clk or posedge clear) begin
        if(clear)
            reaction_timer_reg <= 0;
        else if(state_reg == timing && ms_tick)
            reaction_timer_reg <= (reaction_timer_reg < 14'd9999) ? reaction_timer_reg + 1 : reaction_timer_reg;
    end

    // --- Random countdown (3-10s) ---
    reg [3:0] random_counter_reg;
    always @(posedge clk or posedge clear) begin
        if(clear)
            random_counter_reg <= 4'd3;
        else if(countdown_go) begin
            if(countdown_timer_reg > 0)
                countdown_timer_reg <= countdown_timer_reg - 1;
            else
                countdown_timer_reg <= random_counter_reg * 29'd100000000; // reload random delay
        end
    end
    assign countdown_done = (countdown_timer_reg == 0);

    // --- FSM ---
    always @(posedge clk or posedge clear) begin
        if(clear)
            state_reg <= idle;
        else
            state_reg <= state_next;
    end
    always @* begin
        state_next = state_reg;
        ms_go = 0;
        countdown_go = 0;
        bin2bcd_start = 0;

        case(state_reg)
            idle: if(start) state_next = load;
            load: begin
                countdown_go = 1;
                if(countdown_done) state_next = timing;
            end
            timing: begin
                ms_go = 1;
                if(stop) begin
                    state_next = w2c;
                    bin2bcd_start = 1;
                end
            end
            w2c: begin
                // wait for clear
            end
        endcase
    end

    assign led = (state_reg == timing);

    // --- Binary to BCD conversion (assume existing module) ---
    bin2bcd b2b_unit(
        .clk(clk),
        .reset(clear),
        .start(bin2bcd_start),
        .bin(reaction_timer_reg),
        .ready(),
        .done_tick(),
        .bcd3(bcd3),
        .bcd2(bcd2),
        .bcd1(bcd1),
        .bcd0(bcd0)
    );

    // --- 7-segment display ---
    displayMuxBasys3 disp_unit(
        .clk(clk),
        .hex3(bcd3),
        .hex2(bcd2),
        .hex1(bcd1),
        .hex0(bcd0),
        .dp_in(4'b0111),
        .an(an),
        .sseg(sseg)
    );

    // expose FSM state to VGA
    always @(posedge clk or posedge clear) begin
        if(clear)
            state_out <= idle;
        else
            state_out <= state_reg;
    end
endmodule
