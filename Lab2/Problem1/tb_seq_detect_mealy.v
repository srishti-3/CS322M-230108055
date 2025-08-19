`timescale 1ns/1ps
module tb_seq_detect_mealy;
    reg clk, rst, din;
    wire y;

    // DUT instantiation
    seq_detect_mealy dut(
        .clk(clk),
        .rst(rst),
        .din(din),
        .y(y)
    );

    // Clock gen: 100 MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Dumpfile for GTKWave
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        // Initialize
        clk = 0;
        rst = 1;
        din = 0;
        #12 rst = 0; // deassert reset after few cycles

        // Bitstream with overlaps: 11011011101
        send_bits(11'b11011011101);

        #50 $finish;
    end

    // Task to send bits MSB-first
    task send_bits(input [31:0] data);
        integer i;
        begin
            for (i=$bits(data)-1; i>=0; i=i-1) begin
                din = data[i];
                #10; // 1 clock cycle per bit
            end
        end
    endtask

    // Monitor
    initial begin
        $monitor("T=%0t din=%b y=%b state=%b",
                 $time, din, y, dut.state);
    end

endmodule
