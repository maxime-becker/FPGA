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
wire [9:0] h_count; // Coordonnées horizontales
wire [9:0] v_count; // Coordonnées verticales
assign led = clk_sys;

reg index = 1'b0;
reg [80:0] counter = 1'b0;
reg [4:0] taille = 0;

reg red = 1'b0;
reg green = 1'b0;
reg blue = 1'b0;

localparam h_pixel_max = 640;
localparam v_pixel_max = 480;
localparam h_pixel_half = 320;
localparam v_pixel_half = 240;

always @(posedge clk_sys) begin
    if(v_count == 0)
	begin 
		counter <= counter + 1'b1;
	end
	if(counter[80])
		begin
			green <= green + 1'b1 ;
			red <= red + 1'b0 ;
			red <= blue + 1'b1 ;
			taille <= taille +1; 
		end
	if(counter[30])
		begin
			green <= green + 1'b0 ;
			red <= red + 1'b1 ;
			blue <= blue + 1'b1 ;
		end
	if(counter[10])
		begin
			green <= green + 1'b1 ;
			red <= red + 1'b1 ;
			blue <= blue + 1'b0 ;
			
		end
    if (display_en) 
	begin
		r0<=red;
		g0 <=green;
		b0 <= blue;
		
		if((h_count <= h_pixel_half-40+taille)&&(v_count <= v_pixel_half-70+taille))
			begin
				r0 <= 1;
				b0 <= 0;
				g0 <= 0;
			end
		if((v_count <= v_pixel_max - taille)&&(h_count <= 12))
			begin
				r0 <= 1;
				b0 <= 1;
				g0 <= 0;
			end
		if((v_count <= 1+taille)&&(h_count <= 1+taille))
			begin
				r0 <= 0;
				b0 <= 0;
				g0 <= 1;
			end
        if ((h_count % 12 == 0) && (v_count % 7 == 0))
      	    begin
		index = index + 1'b1;
       red <= index;
		green <= index;
		blue <= index;
            end
    	else 
	    	begin
       red <= index;
		green <= index;
		blue <= index;
    	    end
	end
end


// Instanciation du module VGA Sync
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
