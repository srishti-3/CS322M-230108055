`timescale 1ns/1ps

module tb_comparator_1bit_gate;
    reg A, B;
    wire O1, O2, O3;

    
    comparator_1bit_gate uut (
        .A(A),
        .B(B),
        .O1(O1),
        .O2(O2),
        .O3(O3)
    );

    initial begin
        $display("Time | A B | O1(A>B) O2(A=B) O3(A<B)");
        $monitor("%4t | %b %b |    %b        %b        %b", $time, A, B, O1, O2, O3);

        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;

        $stop;
    end
endmodule
