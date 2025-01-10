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
reg [4:0]index = 5;

reg red;
reg blue;
reg green;

reg [12:0] counter = 1'b0;
reg [9:0] taille = 10;
reg [10:0]square_size = 120;
reg [10:0]right_border = 30;
reg [10:0]bottom_border = 30;
localparam h_pixel_max = 640;
localparam v_pixel_max = 480;
localparam h_pixel_half = 320;
localparam v_pixel_half = 240;

always @(posedge clk_sys) 
	begin
    	if(v_count == 0)
			begin 
       			counter <= counter + 1'b1;
				
			end
		if(counter[12])
			begin
				right_border <= (right_border + 1)%1100;
				bottom_border <= (bottom_border + 1)%530;
				index <= index +1;
				taille <= taille +1;
			end
    	if (display_en) 
			begin
			if ((h_count >= 50 && h_count <= 150) && (v_count >= 300 && v_count <= 400)) begin
        // Corps du château
        red = 4'h8;
        green = 4'h8;
        blue = 4'h8;
    end else if (((h_count >= 50 && h_count <= 80) || (h_count >= 120 && h_count <= 150)) 
                 && (v_count >= 250 && v_count <= 300)) begin
        // Tours du château
        red = 4'h8;
        green = 4'h8;
        blue = 4'h8;
    end

    // Dessin du logo Superman (triangle simple avec un "S")
    else if ((h_count >= 200 && h_count <= 300) && (v_count >= 100 && v_count <= 200)) begin
        // Triangle extérieur rouge
        if (h_count - 200 <= v_count - 100 && 300 - h_count <= v_count - 100) begin
            red = 4'hF;
            green = 4'h0;
            blue = 4'h0;
        end
        // "S" stylisé au centre
        if ((h_count >= 230 && h_count <= 270) && (v_count >= 130 && v_count <= 170)) begin
            red = 4'hF;
            green = 4'hF;
            blue = 4'h0;
        end
    end

    // Dessin de l'avion
    else if ((h_count >= 350 && h_count <= 450) && (v_count >= 50 && v_count <= 100)) begin
        // Corps principal
        red = 4'h0;
        green = 4'h0;
        blue = 4'hF;
    end else if ((h_count >= 370 && h_count <= 430) && (v_count >= 30 && v_count <= 50)) begin
        // Aile supérieure
        red = 4'h0;
        green = 4'h0;
        blue = 4'hF;
    end else if ((h_count >= 370 && h_count <= 430) && (v_count >= 100 && v_count <= 120)) begin
        // Aile inférieure
        red = 4'h0;
        green = 4'h0;
        blue = 4'hF;
    end			
				r0<=red;
				b0<=blue;
				g0<=green;
			end
    	else 
	    	begin
       			r0 <= 1;
				g0 <= 1;
				b0 <= 0;
    	    end
	end
vga_sync vga_s(
    .clk_in(clk_in),         // Horloge d'entrée (12 MHz)
    .reset(reset),           // Signal de réinitialisation
    .h_sync(h_sync),
    .v_sync(v_sync),
    .clk_sys(clk_sys),       // Horloge générée par le PLL (25.125 MHz)
    .h_count(h_count),
    .v_count(v_count),
    .display_en(display_en), // Signal actif dans la zone de pixels
    .locked(locked_led)      // Indique si le PLL est verrouillé
);

endmodule
