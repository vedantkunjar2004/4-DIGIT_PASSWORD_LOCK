
`default_nettype none
module lock(
    input  wire clk, rst, lever,
    input  wire [1:0] button_in,
    output reg  [5:0] LED
);
    parameter S_N=0, S_A=1, S_AA=2, S_AAB=3, S_AABB=4;

    wire btn_a_clean, btn_b_clean;

    debounce db_a (.btn(button_in[1]), .clk(clk), .rst(rst), .clean(btn_a_clean));
    debounce db_b (.btn(button_in[0]), .clk(clk), .rst(rst), .clean(btn_b_clean));

    reg a, b, c, d;
    wire a_in, b_in, invalid;
    reg be_asserted;
    reg [2:0] count;
    reg [2:0] ct, nt;

    always @(posedge clk) begin a <= btn_a_clean; b <= a; end
    always @(posedge clk) begin c <= btn_b_clean; d <= c; end

    assign a_in = a & (~b);
    assign b_in = c & (~d);

    always @(posedge clk or posedge rst) begin
        if (rst || (count == 4) || invalid) count <= 0;
        else if (a_in || b_in)              count <= count + 1;
        else                                count <= count;
    end

    always @(posedge clk or posedge rst) begin
        if (rst || invalid) begin ct <= S_N; be_asserted <= 0; end
        else begin
            ct <= nt;
            if (count == 4) be_asserted <= 1;
        end
    end

    always @(ct, a_in, b_in) begin
        case(ct)
            S_N:    if (a_in) nt = S_A; else nt = S_N;
            S_A:    if (a_in) nt = S_AA; else if (b_in) nt = S_N; else nt = S_A;
            S_AA:   if (b_in) nt = S_AAB; else if (a_in) nt = S_AA; else nt = S_AA;
            S_AAB:  if (b_in) nt = S_AABB; else if (a_in) nt = S_N; else nt = S_AAB;
            S_AABB: if (a_in) nt = S_A; else if (b_in) nt = S_N; else nt = S_AABB;
            default: nt = S_N;
        endcase
    end

    always @(*) begin
        LED[0] = ((count > 0 || be_asserted) && !lever);
        LED[1] = ((count > 1 || be_asserted) && !lever);
        LED[2] = ((count > 2 || be_asserted) && !lever);
        LED[3] = ((count > 3 || be_asserted) && !lever);
        LED[4] = ((ct == S_AABB) && lever && !rst);
        LED[5] = (lever && (ct != S_AABB) && !rst);
    end

    assign invalid = ((ct != S_AABB) && lever);

endmodule
