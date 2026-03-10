`timescale 1ns / 1ps

module tb_traffic_light_fsm;

    logic clk;
    logic reset;
    logic TAORB;
    logic [2:0] LA;
    logic [2:0] LB;

    // ana modulu cagiriyoruz
    traffic_light_fsm uut (
        .clk(clk),
        .reset(reset),
        .TAORB(TAORB),
        .LA(LA),
        .LB(LB)
    );

    // clock uretimi (10 birim)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // test senaryosu
    initial begin
        reset = 1;
        TAORB = 1; // A caddesi dolu baslasin
        #15;
        reset = 0; 

        #30; // biraz bekle sistemi gor

        // A caddesi bosaldi
        TAORB = 0; 

        #80; // S1'deki 5 clock'luk delayi gormek icin bekle

        // B caddesi yesilken A caddesine araba gelirse S3'e gec
        TAORB = 1;

        #80; // S3 sari isik delayi

        $stop;
    end

    initial begin
        $display("Time\tReset\tTAORB\tState\tTimer\tLA(GYR)\tLB(GYR)");
        $display("-------------------------------------------------------");
        $monitor("%0t\t%b\t%b\t%b\t%0d\t%b\t%b", 
                 $time, reset, TAORB, uut.current_state, uut.timer, LA, LB);
    end

endmodule
