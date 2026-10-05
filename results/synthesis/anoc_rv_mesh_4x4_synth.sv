`timescale 1ns/1ps

module anoc_rv_mesh_4x4_synth #(
    parameter int DATA_WIDTH=128,
    parameter int COORD_WIDTH=4,
    parameter int NUM_PORTS=5
)(
    input logic clk, rst,
    input logic [16*NUM_PORTS*DATA_WIDTH-1:0] data_in,
    input logic [16*NUM_PORTS*COORD_WIDTH-1:0] dest_x,
    input logic [16*NUM_PORTS*COORD_WIDTH-1:0] dest_y,
    input logic [16*NUM_PORTS-1:0] valid_in,
    output logic [16*NUM_PORTS-1:0] ready_in,
    input logic [16*NUM_PORTS-1:0] ready_out,
    output logic [16*NUM_PORTS*DATA_WIDTH-1:0] data_out,
    output logic [16*NUM_PORTS-1:0] valid_out
);

logic [5*DATA_WIDTH-1:0] din_0, dout_0;
logic [5*COORD_WIDTH-1:0] dxin_0, dyin_0, dxout_0, dyout_0;
logic [5-1:0] vin_0, rin_0, rout_0, vout_0;
logic [5*DATA_WIDTH-1:0] din_1, dout_1;
logic [5*COORD_WIDTH-1:0] dxin_1, dyin_1, dxout_1, dyout_1;
logic [5-1:0] vin_1, rin_1, rout_1, vout_1;
logic [5*DATA_WIDTH-1:0] din_2, dout_2;
logic [5*COORD_WIDTH-1:0] dxin_2, dyin_2, dxout_2, dyout_2;
logic [5-1:0] vin_2, rin_2, rout_2, vout_2;
logic [5*DATA_WIDTH-1:0] din_3, dout_3;
logic [5*COORD_WIDTH-1:0] dxin_3, dyin_3, dxout_3, dyout_3;
logic [5-1:0] vin_3, rin_3, rout_3, vout_3;
logic [5*DATA_WIDTH-1:0] din_4, dout_4;
logic [5*COORD_WIDTH-1:0] dxin_4, dyin_4, dxout_4, dyout_4;
logic [5-1:0] vin_4, rin_4, rout_4, vout_4;
logic [5*DATA_WIDTH-1:0] din_5, dout_5;
logic [5*COORD_WIDTH-1:0] dxin_5, dyin_5, dxout_5, dyout_5;
logic [5-1:0] vin_5, rin_5, rout_5, vout_5;
logic [5*DATA_WIDTH-1:0] din_6, dout_6;
logic [5*COORD_WIDTH-1:0] dxin_6, dyin_6, dxout_6, dyout_6;
logic [5-1:0] vin_6, rin_6, rout_6, vout_6;
logic [5*DATA_WIDTH-1:0] din_7, dout_7;
logic [5*COORD_WIDTH-1:0] dxin_7, dyin_7, dxout_7, dyout_7;
logic [5-1:0] vin_7, rin_7, rout_7, vout_7;
logic [5*DATA_WIDTH-1:0] din_8, dout_8;
logic [5*COORD_WIDTH-1:0] dxin_8, dyin_8, dxout_8, dyout_8;
logic [5-1:0] vin_8, rin_8, rout_8, vout_8;
logic [5*DATA_WIDTH-1:0] din_9, dout_9;
logic [5*COORD_WIDTH-1:0] dxin_9, dyin_9, dxout_9, dyout_9;
logic [5-1:0] vin_9, rin_9, rout_9, vout_9;
logic [5*DATA_WIDTH-1:0] din_10, dout_10;
logic [5*COORD_WIDTH-1:0] dxin_10, dyin_10, dxout_10, dyout_10;
logic [5-1:0] vin_10, rin_10, rout_10, vout_10;
logic [5*DATA_WIDTH-1:0] din_11, dout_11;
logic [5*COORD_WIDTH-1:0] dxin_11, dyin_11, dxout_11, dyout_11;
logic [5-1:0] vin_11, rin_11, rout_11, vout_11;
logic [5*DATA_WIDTH-1:0] din_12, dout_12;
logic [5*COORD_WIDTH-1:0] dxin_12, dyin_12, dxout_12, dyout_12;
logic [5-1:0] vin_12, rin_12, rout_12, vout_12;
logic [5*DATA_WIDTH-1:0] din_13, dout_13;
logic [5*COORD_WIDTH-1:0] dxin_13, dyin_13, dxout_13, dyout_13;
logic [5-1:0] vin_13, rin_13, rout_13, vout_13;
logic [5*DATA_WIDTH-1:0] din_14, dout_14;
logic [5*COORD_WIDTH-1:0] dxin_14, dyin_14, dxout_14, dyout_14;
logic [5-1:0] vin_14, rin_14, rout_14, vout_14;
logic [5*DATA_WIDTH-1:0] din_15, dout_15;
logic [5*COORD_WIDTH-1:0] dxin_15, dyin_15, dxout_15, dyout_15;
logic [5-1:0] vin_15, rin_15, rout_15, vout_15;

assign din_0[DATA_WIDTH-1:0] = data_in[127:0];
assign dxin_0[COORD_WIDTH-1:0] = dest_x[3:0];
assign dyin_0[COORD_WIDTH-1:0] = dest_y[3:0];
assign vin_0[0] = valid_in[0];
assign rout_0[0] = ready_out[0];
assign ready_in[0] = rin_0[0];
assign data_out[127:0] = dout_0[W-1:0];
assign valid_out[0] = vout_0[0];
assign ready_in[1] = 1'b0;
assign data_out[255:128] = '0;
assign valid_out[1] = 1'b0;
assign ready_in[2] = 1'b0;
assign data_out[383:256] = '0;
assign valid_out[2] = 1'b0;
assign ready_in[3] = 1'b0;
assign data_out[511:384] = '0;
assign valid_out[3] = 1'b0;
assign ready_in[4] = 1'b0;
assign data_out[639:512] = '0;
assign valid_out[4] = 1'b0;
assign din_1[DATA_WIDTH-1:0] = data_in[767:640];
assign dxin_1[COORD_WIDTH-1:0] = dest_x[23:20];
assign dyin_1[COORD_WIDTH-1:0] = dest_y[23:20];
assign vin_1[0] = valid_in[5];
assign rout_1[0] = ready_out[5];
assign ready_in[5] = rin_1[0];
assign data_out[767:640] = dout_1[W-1:0];
assign valid_out[5] = vout_1[0];
assign ready_in[6] = 1'b0;
assign data_out[895:768] = '0;
assign valid_out[6] = 1'b0;
assign ready_in[7] = 1'b0;
assign data_out[1023:896] = '0;
assign valid_out[7] = 1'b0;
assign ready_in[8] = 1'b0;
assign data_out[1151:1024] = '0;
assign valid_out[8] = 1'b0;
assign ready_in[9] = 1'b0;
assign data_out[1279:1152] = '0;
assign valid_out[9] = 1'b0;
assign din_2[DATA_WIDTH-1:0] = data_in[1407:1280];
assign dxin_2[COORD_WIDTH-1:0] = dest_x[43:40];
assign dyin_2[COORD_WIDTH-1:0] = dest_y[43:40];
assign vin_2[0] = valid_in[10];
assign rout_2[0] = ready_out[10];
assign ready_in[10] = rin_2[0];
assign data_out[1407:1280] = dout_2[W-1:0];
assign valid_out[10] = vout_2[0];
assign ready_in[11] = 1'b0;
assign data_out[1535:1408] = '0;
assign valid_out[11] = 1'b0;
assign ready_in[12] = 1'b0;
assign data_out[1663:1536] = '0;
assign valid_out[12] = 1'b0;
assign ready_in[13] = 1'b0;
assign data_out[1791:1664] = '0;
assign valid_out[13] = 1'b0;
assign ready_in[14] = 1'b0;
assign data_out[1919:1792] = '0;
assign valid_out[14] = 1'b0;
assign din_3[DATA_WIDTH-1:0] = data_in[2047:1920];
assign dxin_3[COORD_WIDTH-1:0] = dest_x[63:60];
assign dyin_3[COORD_WIDTH-1:0] = dest_y[63:60];
assign vin_3[0] = valid_in[15];
assign rout_3[0] = ready_out[15];
assign ready_in[15] = rin_3[0];
assign data_out[2047:1920] = dout_3[W-1:0];
assign valid_out[15] = vout_3[0];
assign ready_in[16] = 1'b0;
assign data_out[2175:2048] = '0;
assign valid_out[16] = 1'b0;
assign ready_in[17] = 1'b0;
assign data_out[2303:2176] = '0;
assign valid_out[17] = 1'b0;
assign ready_in[18] = 1'b0;
assign data_out[2431:2304] = '0;
assign valid_out[18] = 1'b0;
assign ready_in[19] = 1'b0;
assign data_out[2559:2432] = '0;
assign valid_out[19] = 1'b0;
assign din_4[DATA_WIDTH-1:0] = data_in[2687:2560];
assign dxin_4[COORD_WIDTH-1:0] = dest_x[83:80];
assign dyin_4[COORD_WIDTH-1:0] = dest_y[83:80];
assign vin_4[0] = valid_in[20];
assign rout_4[0] = ready_out[20];
assign ready_in[20] = rin_4[0];
assign data_out[2687:2560] = dout_4[W-1:0];
assign valid_out[20] = vout_4[0];
assign ready_in[21] = 1'b0;
assign data_out[2815:2688] = '0;
assign valid_out[21] = 1'b0;
assign ready_in[22] = 1'b0;
assign data_out[2943:2816] = '0;
assign valid_out[22] = 1'b0;
assign ready_in[23] = 1'b0;
assign data_out[3071:2944] = '0;
assign valid_out[23] = 1'b0;
assign ready_in[24] = 1'b0;
assign data_out[3199:3072] = '0;
assign valid_out[24] = 1'b0;
assign din_5[DATA_WIDTH-1:0] = data_in[3327:3200];
assign dxin_5[COORD_WIDTH-1:0] = dest_x[103:100];
assign dyin_5[COORD_WIDTH-1:0] = dest_y[103:100];
assign vin_5[0] = valid_in[25];
assign rout_5[0] = ready_out[25];
assign ready_in[25] = rin_5[0];
assign data_out[3327:3200] = dout_5[W-1:0];
assign valid_out[25] = vout_5[0];
assign ready_in[26] = 1'b0;
assign data_out[3455:3328] = '0;
assign valid_out[26] = 1'b0;
assign ready_in[27] = 1'b0;
assign data_out[3583:3456] = '0;
assign valid_out[27] = 1'b0;
assign ready_in[28] = 1'b0;
assign data_out[3711:3584] = '0;
assign valid_out[28] = 1'b0;
assign ready_in[29] = 1'b0;
assign data_out[3839:3712] = '0;
assign valid_out[29] = 1'b0;
assign din_6[DATA_WIDTH-1:0] = data_in[3967:3840];
assign dxin_6[COORD_WIDTH-1:0] = dest_x[123:120];
assign dyin_6[COORD_WIDTH-1:0] = dest_y[123:120];
assign vin_6[0] = valid_in[30];
assign rout_6[0] = ready_out[30];
assign ready_in[30] = rin_6[0];
assign data_out[3967:3840] = dout_6[W-1:0];
assign valid_out[30] = vout_6[0];
assign ready_in[31] = 1'b0;
assign data_out[4095:3968] = '0;
assign valid_out[31] = 1'b0;
assign ready_in[32] = 1'b0;
assign data_out[4223:4096] = '0;
assign valid_out[32] = 1'b0;
assign ready_in[33] = 1'b0;
assign data_out[4351:4224] = '0;
assign valid_out[33] = 1'b0;
assign ready_in[34] = 1'b0;
assign data_out[4479:4352] = '0;
assign valid_out[34] = 1'b0;
assign din_7[DATA_WIDTH-1:0] = data_in[4607:4480];
assign dxin_7[COORD_WIDTH-1:0] = dest_x[143:140];
assign dyin_7[COORD_WIDTH-1:0] = dest_y[143:140];
assign vin_7[0] = valid_in[35];
assign rout_7[0] = ready_out[35];
assign ready_in[35] = rin_7[0];
assign data_out[4607:4480] = dout_7[W-1:0];
assign valid_out[35] = vout_7[0];
assign ready_in[36] = 1'b0;
assign data_out[4735:4608] = '0;
assign valid_out[36] = 1'b0;
assign ready_in[37] = 1'b0;
assign data_out[4863:4736] = '0;
assign valid_out[37] = 1'b0;
assign ready_in[38] = 1'b0;
assign data_out[4991:4864] = '0;
assign valid_out[38] = 1'b0;
assign ready_in[39] = 1'b0;
assign data_out[5119:4992] = '0;
assign valid_out[39] = 1'b0;
assign din_8[DATA_WIDTH-1:0] = data_in[5247:5120];
assign dxin_8[COORD_WIDTH-1:0] = dest_x[163:160];
assign dyin_8[COORD_WIDTH-1:0] = dest_y[163:160];
assign vin_8[0] = valid_in[40];
assign rout_8[0] = ready_out[40];
assign ready_in[40] = rin_8[0];
assign data_out[5247:5120] = dout_8[W-1:0];
assign valid_out[40] = vout_8[0];
assign ready_in[41] = 1'b0;
assign data_out[5375:5248] = '0;
assign valid_out[41] = 1'b0;
assign ready_in[42] = 1'b0;
assign data_out[5503:5376] = '0;
assign valid_out[42] = 1'b0;
assign ready_in[43] = 1'b0;
assign data_out[5631:5504] = '0;
assign valid_out[43] = 1'b0;
assign ready_in[44] = 1'b0;
assign data_out[5759:5632] = '0;
assign valid_out[44] = 1'b0;
assign din_9[DATA_WIDTH-1:0] = data_in[5887:5760];
assign dxin_9[COORD_WIDTH-1:0] = dest_x[183:180];
assign dyin_9[COORD_WIDTH-1:0] = dest_y[183:180];
assign vin_9[0] = valid_in[45];
assign rout_9[0] = ready_out[45];
assign ready_in[45] = rin_9[0];
assign data_out[5887:5760] = dout_9[W-1:0];
assign valid_out[45] = vout_9[0];
assign ready_in[46] = 1'b0;
assign data_out[6015:5888] = '0;
assign valid_out[46] = 1'b0;
assign ready_in[47] = 1'b0;
assign data_out[6143:6016] = '0;
assign valid_out[47] = 1'b0;
assign ready_in[48] = 1'b0;
assign data_out[6271:6144] = '0;
assign valid_out[48] = 1'b0;
assign ready_in[49] = 1'b0;
assign data_out[6399:6272] = '0;
assign valid_out[49] = 1'b0;
assign din_10[DATA_WIDTH-1:0] = data_in[6527:6400];
assign dxin_10[COORD_WIDTH-1:0] = dest_x[203:200];
assign dyin_10[COORD_WIDTH-1:0] = dest_y[203:200];
assign vin_10[0] = valid_in[50];
assign rout_10[0] = ready_out[50];
assign ready_in[50] = rin_10[0];
assign data_out[6527:6400] = dout_10[W-1:0];
assign valid_out[50] = vout_10[0];
assign ready_in[51] = 1'b0;
assign data_out[6655:6528] = '0;
assign valid_out[51] = 1'b0;
assign ready_in[52] = 1'b0;
assign data_out[6783:6656] = '0;
assign valid_out[52] = 1'b0;
assign ready_in[53] = 1'b0;
assign data_out[6911:6784] = '0;
assign valid_out[53] = 1'b0;
assign ready_in[54] = 1'b0;
assign data_out[7039:6912] = '0;
assign valid_out[54] = 1'b0;
assign din_11[DATA_WIDTH-1:0] = data_in[7167:7040];
assign dxin_11[COORD_WIDTH-1:0] = dest_x[223:220];
assign dyin_11[COORD_WIDTH-1:0] = dest_y[223:220];
assign vin_11[0] = valid_in[55];
assign rout_11[0] = ready_out[55];
assign ready_in[55] = rin_11[0];
assign data_out[7167:7040] = dout_11[W-1:0];
assign valid_out[55] = vout_11[0];
assign ready_in[56] = 1'b0;
assign data_out[7295:7168] = '0;
assign valid_out[56] = 1'b0;
assign ready_in[57] = 1'b0;
assign data_out[7423:7296] = '0;
assign valid_out[57] = 1'b0;
assign ready_in[58] = 1'b0;
assign data_out[7551:7424] = '0;
assign valid_out[58] = 1'b0;
assign ready_in[59] = 1'b0;
assign data_out[7679:7552] = '0;
assign valid_out[59] = 1'b0;
assign din_12[DATA_WIDTH-1:0] = data_in[7807:7680];
assign dxin_12[COORD_WIDTH-1:0] = dest_x[243:240];
assign dyin_12[COORD_WIDTH-1:0] = dest_y[243:240];
assign vin_12[0] = valid_in[60];
assign rout_12[0] = ready_out[60];
assign ready_in[60] = rin_12[0];
assign data_out[7807:7680] = dout_12[W-1:0];
assign valid_out[60] = vout_12[0];
assign ready_in[61] = 1'b0;
assign data_out[7935:7808] = '0;
assign valid_out[61] = 1'b0;
assign ready_in[62] = 1'b0;
assign data_out[8063:7936] = '0;
assign valid_out[62] = 1'b0;
assign ready_in[63] = 1'b0;
assign data_out[8191:8064] = '0;
assign valid_out[63] = 1'b0;
assign ready_in[64] = 1'b0;
assign data_out[8319:8192] = '0;
assign valid_out[64] = 1'b0;
assign din_13[DATA_WIDTH-1:0] = data_in[8447:8320];
assign dxin_13[COORD_WIDTH-1:0] = dest_x[263:260];
assign dyin_13[COORD_WIDTH-1:0] = dest_y[263:260];
assign vin_13[0] = valid_in[65];
assign rout_13[0] = ready_out[65];
assign ready_in[65] = rin_13[0];
assign data_out[8447:8320] = dout_13[W-1:0];
assign valid_out[65] = vout_13[0];
assign ready_in[66] = 1'b0;
assign data_out[8575:8448] = '0;
assign valid_out[66] = 1'b0;
assign ready_in[67] = 1'b0;
assign data_out[8703:8576] = '0;
assign valid_out[67] = 1'b0;
assign ready_in[68] = 1'b0;
assign data_out[8831:8704] = '0;
assign valid_out[68] = 1'b0;
assign ready_in[69] = 1'b0;
assign data_out[8959:8832] = '0;
assign valid_out[69] = 1'b0;
assign din_14[DATA_WIDTH-1:0] = data_in[9087:8960];
assign dxin_14[COORD_WIDTH-1:0] = dest_x[283:280];
assign dyin_14[COORD_WIDTH-1:0] = dest_y[283:280];
assign vin_14[0] = valid_in[70];
assign rout_14[0] = ready_out[70];
assign ready_in[70] = rin_14[0];
assign data_out[9087:8960] = dout_14[W-1:0];
assign valid_out[70] = vout_14[0];
assign ready_in[71] = 1'b0;
assign data_out[9215:9088] = '0;
assign valid_out[71] = 1'b0;
assign ready_in[72] = 1'b0;
assign data_out[9343:9216] = '0;
assign valid_out[72] = 1'b0;
assign ready_in[73] = 1'b0;
assign data_out[9471:9344] = '0;
assign valid_out[73] = 1'b0;
assign ready_in[74] = 1'b0;
assign data_out[9599:9472] = '0;
assign valid_out[74] = 1'b0;
assign din_15[DATA_WIDTH-1:0] = data_in[9727:9600];
assign dxin_15[COORD_WIDTH-1:0] = dest_x[303:300];
assign dyin_15[COORD_WIDTH-1:0] = dest_y[303:300];
assign vin_15[0] = valid_in[75];
assign rout_15[0] = ready_out[75];
assign ready_in[75] = rin_15[0];
assign data_out[9727:9600] = dout_15[W-1:0];
assign valid_out[75] = vout_15[0];
assign ready_in[76] = 1'b0;
assign data_out[9855:9728] = '0;
assign valid_out[76] = 1'b0;
assign ready_in[77] = 1'b0;
assign data_out[9983:9856] = '0;
assign valid_out[77] = 1'b0;
assign ready_in[78] = 1'b0;
assign data_out[10111:9984] = '0;
assign valid_out[78] = 1'b0;
assign ready_in[79] = 1'b0;
assign data_out[10239:10112] = '0;
assign valid_out[79] = 1'b0;

assign din_0[255:128] = dout_4[383:256];
assign dxin_0[7:4] = dxout_4[11:8];
assign dyin_0[7:4] = dyout_4[11:8];
assign vin_0[1] = vout_4[2];
assign rout_4[2] = rin_0[1];
assign din_0[383:256] = '0;
assign dxin_0[11:8] = '0;
assign dyin_0[11:8] = '0;
assign vin_0[2] = 1'b0;
assign rout_0[2] = 1'b0;
assign din_0[511:384] = dout_1[639:512];
assign dxin_0[15:12] = dxout_1[19:16];
assign dyin_0[15:12] = dyout_1[19:16];
assign vin_0[3] = vout_1[4];
assign rout_1[4] = rin_0[3];
assign din_0[639:512] = '0;
assign dxin_0[19:16] = '0;
assign dyin_0[19:16] = '0;
assign vin_0[4] = 1'b0;
assign rout_0[4] = 1'b0;
assign din_1[255:128] = dout_5[383:256];
assign dxin_1[7:4] = dxout_5[11:8];
assign dyin_1[7:4] = dyout_5[11:8];
assign vin_1[1] = vout_5[2];
assign rout_5[2] = rin_1[1];
assign din_1[383:256] = '0;
assign dxin_1[11:8] = '0;
assign dyin_1[11:8] = '0;
assign vin_1[2] = 1'b0;
assign rout_1[2] = 1'b0;
assign din_1[511:384] = dout_2[639:512];
assign dxin_1[15:12] = dxout_2[19:16];
assign dyin_1[15:12] = dyout_2[19:16];
assign vin_1[3] = vout_2[4];
assign rout_2[4] = rin_1[3];
assign din_1[639:512] = dout_0[511:384];
assign dxin_1[19:16] = dxout_0[15:12];
assign dyin_1[19:16] = dyout_0[15:12];
assign vin_1[4] = vout_0[3];
assign rout_0[3] = rin_1[4];
assign din_2[255:128] = dout_6[383:256];
assign dxin_2[7:4] = dxout_6[11:8];
assign dyin_2[7:4] = dyout_6[11:8];
assign vin_2[1] = vout_6[2];
assign rout_6[2] = rin_2[1];
assign din_2[383:256] = '0;
assign dxin_2[11:8] = '0;
assign dyin_2[11:8] = '0;
assign vin_2[2] = 1'b0;
assign rout_2[2] = 1'b0;
assign din_2[511:384] = dout_3[639:512];
assign dxin_2[15:12] = dxout_3[19:16];
assign dyin_2[15:12] = dyout_3[19:16];
assign vin_2[3] = vout_3[4];
assign rout_3[4] = rin_2[3];
assign din_2[639:512] = dout_1[511:384];
assign dxin_2[19:16] = dxout_1[15:12];
assign dyin_2[19:16] = dyout_1[15:12];
assign vin_2[4] = vout_1[3];
assign rout_1[3] = rin_2[4];
assign din_3[255:128] = dout_7[383:256];
assign dxin_3[7:4] = dxout_7[11:8];
assign dyin_3[7:4] = dyout_7[11:8];
assign vin_3[1] = vout_7[2];
assign rout_7[2] = rin_3[1];
assign din_3[383:256] = '0;
assign dxin_3[11:8] = '0;
assign dyin_3[11:8] = '0;
assign vin_3[2] = 1'b0;
assign rout_3[2] = 1'b0;
assign din_3[511:384] = '0;
assign dxin_3[15:12] = '0;
assign dyin_3[15:12] = '0;
assign vin_3[3] = 1'b0;
assign rout_3[3] = 1'b0;
assign din_3[639:512] = dout_2[511:384];
assign dxin_3[19:16] = dxout_2[15:12];
assign dyin_3[19:16] = dyout_2[15:12];
assign vin_3[4] = vout_2[3];
assign rout_2[3] = rin_3[4];
assign din_4[255:128] = dout_8[383:256];
assign dxin_4[7:4] = dxout_8[11:8];
assign dyin_4[7:4] = dyout_8[11:8];
assign vin_4[1] = vout_8[2];
assign rout_8[2] = rin_4[1];
assign din_4[383:256] = dout_0[255:128];
assign dxin_4[11:8] = dxout_0[7:4];
assign dyin_4[11:8] = dyout_0[7:4];
assign vin_4[2] = vout_0[1];
assign rout_0[1] = rin_4[2];
assign din_4[511:384] = dout_5[639:512];
assign dxin_4[15:12] = dxout_5[19:16];
assign dyin_4[15:12] = dyout_5[19:16];
assign vin_4[3] = vout_5[4];
assign rout_5[4] = rin_4[3];
assign din_4[639:512] = '0;
assign dxin_4[19:16] = '0;
assign dyin_4[19:16] = '0;
assign vin_4[4] = 1'b0;
assign rout_4[4] = 1'b0;
assign din_5[255:128] = dout_9[383:256];
assign dxin_5[7:4] = dxout_9[11:8];
assign dyin_5[7:4] = dyout_9[11:8];
assign vin_5[1] = vout_9[2];
assign rout_9[2] = rin_5[1];
assign din_5[383:256] = dout_1[255:128];
assign dxin_5[11:8] = dxout_1[7:4];
assign dyin_5[11:8] = dyout_1[7:4];
assign vin_5[2] = vout_1[1];
assign rout_1[1] = rin_5[2];
assign din_5[511:384] = dout_6[639:512];
assign dxin_5[15:12] = dxout_6[19:16];
assign dyin_5[15:12] = dyout_6[19:16];
assign vin_5[3] = vout_6[4];
assign rout_6[4] = rin_5[3];
assign din_5[639:512] = dout_4[511:384];
assign dxin_5[19:16] = dxout_4[15:12];
assign dyin_5[19:16] = dyout_4[15:12];
assign vin_5[4] = vout_4[3];
assign rout_4[3] = rin_5[4];
assign din_6[255:128] = dout_10[383:256];
assign dxin_6[7:4] = dxout_10[11:8];
assign dyin_6[7:4] = dyout_10[11:8];
assign vin_6[1] = vout_10[2];
assign rout_10[2] = rin_6[1];
assign din_6[383:256] = dout_2[255:128];
assign dxin_6[11:8] = dxout_2[7:4];
assign dyin_6[11:8] = dyout_2[7:4];
assign vin_6[2] = vout_2[1];
assign rout_2[1] = rin_6[2];
assign din_6[511:384] = dout_7[639:512];
assign dxin_6[15:12] = dxout_7[19:16];
assign dyin_6[15:12] = dyout_7[19:16];
assign vin_6[3] = vout_7[4];
assign rout_7[4] = rin_6[3];
assign din_6[639:512] = dout_5[511:384];
assign dxin_6[19:16] = dxout_5[15:12];
assign dyin_6[19:16] = dyout_5[15:12];
assign vin_6[4] = vout_5[3];
assign rout_5[3] = rin_6[4];
assign din_7[255:128] = dout_11[383:256];
assign dxin_7[7:4] = dxout_11[11:8];
assign dyin_7[7:4] = dyout_11[11:8];
assign vin_7[1] = vout_11[2];
assign rout_11[2] = rin_7[1];
assign din_7[383:256] = dout_3[255:128];
assign dxin_7[11:8] = dxout_3[7:4];
assign dyin_7[11:8] = dyout_3[7:4];
assign vin_7[2] = vout_3[1];
assign rout_3[1] = rin_7[2];
assign din_7[511:384] = '0;
assign dxin_7[15:12] = '0;
assign dyin_7[15:12] = '0;
assign vin_7[3] = 1'b0;
assign rout_7[3] = 1'b0;
assign din_7[639:512] = dout_6[511:384];
assign dxin_7[19:16] = dxout_6[15:12];
assign dyin_7[19:16] = dyout_6[15:12];
assign vin_7[4] = vout_6[3];
assign rout_6[3] = rin_7[4];
assign din_8[255:128] = dout_12[383:256];
assign dxin_8[7:4] = dxout_12[11:8];
assign dyin_8[7:4] = dyout_12[11:8];
assign vin_8[1] = vout_12[2];
assign rout_12[2] = rin_8[1];
assign din_8[383:256] = dout_4[255:128];
assign dxin_8[11:8] = dxout_4[7:4];
assign dyin_8[11:8] = dyout_4[7:4];
assign vin_8[2] = vout_4[1];
assign rout_4[1] = rin_8[2];
assign din_8[511:384] = dout_9[639:512];
assign dxin_8[15:12] = dxout_9[19:16];
assign dyin_8[15:12] = dyout_9[19:16];
assign vin_8[3] = vout_9[4];
assign rout_9[4] = rin_8[3];
assign din_8[639:512] = '0;
assign dxin_8[19:16] = '0;
assign dyin_8[19:16] = '0;
assign vin_8[4] = 1'b0;
assign rout_8[4] = 1'b0;
assign din_9[255:128] = dout_13[383:256];
assign dxin_9[7:4] = dxout_13[11:8];
assign dyin_9[7:4] = dyout_13[11:8];
assign vin_9[1] = vout_13[2];
assign rout_13[2] = rin_9[1];
assign din_9[383:256] = dout_5[255:128];
assign dxin_9[11:8] = dxout_5[7:4];
assign dyin_9[11:8] = dyout_5[7:4];
assign vin_9[2] = vout_5[1];
assign rout_5[1] = rin_9[2];
assign din_9[511:384] = dout_10[639:512];
assign dxin_9[15:12] = dxout_10[19:16];
assign dyin_9[15:12] = dyout_10[19:16];
assign vin_9[3] = vout_10[4];
assign rout_10[4] = rin_9[3];
assign din_9[639:512] = dout_8[511:384];
assign dxin_9[19:16] = dxout_8[15:12];
assign dyin_9[19:16] = dyout_8[15:12];
assign vin_9[4] = vout_8[3];
assign rout_8[3] = rin_9[4];
assign din_10[255:128] = dout_14[383:256];
assign dxin_10[7:4] = dxout_14[11:8];
assign dyin_10[7:4] = dyout_14[11:8];
assign vin_10[1] = vout_14[2];
assign rout_14[2] = rin_10[1];
assign din_10[383:256] = dout_6[255:128];
assign dxin_10[11:8] = dxout_6[7:4];
assign dyin_10[11:8] = dyout_6[7:4];
assign vin_10[2] = vout_6[1];
assign rout_6[1] = rin_10[2];
assign din_10[511:384] = dout_11[639:512];
assign dxin_10[15:12] = dxout_11[19:16];
assign dyin_10[15:12] = dyout_11[19:16];
assign vin_10[3] = vout_11[4];
assign rout_11[4] = rin_10[3];
assign din_10[639:512] = dout_9[511:384];
assign dxin_10[19:16] = dxout_9[15:12];
assign dyin_10[19:16] = dyout_9[15:12];
assign vin_10[4] = vout_9[3];
assign rout_9[3] = rin_10[4];
assign din_11[255:128] = dout_15[383:256];
assign dxin_11[7:4] = dxout_15[11:8];
assign dyin_11[7:4] = dyout_15[11:8];
assign vin_11[1] = vout_15[2];
assign rout_15[2] = rin_11[1];
assign din_11[383:256] = dout_7[255:128];
assign dxin_11[11:8] = dxout_7[7:4];
assign dyin_11[11:8] = dyout_7[7:4];
assign vin_11[2] = vout_7[1];
assign rout_7[1] = rin_11[2];
assign din_11[511:384] = '0;
assign dxin_11[15:12] = '0;
assign dyin_11[15:12] = '0;
assign vin_11[3] = 1'b0;
assign rout_11[3] = 1'b0;
assign din_11[639:512] = dout_10[511:384];
assign dxin_11[19:16] = dxout_10[15:12];
assign dyin_11[19:16] = dyout_10[15:12];
assign vin_11[4] = vout_10[3];
assign rout_10[3] = rin_11[4];
assign din_12[255:128] = '0;
assign dxin_12[7:4] = '0;
assign dyin_12[7:4] = '0;
assign vin_12[1] = 1'b0;
assign rout_12[1] = 1'b0;
assign din_12[383:256] = dout_8[255:128];
assign dxin_12[11:8] = dxout_8[7:4];
assign dyin_12[11:8] = dyout_8[7:4];
assign vin_12[2] = vout_8[1];
assign rout_8[1] = rin_12[2];
assign din_12[511:384] = dout_13[639:512];
assign dxin_12[15:12] = dxout_13[19:16];
assign dyin_12[15:12] = dyout_13[19:16];
assign vin_12[3] = vout_13[4];
assign rout_13[4] = rin_12[3];
assign din_12[639:512] = '0;
assign dxin_12[19:16] = '0;
assign dyin_12[19:16] = '0;
assign vin_12[4] = 1'b0;
assign rout_12[4] = 1'b0;
assign din_13[255:128] = '0;
assign dxin_13[7:4] = '0;
assign dyin_13[7:4] = '0;
assign vin_13[1] = 1'b0;
assign rout_13[1] = 1'b0;
assign din_13[383:256] = dout_9[255:128];
assign dxin_13[11:8] = dxout_9[7:4];
assign dyin_13[11:8] = dyout_9[7:4];
assign vin_13[2] = vout_9[1];
assign rout_9[1] = rin_13[2];
assign din_13[511:384] = dout_14[639:512];
assign dxin_13[15:12] = dxout_14[19:16];
assign dyin_13[15:12] = dyout_14[19:16];
assign vin_13[3] = vout_14[4];
assign rout_14[4] = rin_13[3];
assign din_13[639:512] = dout_12[511:384];
assign dxin_13[19:16] = dxout_12[15:12];
assign dyin_13[19:16] = dyout_12[15:12];
assign vin_13[4] = vout_12[3];
assign rout_12[3] = rin_13[4];
assign din_14[255:128] = '0;
assign dxin_14[7:4] = '0;
assign dyin_14[7:4] = '0;
assign vin_14[1] = 1'b0;
assign rout_14[1] = 1'b0;
assign din_14[383:256] = dout_10[255:128];
assign dxin_14[11:8] = dxout_10[7:4];
assign dyin_14[11:8] = dyout_10[7:4];
assign vin_14[2] = vout_10[1];
assign rout_10[1] = rin_14[2];
assign din_14[511:384] = dout_15[639:512];
assign dxin_14[15:12] = dxout_15[19:16];
assign dyin_14[15:12] = dyout_15[19:16];
assign vin_14[3] = vout_15[4];
assign rout_15[4] = rin_14[3];
assign din_14[639:512] = dout_13[511:384];
assign dxin_14[19:16] = dxout_13[15:12];
assign dyin_14[19:16] = dyout_13[15:12];
assign vin_14[4] = vout_13[3];
assign rout_13[3] = rin_14[4];
assign din_15[255:128] = '0;
assign dxin_15[7:4] = '0;
assign dyin_15[7:4] = '0;
assign vin_15[1] = 1'b0;
assign rout_15[1] = 1'b0;
assign din_15[383:256] = dout_11[255:128];
assign dxin_15[11:8] = dxout_11[7:4];
assign dyin_15[11:8] = dyout_11[7:4];
assign vin_15[2] = vout_11[1];
assign rout_11[1] = rin_15[2];
assign din_15[511:384] = '0;
assign dxin_15[15:12] = '0;
assign dyin_15[15:12] = '0;
assign vin_15[3] = 1'b0;
assign rout_15[3] = 1'b0;
assign din_15[639:512] = dout_14[511:384];
assign dxin_15[19:16] = dxout_14[15:12];
assign dyin_15[19:16] = dyout_14[15:12];
assign vin_15[4] = vout_14[3];
assign rout_14[3] = rin_15[4];

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_0 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd0),
        .current_y(4'd0),
    .data_in(din_0),
    .dest_x(dxin_0),
    .dest_y(dyin_0),
    .valid_in(vin_0),
    .ready_in(rin_0),
    .ready_out(rout_0),
    .data_out(dout_0),
    .valid_out(vout_0),
    .dest_x_out(dxout_0),
    .dest_y_out(dyout_0)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_1 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd1),
        .current_y(4'd0),
    .data_in(din_1),
    .dest_x(dxin_1),
    .dest_y(dyin_1),
    .valid_in(vin_1),
    .ready_in(rin_1),
    .ready_out(rout_1),
    .data_out(dout_1),
    .valid_out(vout_1),
    .dest_x_out(dxout_1),
    .dest_y_out(dyout_1)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_2 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd2),
        .current_y(4'd0),
    .data_in(din_2),
    .dest_x(dxin_2),
    .dest_y(dyin_2),
    .valid_in(vin_2),
    .ready_in(rin_2),
    .ready_out(rout_2),
    .data_out(dout_2),
    .valid_out(vout_2),
    .dest_x_out(dxout_2),
    .dest_y_out(dyout_2)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_3 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd3),
        .current_y(4'd0),
    .data_in(din_3),
    .dest_x(dxin_3),
    .dest_y(dyin_3),
    .valid_in(vin_3),
    .ready_in(rin_3),
    .ready_out(rout_3),
    .data_out(dout_3),
    .valid_out(vout_3),
    .dest_x_out(dxout_3),
    .dest_y_out(dyout_3)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_4 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd0),
        .current_y(4'd1),
    .data_in(din_4),
    .dest_x(dxin_4),
    .dest_y(dyin_4),
    .valid_in(vin_4),
    .ready_in(rin_4),
    .ready_out(rout_4),
    .data_out(dout_4),
    .valid_out(vout_4),
    .dest_x_out(dxout_4),
    .dest_y_out(dyout_4)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_5 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd1),
        .current_y(4'd1),
    .data_in(din_5),
    .dest_x(dxin_5),
    .dest_y(dyin_5),
    .valid_in(vin_5),
    .ready_in(rin_5),
    .ready_out(rout_5),
    .data_out(dout_5),
    .valid_out(vout_5),
    .dest_x_out(dxout_5),
    .dest_y_out(dyout_5)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_6 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd2),
        .current_y(4'd1),
    .data_in(din_6),
    .dest_x(dxin_6),
    .dest_y(dyin_6),
    .valid_in(vin_6),
    .ready_in(rin_6),
    .ready_out(rout_6),
    .data_out(dout_6),
    .valid_out(vout_6),
    .dest_x_out(dxout_6),
    .dest_y_out(dyout_6)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_7 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd3),
        .current_y(4'd1),
    .data_in(din_7),
    .dest_x(dxin_7),
    .dest_y(dyin_7),
    .valid_in(vin_7),
    .ready_in(rin_7),
    .ready_out(rout_7),
    .data_out(dout_7),
    .valid_out(vout_7),
    .dest_x_out(dxout_7),
    .dest_y_out(dyout_7)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_8 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd0),
        .current_y(4'd2),
    .data_in(din_8),
    .dest_x(dxin_8),
    .dest_y(dyin_8),
    .valid_in(vin_8),
    .ready_in(rin_8),
    .ready_out(rout_8),
    .data_out(dout_8),
    .valid_out(vout_8),
    .dest_x_out(dxout_8),
    .dest_y_out(dyout_8)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_9 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd1),
        .current_y(4'd2),
    .data_in(din_9),
    .dest_x(dxin_9),
    .dest_y(dyin_9),
    .valid_in(vin_9),
    .ready_in(rin_9),
    .ready_out(rout_9),
    .data_out(dout_9),
    .valid_out(vout_9),
    .dest_x_out(dxout_9),
    .dest_y_out(dyout_9)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_10 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd2),
        .current_y(4'd2),
    .data_in(din_10),
    .dest_x(dxin_10),
    .dest_y(dyin_10),
    .valid_in(vin_10),
    .ready_in(rin_10),
    .ready_out(rout_10),
    .data_out(dout_10),
    .valid_out(vout_10),
    .dest_x_out(dxout_10),
    .dest_y_out(dyout_10)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_11 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd3),
        .current_y(4'd2),
    .data_in(din_11),
    .dest_x(dxin_11),
    .dest_y(dyin_11),
    .valid_in(vin_11),
    .ready_in(rin_11),
    .ready_out(rout_11),
    .data_out(dout_11),
    .valid_out(vout_11),
    .dest_x_out(dxout_11),
    .dest_y_out(dyout_11)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_12 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd0),
        .current_y(4'd3),
    .data_in(din_12),
    .dest_x(dxin_12),
    .dest_y(dyin_12),
    .valid_in(vin_12),
    .ready_in(rin_12),
    .ready_out(rout_12),
    .data_out(dout_12),
    .valid_out(vout_12),
    .dest_x_out(dxout_12),
    .dest_y_out(dyout_12)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_13 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd1),
        .current_y(4'd3),
    .data_in(din_13),
    .dest_x(dxin_13),
    .dest_y(dyin_13),
    .valid_in(vin_13),
    .ready_in(rin_13),
    .ready_out(rout_13),
    .data_out(dout_13),
    .valid_out(vout_13),
    .dest_x_out(dxout_13),
    .dest_y_out(dyout_13)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_14 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd2),
        .current_y(4'd3),
    .data_in(din_14),
    .dest_x(dxin_14),
    .dest_y(dyin_14),
    .valid_in(vin_14),
    .ready_in(rin_14),
    .ready_out(rout_14),
    .data_out(dout_14),
    .valid_out(vout_14),
    .dest_x_out(dxout_14),
    .dest_y_out(dyout_14)
);

anoc_rv_router_buffered_synth #(
    .DATA_WIDTH(DATA_WIDTH),
    .COORD_WIDTH(COORD_WIDTH),
    .NUM_PORTS(NUM_PORTS)
) router_15 (
    .clk(clk),
        .rst_n(~rst),
        .current_x(4'd3),
        .current_y(4'd3),
    .data_in(din_15),
    .dest_x(dxin_15),
    .dest_y(dyin_15),
    .valid_in(vin_15),
    .ready_in(rin_15),
    .ready_out(rout_15),
    .data_out(dout_15),
    .valid_out(vout_15),
    .dest_x_out(dxout_15),
    .dest_y_out(dyout_15)
);

endmodule