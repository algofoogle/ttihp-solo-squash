/*
 * Copyright (c) 2024 Anton Maurovic
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Pinout (should match info.yaml):
//   # Inputs
//   ui[0]: pause       # Keep the game in a paused state while asserted.
//   ui[1]: new_game    # Reset game state.
//   ui[2]: down_key    # Move paddle down while asserted.
//   ui[3]: up_key      # Move paddle up while asserted.
//   ui[4]: extra_sel   # Select what the extra debug1&2 signals (top 2 bits of bidirectional port) are for.
//   ui[5]: ""          # Unused.
//   ui[6]: ""          # Unused.
//   ui[7]: ""          # Unused.
//   # Outputs
//   uo[0]: blue        # VGA signal: blue
//   uo[1]: green       # VGA signal: green
//   uo[2]: red         # VGA signal: red
//   uo[3]: hsync       # VGA signal: horizontal sync pulse
//   uo[4]: vsync       # VGA signal: vertical sync pulse
//   uo[5]: speaker     # Speaker tone
//   uo[6]: col0        # Asserted whenever VGA horizontal scan is at pixel 0
//   uo[7]: row0        # Asserted while the VGA vertical scan is at line 0
//   # Bidirectional pins
//   uio[0]: lzc_out[0]  # Leading zero counter experiment; count bit 0
//   uio[1]: lzc_out[1]  # Leading zero counter experiment; count bit 1
//   uio[2]: lzc_out[2]  # Leading zero counter experiment; count bit 2
//   uio[3]: lzc_out[3]  # Leading zero counter experiment; count bit 3
//   uio[4]: lzc_out[4]  # Leading zero counter experiment; count bit 4
//   uio[5]: lzc_all     # Leading zero counter experiment; asserted if lzc_out==24
//   uio[6]: debug1      # If extra_sel==0: UNregistered (direct) green signal; else: 'visible' signal.
//   uio[7]: debug2      # if extra_sel==0: UNregistered (direct) red signal; else: UNregistered blue signal.

module tt_um_algofoogle_solo_squash (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // List all unused inputs to prevent warnings:
    wire _unused = &{ena, ui_in[7:5], 1'b0};

    // Register the RGB outputs for stability:
    wire r, g, b;
    reg qr, qg, qb;
    always @(posedge clk) {qr,qg,qb} <= {r,g,b};
    assign uo_out[2:0] = {qr,qg,qb};
    //NOTE: MAYBE we should also care about registering hsync, vsync, and maybe speaker,
    // but I want to see what happens in the real ASIC if we don't.

    // Hard-wire bidir IOs to make them all outputs:
    assign uio_oe = 8'b11111111;
    // For other experimentation, output the UNregistered (direct combo logic)
    // red and green signals directly out via the upper 2 bits of the bidir IO port,
    // unless switched by pulling ui_in[4] high, in which case red and green are
    // replaced with blue and the 'visible' signal:
    assign uio_out[7] = ui_in[4] ? b : r;
    assign uio_out[6] = ui_in[4] ? visible : g;
    wire visible;

    // Input metastability avoidance. Do we really need this, for this design?
    // I'm playing it extra safe :)
    wire pause_n, new_game_n, down_key_n, up_key_n;
    input_sync pause    (.clk(clk), .d(~ui_in[0]), .q(pause_n   ));
    input_sync new_game (.clk(clk), .d(~ui_in[1]), .q(new_game_n));
    input_sync down_key (.clk(clk), .d(~ui_in[2]), .q(down_key_n));
    input_sync up_key   (.clk(clk), .d(~ui_in[3]), .q(up_key_n  ));

    wire [9:0] h;
    wire [9:0] v;
    wire [4:0] offset; // This is effectively a frame counter.

    // Just for fun, wire up a leading zero counter (with 24-bit input) that takes a concatenation of
    // offset's lower 4 bits, then v, then h.
    lzc24 lzc(.x({offset[3:0], v, h}), .z(uio_out[4:0]), .a(uio_out[5]));

    solo_squash game(
        // --- Inputs ---
        .clk        (clk),
        .reset      (~rst_n),       // Active HIGH reset needed here.
        // Active-low control inputs (but pulled low by the chip BY DEFAULT when not pressed, so inverted here):
        .pause_n    (pause_n),
        .new_game_n (new_game_n),
        .down_key_n (down_key_n),
        .up_key_n   (up_key_n),

        // --- Outputs ---
        .red        (r),
        .green      (g),
        .blue       (b),
        .hsync      (uo_out[3]),
        .vsync      (uo_out[4]),
        .speaker    (uo_out[5]),
        // Debug outputs:
        .col0       (uo_out[6]),
        .row0       (uo_out[7]),
        .h_out      (h),
        .v_out      (v),
        .offset_out (offset),
        .visible_out(visible)
    );

endmodule

// Basic double DFF metastability avoidance:
module input_sync(
    input wire clk,
    input wire d,
    output wire q
);
    reg dff1, dff2;
    assign q = dff2;
    always @(posedge clk) {dff2,dff1} <= {dff1,d};
endmodule
