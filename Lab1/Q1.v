module comparator_1bit_gate (
    input A, B,
    output O1, O2, O3
);
    wire notA, notB, xorAB;

    
    not (notA, A);
    not (notB, B);

    
    and (O1, A, notB);

   
    xor (xorAB, A, B);
    not (O2, xorAB);

   
    and (O3, notA, B);

endmodule
