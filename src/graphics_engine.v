`default_nettype none

module graphics_engine(
    output wire [1:0] r, g, b,
    input wire [9:0] x, 
    input wire [8:0] y,
    input wire frame_active, v_sync, 
    input wire rst_n
    );
    
    wire [5:0] sine_off_y, sine_bg_off_y;
    
    wire [5:0] overlay_rgb, sine_rgb, sine_bg_rgb, sine_rgb_dither, sine_bg_rgb_dither;
    wire overlay_active, overlay_text_active, sine_active, sine_bg_active;
    
    reg [9:0] ctr;
    wire [9:0] anim_x, anim_2x;
    
    always @(posedge v_sync, negedge rst_n) begin
        if (~rst_n)
            ctr <= 10'd0;
        else
            ctr <= ctr + 1'd1;
    end

    assign anim_x = x + ctr;
    assign anim_2x = x + {ctr[8:0], 1'd0};
    
    overlay_creator overlay_creator1 (
        .overlay_active(overlay_active), .text_active(overlay_text_active),
        .x(x), .y(y)
    );
    
    assign sine_off_y = y[8:4] - 5'd3;
    assign sine_bg_off_y = y[8:3] - 5'd2;
    
    sine_layer sine_layer1 (
        .sine_rgb(sine_rgb), 
        .x(anim_x[8:3]), 
        .y(sine_off_y[4:0])
    );
    
    sine_layer sine_layer2 (
        .sine_rgb(sine_bg_rgb), 
        .x(anim_2x[7:2]), 
        .y(sine_bg_off_y[4:0])
    );

    assign overlay_rgb = overlay_active ? {
      {overlay_text_active, ctr[7], overlay_text_active, ctr[6], overlay_text_active, ctr[5]}
    } : 6'b00_00_00;
    
    assign sine_rgb_dither = sine_rgb & {6{(x[0] ^ y[0])}};
    assign sine_bg_rgb_dither = sine_bg_rgb & {6{(x[0] & y[0])}};
    
    assign sine_active = |sine_rgb_dither;
    assign sine_bg_active = |sine_bg_rgb_dither;
    
    assign {r, g, b} = frame_active ? (
        overlay_active ? overlay_rgb : (
            sine_active ? sine_rgb_dither : (
                sine_bg_active ? sine_bg_rgb_dither : 6'b00_00_00
            )
        )
    ) : 6'b00_00_00;
    
    wire _unused = &{sine_off_y[5], sine_bg_off_y[5], anim_x[9], anim_x[2:0], anim_2x[9:8], anim_2x[1:0]};
endmodule