module vending_mealy(
    input  wire       clk,
    input  wire       rst,     
    input  wire [1:0] coin,    
    output reg        dispense, 
    output reg        chg5     
);

    
    parameter S0  = 2'b00,
              S5  = 2'b01,
              S10 = 2'b10,
              S15 = 2'b11;

    reg [1:0] state, next_state;

    
    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

  
    always @(*) begin
      
        next_state = state;
        dispense   = 1'b0;
        chg5       = 1'b0;

        case (state)
            S0: begin
                if (coin == 2'b01) next_state = S5;       
                else if (coin == 2'b10) next_state = S10; 
            end

            S5: begin
                if (coin == 2'b01) next_state = S10;
                else if (coin == 2'b10) next_state = S15;
            end

            S10: begin
                if (coin == 2'b01) next_state = S15;
                else if (coin == 2'b10) begin
                    dispense   = 1'b1; 
                    next_state = S0;  
                end
            end

            S15: begin
                if (coin == 2'b01) begin
                    dispense   = 1'b1;
                    next_state = S0;  
                end
                else if (coin == 2'b10) begin
                    dispense   = 1'b1; 
                    chg5       = 1'b1;
                    next_state = S0;
                end
            end
        endcase
    end
endmodule
