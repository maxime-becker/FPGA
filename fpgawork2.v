module vga_sync_test(
    input wire clk_in,
    input wire reset,
    input wire button,
    output reg r0,
    output reg b0,
    output reg g0,
    output wire h_sync,
    output wire v_sync,
    output wire led,
    output wire locked_led
);

    wire clk_sys;
    wire display_en;
    wire [9:0] h_count;
    wire [9:0] v_count;
    assign led = clk_sys;

    reg but = 1'b0;
    reg [5:0] index = 5;
    reg red;
    reg blue;
    reg green;

    reg [23:0] counter = 0;
    reg [7:0] taille = 10;
    reg [10:0] square_size = 120;
    reg [10:0] right_border = 30;
    reg [10:0] bottom_border = 30;

    localparam h_pixel_max = 640;
    localparam v_pixel_max = 480;
    localparam h_pixel_half = 320;
    localparam v_pixel_half = 240;

    always @(posedge clk_sys) begin
        counter <= counter + 1'b1;

        if (counter == 2*21 || counter == 219 || counter == 2*18 || 
            counter == 2*2 || counter == 24 || counter == 2*3 || 
            counter == 2*5 || counter == 26 || counter == 2*7 || 
            counter == 2*8 || counter == 29 || counter == 2*10) begin
            right_border <= (right_border + 1) % 1100;
            bottom_border <= (bottom_border + 1) % 530;
            taille <= taille + 1;
        end

        if (counter == 2*22 || counter == 2*21) begin
            index <= index + 1;
        end

        if (taille <= 40 + index[2:0] && taille >= 30 + index[2:0]) begin
            but <= 1;
        end else begin
            but <= 0;
        end

        if (~button) begin
            but <= 1;
        end else begin
            but <= 0;
        end

        if (display_en) begin
            if (but) begin
                if ((h_count <= h_pixel_half - 40 - taille) && 
                    (v_count <= v_pixel_half - 70 + taille)) begin
                    r0 <= 1;
                    b0 <= 1;
                    g0 <= index[5];
                end

                if ((v_count <= v_pixel_max - taille) && 
                    (h_count <= 12 + index[1])) begin
                    r0 <= index[4];
                    g0 <= ~index[4];
                    b0 <= index[4];
                end

                if ((v_count <= 70 + 2 * taille) && 
                    (h_count <= 50 + index)) begin
                    r0 <= ~index[0];
                    b0 <= index[2];
                    g0 <= index[2];
                end

                if ((h_count % (12 + index[1] + index[1]) == 0) && 
                    (v_count % 7 == 0)) begin
                    index <= index - 1;
                    r0 <= ~index[3];
                    g0 <= ~index[3];
                    b0 <= ~index[3];
                end
            end else begin
                r0 <= counter[10];
                b0 <= 0;
                g0 <= index[1];

                if (((h_count <= taille * 3 - index) && 
                     (v_count <= taille * 3 - index)) &&
                    ((h_count >= taille) && 
                     (v_count >= taille))) begin
                    r0 <= taille[3];
                    b0 <= index[1];
                    g0 <= taille[4];
                end else begin
                    r0 <= taille[0];
                    b0 <= ~taille[0];
                    g0 <= index[1];
                end

                if (((h_count >= taille * 3 - index) && 
                     (v_count >= taille * 3 - index)) &&
                    ((h_count <= taille) && 
                     (v_count <= taille))) begin
                    r0 <= index[1];
                    b0 <= index[1];
                    g0 <= taille[4];
                end
            end
        end else begin
            r0 <= 1;
            g0 <= 1;
            b0 <= 1;
        end
    end

    vga_sync vga_s(
        .clk_in(clk_in),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .clk_sys(clk_sys),
        .h_count(h_count),
        .v_count(v_count),
        .display_en(display_en),
        .locked(locked_led)
    );

endmodule