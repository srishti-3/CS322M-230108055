`timescale 1ns/1ps

module tb_comparator_4bit_eq_gate;
    reg [3:0] A, B;
    wire EQ;


    comparator_4bit_eq_gate uut (
        .A(A),
        .B(B),
        .EQ(EQ)
    );

    initial begin
        $display("Time |    A    B    | EQ (A==B)");
        $monitor("%4t | %b %b |    %b", $time, A, B, EQ);

        A = 4'b0000; B = 4'b0000; #10;
        A = 4'b1010; B = 4'b1010; #10;
        A = 4'b1111; B = 4'b0000; #10;
        A = 4'b1100; B = 4'b1100; #10;
        A = 4'b0101; B = 4'b0110; #10;

        $stop;
    end
endmodule
