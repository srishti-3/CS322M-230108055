module seq_detect_mealy(
    input  wire clk,
    input  wire rst,   
    input  wire din,   
    output reg  y      
);

 
    localparam S0 = 2'b00; 
    localparam S1 = 2'b01; 
    localparam S2 = 2'b10; 
    localparam S3 = 2'b11; 

    reg [1:0] state, next_state;

    
    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

   
    always @(*) begin
        next_state = state;
        y = 1'b0;  
        case (state)
            S0: next_state = (din) ? S1 : S0;

            S1: next_state = (din) ? S2 : S0;

            S2: next_state = (din) ? S2 : S3;

            S3: begin
                if (din) begin
                    next_state = S1;
                    y = 1'b1; // detect 1101
                end else begin
                    next_state = S0;
                end
            end

            default: next_state = S0;
        endcase
    end

endmodule
