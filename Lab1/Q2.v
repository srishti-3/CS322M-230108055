module comparator_4bit_eq_gate (
    input [3:0] A, B,
    output EQ
);
    wire xnor0, xnor1, xnor2, xnor3;

    xnor (xnor0, A[0], B[0]);
    xnor (xnor1, A[1], B[1]);
    xnor (xnor2, A[2], B[2]);
    xnor (xnor3, A[3], B[3]);

  
    and (EQ, xnor0, xnor1, xnor2, xnor3);

endmodule
