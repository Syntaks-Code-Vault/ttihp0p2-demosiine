`default_nettype none

module audio_engine(
    output wire audio,
    input wire clk, rst_n
    );

    //TODO: Eliminate NOTE_G3
    
    parameter [6:0] NOTE_B1 = 7'd100;
    parameter [6:0] NOTE_D2 = 7'd84;
    parameter [6:0] NOTE_E2 = 7'd74;
    parameter [6:0] NOTE_F2 = 7'd70;
    parameter [6:0] NOTE_G2 = 7'd62;
    parameter [6:0] NOTE_A2 = 7'd55;
    parameter [6:0] NOTE_C3 = 7'd47;
    parameter [6:0] NOTE_D3 = 7'd42;
    parameter [6:0] NOTE_E3 = 7'd37;
    parameter [6:0] NOTE_F3 = 7'd35;
    parameter [6:0] NOTE_G3 = 7'd31;
    parameter [6:0] NOTE_A3 = 7'd28;
    
    function [6:0] seq_lut (input [6:0] timestamp);
    begin
        if (~timestamp[6]) begin
            if (~timestamp[4]) begin
                case (timestamp[3:0])
                    4'h0, 
                    4'h1, 
                    4'h3, 
                    4'h4, 
                    4'h6, 
                    4'h7, 
                    4'h9, 
                    4'hA: seq_lut = NOTE_C3;
                    4'h2, 
                    4'h8, 
                    4'hE: seq_lut = NOTE_F2;
                    4'h5, 
                    4'hB: seq_lut = NOTE_A2;
                    4'hC: seq_lut = NOTE_D2;
                    4'hD: seq_lut = NOTE_E2;
                    4'hF: seq_lut = NOTE_G2;
                endcase
            end else begin
                case (timestamp[3:0])
                    4'h0, 
                    4'h1, 
                    4'h3, 
                    4'h4, 
                    4'h6, 
                    4'h7, 
                    4'h9, 
                    4'hA, 
                    4'hC, 
                    4'hD, 
                    4'hF: seq_lut = NOTE_G2;
                    4'h2, 
                    4'h8, 
                    4'hE: seq_lut = NOTE_D2;
                    4'h5, 
                    4'hB: seq_lut = NOTE_B1;
                endcase
            end
        end else begin
            if (~timestamp[2]) begin
                case (timestamp[1:0])
                    2'h0, 
                    2'h1: seq_lut = NOTE_A2;
                    2'h2: seq_lut = NOTE_A3;
                    2'h3: seq_lut = NOTE_F2;
                endcase
            end else begin
                if (~(timestamp[4] & timestamp[3])) begin
                    case (timestamp[1:0])
                        2'h0: seq_lut = NOTE_C3;
                        2'h1: seq_lut = NOTE_E3;
                        2'h2, 
                        2'h3: seq_lut = NOTE_D3;
                    endcase
                end else begin
                    case (timestamp[1:0])
                        2'h0, 
                        2'h2: seq_lut = NOTE_D3;
                        2'h1: seq_lut = NOTE_F3;
                        2'h3: seq_lut = NOTE_C3;
                    endcase
                end
            end
        end
    end
    endfunction
    
    wire synth_clk, seq_clk, seq_active;
    reg [4:0] seq_ctr;
    reg [6:0] seq_time;
    wire [6:0] seq_hp;
    
    reg [17:0] counter;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
          counter <= 18'd0;
        else
          counter <= counter + 1;
    end
    
    assign synth_clk = counter[10]; 
    assign seq_clk = counter[17];
    
    always @(posedge seq_clk or negedge rst_n) begin
        if (~rst_n) begin
            seq_ctr <= 5'd0;
            seq_time <= 7'd0;
        end else begin
            if (seq_ctr == 5'd19) begin
                seq_ctr <= 5'd0;
                seq_time <= seq_time + 1;
            end else
                seq_ctr <= seq_ctr + 5'd1;
        end
    end
    
    assign seq_hp = seq_lut(seq_time);
    assign seq_active = seq_ctr < 5'd10;
    
    freq_synth freq_synth1 (
        .audio(audio),
        .synth_clk(synth_clk), .rst_n(rst_n),
        .hp(seq_hp),
        .active(seq_active)
    );
    
    wire _unused = ;
endmodule