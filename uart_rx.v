module uart_rx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output reg [7:0] data_out,
    output reg data_valid
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_BIT = CLKS_PER_BIT / 2;

    localparam [1:0] S_IDLE  = 2'd0;
    localparam [1:0] S_START = 2'd1;
    localparam [1:0] S_DATA  = 2'd2;
    localparam [1:0] S_STOP  = 2'd3;

    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] rx_shift;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_shift <= 0;
            data_out <= 0;
            data_valid <= 1'b0;
        end
        else begin
            data_valid <= 1'b0;

            case (state)

                S_IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;

                    if (rx == 1'b0)
                        state <= S_START;
                end

                S_START: begin
                    if (clk_count < HALF_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end
                    else begin
                        clk_count <= 0;

                        if (rx == 1'b0)
                            state <= S_DATA;
                        else
                            state <= S_IDLE;
                    end
                end

                S_DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end
                    else begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;

                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else
                            state <= S_STOP;
                    end
                end

                S_STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end
                    else begin
                        clk_count <= 0;

                        if (rx == 1'b1) begin
                            data_out <= rx_shift;
                            data_valid <= 1'b1;
                        end

                        state <= S_IDLE;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule
