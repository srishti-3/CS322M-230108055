module master_fsm(
    input  wire       clk,
    input  wire       rst,  
    input  wire       ack,
    output reg        req,
    output reg [7:0]  data,
    output reg        done
);

 
    parameter IDLE   = 3'b000,
              SEND   = 3'b001,
              WAIT_A = 3'b010,
              DROP   = 3'b011,
              NEXT   = 3'b100,
              FINISH = 3'b101;

    reg [2:0] state, next_state;
    reg [1:0] byte_idx; 
   
    reg [7:0] byte_mem [0:3];
    initial begin
        byte_mem[0] = 8'hA0;
        byte_mem[1] = 8'hA1;
        byte_mem[2] = 8'hA2;
        byte_mem[3] = 8'hA3;
    end

   
    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            byte_idx <= 2'b00;
        end else begin
            state <= next_state;
        end
    end

   
    always @(*) begin
      
        req   = 1'b0;
        data  = byte_mem[byte_idx];
        done  = 1'b0;
        next_state = state;

        case (state)
            IDLE:   next_state = SEND;

            SEND: begin
                req = 1'b1;
                next_state = WAIT_A;
            end

            WAIT_A: begin
                req = 1'b1;
                if (ack) next_state = DROP;
            end

            DROP: begin
               
                if (!ack) next_state = NEXT;
            end

            NEXT: begin
                if (byte_idx == 2'b11) next_state = FINISH;
                else next_state = SEND;
            end

            FINISH: begin
                done = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    
    always @(posedge clk) begin
        if (rst)
            byte_idx <= 2'b00;
        else if (state == NEXT) begin
            if (byte_idx != 2'b11)
                byte_idx <= byte_idx + 1'b1;
            else
                byte_idx <= 2'b00; 
        end
    end
endmodule
