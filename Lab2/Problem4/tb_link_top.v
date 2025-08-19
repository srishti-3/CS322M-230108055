`timescale 1ns/1ps
module tb_link_top;
    reg clk, rst;
    wire done;

    link_top dut(.clk(clk), .rst(rst), .done(done));

  
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

  
    initial begin
        $dumpfile("handshake.vcd");
        $dumpvars(0, tb_link_top);

        rst = 1;
        #20;
        rst = 0;

       
        #500;
        $finish;
    end
endmodule
