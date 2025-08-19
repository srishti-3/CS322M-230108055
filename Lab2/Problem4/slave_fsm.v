module slave_fsm(
    input  wire      clk,
    input  wire      rst,
    input  wire      req,
    input  wire [7:0] data_in,
    output reg       ack,
    output reg [7:0] last_byte
);

   
    parameter WAITREQ  = 2'b00,
              ASSERT   = 2'b01,
              HOLD     = 2'b10,
              DROP     = 2'b11;

    reg [1:0] state, next_state;
    reg [1:0] hold_cnt;

    
    always @(posedge clk) begin
        if (rst) begin
            state     <= WAITREQ;
            hold_cnt  <= 2'b00;
        end else begin
            state <= next_state;
        end
    end


    always @(*) begin
        ack        = 1'b0;
        next_state = state;

        case (state)
            WAITREQ: begin
                if (req) next_state = ASSERT;
            end

            ASSERT: begin
                ack        = 1'b1;
                next_state = HOLD;
            end

            HOLD: begin
                ack = 1'b1;
                if (hold_cnt == 2'd1) next_state = DROP; 
            end

            DROP: begin
                if (!req) next_state = WAITREQ;
            end
        endcase
    end


    always @(posedge clk) begin
        if (rst)
            hold_cnt <= 2'd0;
        else if (state == ASSERT)
            hold_cnt <= 2'd0;
        else if (state == HOLD)
            hold_cnt <= hold_cnt + 1'b1;
    end

    
    always @(posedge clk) begin
        if (state == ASSERT)
            last_byte <= data_in;
    end
endmodule
