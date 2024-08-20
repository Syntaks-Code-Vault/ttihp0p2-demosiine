`default_nettype none

module freq_synth(
    output wire audio,
    input wire synth_clk, rst_n,
    input wire [6:0] hp,
    input wire active
    );
    
    reg audio_reg;
    reg [6:0] hp_ctr;
    always @ (posedge synth_clk) begin
        if (~active | ~rst_n) begin
            audio_reg <= 1'd0;  
            hp_ctr <= 7'd1;
        end else begin
            if (hp_ctr == hp) begin
                hp_ctr <= 7'd1;
                audio_reg <= ~audio_reg;
            end else
                hp_ctr <= hp_ctr + 1'd1;
        end
    end
    
    assign audio = audio_reg & active;
    
    wire _unused = 0;
endmodule
