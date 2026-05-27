`default_nettype none
module debounce(
    input  wire btn, clk, rst,
    output reg  clean
);
    localparam s0=0, s1=1, s2=2, s3=3;
    reg [1:0] ps, ns;
    reg [20:0] count;        // 21 bits — enough for 2,000,000
    reg start_timer, stop_timer;
       
    always @(posedge clk or posedge rst) begin
        if (rst) ps <= s0;
        else     ps <= ns;
    end

    always @(posedge clk or posedge rst) begin
        if (rst || stop_timer) count <= 0;
        else if (start_timer)  count <= count + 1;
        else                   count <= 0;
    end

    always @(*) begin
        ns = ps;
        start_timer = 0;
        stop_timer  = 0;
        case(ps)
            s0: begin
                clean = 0;
                if (btn) ns = s1;
            end
            s1: begin
                clean = 0;
                if (!btn) ns = s0;
                else begin
                    if (count == 10) begin   
                    stop_timer = 1;
                        ns = s2;
                    end else
                        start_timer = 1;
                end
            end
            s2: begin
                clean = 1;
                if (!btn) ns = s3;
            end
            s3: begin
                clean = 1;
                if (btn) ns = s2;
                else begin
                    if (count == 10) begin   
                    stop_timer = 1;
                        ns = s0;
                    end else begin
                        start_timer = 1;
                        ns = s3;
                    end
                end
            end
            default: ns = s0;
        endcase
    end
endmodule
