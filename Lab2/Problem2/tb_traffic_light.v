`timescale 1ns/1ps
module tb_traffic_light;

    reg clk, rst, tick;
    wire ns_g, ns_y, ns_r;
    wire ew_g, ew_y, ew_r;

    // DUT instantiation
    traffic_light dut(
        .clk(clk), .rst(rst), .tick(tick),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
    );

    // 50MHz clock for example (20 ns period)
    always #10 clk = ~clk;

    initial begin
        // waveform dump
        $dumpfile("traffic.vcd");
        $dumpvars(0, tb_traffic_light);

        // init
        clk = 0;
        rst = 1;
        tick = 0;
        #25 rst = 0; // deassert reset

        // Generate tick pulses every 100ns (for simulation speed)
        repeat (40) begin
            #90 tick = 1;
            #20 tick = 0;
        end

        #100 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("T=%0t ns_g=%b ns_y=%b ns_r=%b | ew_g=%b ew_y=%b ew_r=%b | state=%b",
                  $time, ns_g, ns_y, ns_r, ew_g, ew_y, ew_r, dut.state);
    end

endmodule
