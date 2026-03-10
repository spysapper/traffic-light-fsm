module traffic_light_fsm (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,
    output logic [2:0] LA, // [Green, Yellow, Red]
    output logic [2:0] LB
);

    // fsm stateleri
    typedef enum logic [1:0] {
        S0 = 2'b00, 
        S1 = 2'b01, 
        S2 = 2'b10, 
        S3 = 2'b11  
    } state_t;

    state_t current_state, next_state;

    // 5 saniyelik sari isik delayi icin timer
    logic [2:0] timer;
    logic reset_timer;
    logic inc_timer;

    // state register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // timer blogu
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            timer <= 3'd0;
        end else if (reset_timer) begin
            timer <= 3'd0; // state degisince timer'i sifirla
        end else if (inc_timer) begin
            timer <= timer + 3'd1;
        end
    end

    // next state ve output logic
    always_comb begin
        // latch olusmasin diye default degerleri bastan veriyorum
        next_state  = current_state;
        reset_timer = 1'b0;
        inc_timer   = 1'b0;
        LA          = 3'b001; // default kirmizi
        LB          = 3'b001; 

        case (current_state)
            S0: begin
                LA = 3'b100; // LA yesil yandi
                LB = 3'b001; // LB kirmizi
                if (~TAORB) begin
                    next_state = S1;
                    reset_timer = 1'b1;
                end
            end

            S1: begin
                LA = 3'b010; // LA sari
                LB = 3'b001; 
                // 5 saniye dolana kadar say
                if (timer < 3'd5) begin
                    inc_timer = 1'b1;
                end else begin
                    next_state = S2;
                    reset_timer = 1'b1; 
                end
            end

            S2: begin
                LA = 3'b001; 
                LB = 3'b100; // LB yesil
                if (TAORB) begin
                    next_state = S3;
                    reset_timer = 1'b1;
                end
            end

            S3: begin
                LA = 3'b001; 
                LB = 3'b010; // LB sari
                if (timer < 3'd5) begin
                    inc_timer = 1'b1;
                end else begin
                    next_state = S0;
                    reset_timer = 1'b1; 
                end
            end

            default: next_state = S0;
        endcase
    end

endmodule
