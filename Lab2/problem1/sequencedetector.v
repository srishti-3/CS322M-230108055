module seq_detector_mealy (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output reg  dout
);


    parameter IDLE   = 2'b00;
    parameter S1     = 2'b01;
    parameter S2     = 2'b10;
    parameter S3     = 2'b11;

    reg [1:0] present_state, future_state;

  
    always @(posedge clk or posedge reset) begin
        if (reset)
            present_state <= IDLE;
        else
            present_state <= future_state;
    end

 
    always @(*) begin
        case (present_state)
            IDLE:   future_state = (din) ? S1 : IDLE;
            S1:     future_state = (din) ? S2 : IDLE;
            S2:     future_state = (din) ? S2 : S3;
            S3:     future_state = (din) ? S1 : IDLE;
            default: future_state = IDLE;
        endcase
    end

   
    always @(*) begin
        case (present_state)
            S3: dout = (din) ? 1'b1 : 1'b0;  
            default: dout = 1'b0;
        endcase
    end

endmodule
