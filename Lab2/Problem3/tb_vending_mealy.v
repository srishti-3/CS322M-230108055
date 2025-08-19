`timescale 1ns/1ps
module tb_vending_mealy;
    reg clk, rst;
    reg [1:0] coin;
    wire dispense, chg5;

    vending_mealy dut(.clk(clk), .rst(rst), .coin(coin),
                      .dispense(dispense), .chg5(chg5));

    
    initial clk = 0;
    always #5 clk = ~clk;

   
    task put5;
        begin
            coin = 2'b01; #10;
            coin = 2'b00; #10;
        end
    endtask

    task put10;
        begin
            coin = 2'b10; #10;
            coin = 2'b00; #10;
        end
    endtask

   
    initial begin
        $dumpfile("vending.vcd");
        $dumpvars(0, tb_vending_mealy);

        
        coin = 2'b00;
        rst  = 1;
        #15 rst = 0;

       
        put10; put10;

       
        put5; put5; put10;

      
        put10; put10; put5;

        #100 $finish;
    end
endmodule
