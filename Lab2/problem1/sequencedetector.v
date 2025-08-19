module seq_detect_1101_mealy (
    input  wire clk,
    input  wire reset,  
    input  wire din,
    output reg  y
);

  
    typedef enum reg [1:0] {
        S0 = 2'b00,  
        S1 = 2'b01,  
        S2 = 2'b10, 
        S3 = 2'b11
    } state_t;

    state_t present_state, next_state;


    always @(posedge clk) begin
        if (reset)
            present_state <= S0;
        else
            present_state <= next_state;
    end


    always @(*) begin
        y = 1'b0; 
        case (present_state)
            S0: next_state = (din) ? S1 : S0;

            S1: next_state = (din) ? S2 : S0;

            S2: next_state = (din) ? S2 : S3;

            S3: begin
                if (din) begin
                    next_state = S1;
                    y = 1'b1;  
                end else begin
                    next_state = S0;
                end
            end

            default: next_state = S0;
        endcase
    end

endmodule
