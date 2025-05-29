
// 按 write_address_log_table 中的validtable中的id 去匹配对应fifo使能
module write_data_arbiter(
    input clk,
    input rst_n,

    input  [ 5:0] s0_axi_w_fifo0_wid,
    input  [31:0] s0_axi_w_fifo0_wdata,
    input         s0_axi_w_fifo0_wlast,
    input  [ 3:0] s0_axi_w_fifo0_wstrb,
    input         s0_axi_w_fifo0_valid,
    output        s0_axi_w_fifo0_ready,
    input  [ 1:0] s0_fifo0_IDgrant,

    input  [ 5:0] s0_axi_w_fifo1_wid,
    input  [31:0] s0_axi_w_fifo1_wdata,
    input         s0_axi_w_fifo1_wlast,
    input  [ 3:0] s0_axi_w_fifo1_wstrb,
    input         s0_axi_w_fifo1_valid,
    output        s0_axi_w_fifo1_ready,
    input  [ 1:0] s0_fifo1_IDgrant,

    input  [ 5:0] s0_axi_w_fifo2_wid,
    input  [31:0] s0_axi_w_fifo2_wdata,
    input         s0_axi_w_fifo2_wlast,
    input  [ 3:0] s0_axi_w_fifo2_wstrb,
    input         s0_axi_w_fifo2_valid,
    output        s0_axi_w_fifo2_ready,
    input  [ 1:0] s0_fifo2_IDgrant,

    input  [ 5:0] s1_axi_w_fifo0_wid,
    input  [31:0] s1_axi_w_fifo0_wdata,
    input         s1_axi_w_fifo0_wlast,
    input  [ 3:0] s1_axi_w_fifo0_wstrb,
    input         s1_axi_w_fifo0_valid,
    output        s1_axi_w_fifo0_ready,
    input  [ 1:0] s1_fifo0_IDgrant,

    input  [ 5:0] s1_axi_w_fifo1_wid,
    input  [31:0] s1_axi_w_fifo1_wdata,
    input         s1_axi_w_fifo1_wlast,
    input  [ 3:0] s1_axi_w_fifo1_wstrb,
    input         s1_axi_w_fifo1_valid,
    output        s1_axi_w_fifo1_ready,
    input  [ 1:0] s1_fifo1_IDgrant,

    input  [ 5:0] s1_axi_w_fifo2_wid,
    input  [31:0] s1_axi_w_fifo2_wdata,
    input         s1_axi_w_fifo2_wlast,
    input  [ 3:0] s1_axi_w_fifo2_wstrb,
    input         s1_axi_w_fifo2_valid,
    output        s1_axi_w_fifo2_ready,
    input  [ 1:0] s1_fifo2_IDgrant,


    input  [ 5:0] s2_axi_w_fifo0_wid,
    input  [31:0] s2_axi_w_fifo0_wdata,
    input         s2_axi_w_fifo0_wlast,
    input  [ 3:0] s2_axi_w_fifo0_wstrb,
    input         s2_axi_w_fifo0_valid,
    output        s2_axi_w_fifo0_ready,
    input  [ 1:0] s2_fifo0_IDgrant,

    input  [ 5:0] s2_axi_w_fifo1_wid,
    input  [31:0] s2_axi_w_fifo1_wdata,
    input         s2_axi_w_fifo1_wlast,
    input  [ 3:0] s2_axi_w_fifo1_wstrb,
    input         s2_axi_w_fifo1_valid,
    output        s2_axi_w_fifo1_ready,
    input  [ 1:0] s2_fifo1_IDgrant,

    input  [ 5:0] s2_axi_w_fifo2_wid,
    input  [31:0] s2_axi_w_fifo2_wdata,
    input         s2_axi_w_fifo2_wlast,
    input  [ 3:0] s2_axi_w_fifo2_wstrb,
    input         s2_axi_w_fifo2_valid,
    output        s2_axi_w_fifo2_ready,
    input  [ 1:0] s2_fifo2_IDgrant,


//write_address_log_table 提供
    input  [ 5:0] s_validid0,
    input  [ 5:0] s_validid1,
    input  [ 5:0] s_validid2,

    input  [ 2:0] s_valid,

    input  [ 7:0] s_wlen0,
    input  [ 7:0] s_wlen1,
    input  [ 7:0] s_wlen2,

    output  [ 5:0] m_axi_w_wid,
    output  [31:0] m_axi_w_wdata,
    output         m_axi_w_wlast,
    output  [ 3:0] m_axi_w_wstrb,
    output         m_axi_w_valid,
    input          m_axi_w_ready


);

    wire [ 2:0]  req;
    wire [ 2:0]  grant;



    wire [ 5:0]  s_axi_w_arb0_wid;
    wire [31:0]  s_axi_w_arb0_wdata;
    wire         s_axi_w_arb0_wlast;
    wire [ 3:0]  s_axi_w_arb0_wstrb;
    wire         req0;

    reg  [42:0]  s_axi_w_arb0_payload;


    wire s_fifo_0_match00 = s_valid[0] && (s_validid0 == s0_axi_w_fifo0_wid) && s0_axi_w_fifo0_valid && (s0_fifo0_IDgrant == 2'b00);
    wire s_fifo_0_match01 = s_valid[0] && (s_validid0 == s0_axi_w_fifo1_wid) && s0_axi_w_fifo1_valid && (s0_fifo1_IDgrant == 2'b00);
    wire s_fifo_0_match02 = s_valid[0] && (s_validid0 == s0_axi_w_fifo2_wid) && s0_axi_w_fifo2_valid && (s0_fifo2_IDgrant == 2'b00);

    wire s_fifo_0_match10 = s_valid[0] && (s_validid0 == s1_axi_w_fifo0_wid) && s1_axi_w_fifo0_valid && (s1_fifo0_IDgrant == 2'b00);
    wire s_fifo_0_match11 = s_valid[0] && (s_validid0 == s1_axi_w_fifo1_wid) && s1_axi_w_fifo1_valid && (s1_fifo1_IDgrant == 2'b00);
    wire s_fifo_0_match12 = s_valid[0] && (s_validid0 == s1_axi_w_fifo2_wid) && s1_axi_w_fifo2_valid && (s1_fifo2_IDgrant == 2'b00);

    wire s_fifo_0_match20 = s_valid[0] && (s_validid0 == s2_axi_w_fifo0_wid) && s2_axi_w_fifo0_valid && (s2_fifo0_IDgrant == 2'b00);
    wire s_fifo_0_match21 = s_valid[0] && (s_validid0 == s2_axi_w_fifo1_wid) && s2_axi_w_fifo1_valid && (s2_fifo1_IDgrant == 2'b00);
    wire s_fifo_0_match22 = s_valid[0] && (s_validid0 == s2_axi_w_fifo2_wid) && s2_axi_w_fifo2_valid && (s2_fifo2_IDgrant == 2'b00);

    assign req0 = s_fifo_0_match00 | s_fifo_0_match01 | s_fifo_0_match02 |
              s_fifo_0_match10 | s_fifo_0_match11 | s_fifo_0_match12 |
              s_fifo_0_match20 | s_fifo_0_match21 | s_fifo_0_match22;


    // assign s_axi_w_arb0_wid = s_fifo_0_match00 ? s0_axi_w_fifo0_wid : (s_fifo_0_match01 ? s0_axi_w_fifo1_wid : (s_fifo_0_match02 ? 
    //         s0_axi_w_fifo2_wid : (s_fifo_0_match10 ? s1_axi_w_fifo0_wid : (s_fifo_0_match11 ? s1_axi_w_fifo1_wid : (s_fifo_0_match12 ? 
    //             s1_axi_w_fifo2_wid : (s_fifo_0_match20 ? s2_axi_w_fifo0_wid : (s_fifo_0_match21 ? s2_axi_w_fifo1_wid : (s_fifo_0_match22 ? s2_axi_w_fifo2_wid : s_axi_w_arb0_wid))))))));



    always @(*) begin
        if (s_fifo_0_match00) begin
           s_axi_w_arb0_payload = {s0_axi_w_fifo0_wid, s0_axi_w_fifo0_wdata, s0_axi_w_fifo0_wlast, s0_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_0_match01) begin
           s_axi_w_arb0_payload = {s0_axi_w_fifo1_wid, s0_axi_w_fifo1_wdata, s0_axi_w_fifo1_wlast, s0_axi_w_fifo1_wstrb};
        end 
        else if (s_fifo_0_match02) begin
           s_axi_w_arb0_payload = {s0_axi_w_fifo2_wid, s0_axi_w_fifo2_wdata, s0_axi_w_fifo2_wlast, s0_axi_w_fifo2_wstrb};
        end
        else if (s_fifo_0_match10) begin
           s_axi_w_arb0_payload = {s1_axi_w_fifo0_wid, s1_axi_w_fifo0_wdata, s1_axi_w_fifo0_wlast, s1_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_0_match11) begin
           s_axi_w_arb0_payload = {s1_axi_w_fifo1_wid, s1_axi_w_fifo1_wdata, s1_axi_w_fifo1_wlast, s1_axi_w_fifo1_wstrb};
        end
        else if (s_fifo_0_match12) begin
           s_axi_w_arb0_payload = {s1_axi_w_fifo2_wid, s1_axi_w_fifo2_wdata, s1_axi_w_fifo2_wlast, s1_axi_w_fifo2_wstrb};
        end 
        else if (s_fifo_0_match20) begin
           s_axi_w_arb0_payload = {s2_axi_w_fifo0_wid, s2_axi_w_fifo0_wdata, s2_axi_w_fifo0_wlast, s2_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_0_match21) begin
           s_axi_w_arb0_payload = {s2_axi_w_fifo1_wid, s2_axi_w_fifo1_wdata, s2_axi_w_fifo1_wlast, s2_axi_w_fifo1_wstrb};
        end 
        else if (s_fifo_0_match22) begin
           s_axi_w_arb0_payload = {s2_axi_w_fifo2_wid, s2_axi_w_fifo2_wdata, s2_axi_w_fifo2_wlast, s2_axi_w_fifo2_wstrb};
        end 
        else begin
           s_axi_w_arb0_payload = s_axi_w_arb0_payload;  
        end
    end

    assign s_axi_w_arb0_wid   = s_axi_w_arb0_payload[42:37];
    assign s_axi_w_arb0_wdata = s_axi_w_arb0_payload[36: 5];
    assign s_axi_w_arb0_wlast = s_axi_w_arb0_payload[4];
    assign s_axi_w_arb0_wstrb = s_axi_w_arb0_payload[3:0];



        wire [ 5:0]  s_axi_w_arb1_wid;
    wire [31:0]  s_axi_w_arb1_wdata;
    wire         s_axi_w_arb1_wlast;
    wire [ 3:0]  s_axi_w_arb1_wstrb;
    wire         req1;

    reg  [42:0]  s_axi_w_arb1_payload;


    wire s_fifo_1_match00 = s_valid[1] && (s_validid1 == s0_axi_w_fifo0_wid) && s0_axi_w_fifo0_valid && (s0_fifo0_IDgrant == 2'b00);
    wire s_fifo_1_match01 = s_valid[1] && (s_validid1 == s0_axi_w_fifo1_wid) && s0_axi_w_fifo1_valid && (s0_fifo1_IDgrant == 2'b00);
    wire s_fifo_1_match02 = s_valid[1] && (s_validid1 == s0_axi_w_fifo2_wid) && s0_axi_w_fifo2_valid && (s0_fifo2_IDgrant == 2'b00);

    wire s_fifo_1_match10 = s_valid[1] && (s_validid1 == s1_axi_w_fifo0_wid) && s1_axi_w_fifo0_valid && (s1_fifo0_IDgrant == 2'b00);
    wire s_fifo_1_match11 = s_valid[1] && (s_validid1 == s1_axi_w_fifo1_wid) && s1_axi_w_fifo1_valid && (s1_fifo1_IDgrant == 2'b00);
    wire s_fifo_1_match12 = s_valid[1] && (s_validid1 == s1_axi_w_fifo2_wid) && s1_axi_w_fifo2_valid && (s1_fifo2_IDgrant == 2'b00);

    wire s_fifo_1_match20 = s_valid[1] && (s_validid1 == s2_axi_w_fifo0_wid) && s2_axi_w_fifo0_valid && (s2_fifo0_IDgrant == 2'b00);
    wire s_fifo_1_match21 = s_valid[1] && (s_validid1 == s2_axi_w_fifo1_wid) && s2_axi_w_fifo1_valid && (s2_fifo1_IDgrant == 2'b00);
    wire s_fifo_1_match22 = s_valid[1] && (s_validid1 == s2_axi_w_fifo2_wid) && s2_axi_w_fifo2_valid && (s2_fifo2_IDgrant == 2'b00);

    assign req1 = s_fifo_1_match00 | s_fifo_1_match01 | s_fifo_1_match02 |
              s_fifo_1_match10 | s_fifo_1_match11 | s_fifo_1_match12 |
              s_fifo_1_match20 | s_fifo_1_match21 | s_fifo_1_match22;


    // assign s_axi_w_arb1_wid = s_fifo_1_match00 ? s0_axi_w_fifo0_wid : (s_fifo_1_match01 ? s0_axi_w_fifo1_wid : (s_fifo_1_match02 ? 
    //         s0_axi_w_fifo2_wid : (s_fifo_1_match10 ? s1_axi_w_fifo0_wid : (s_fifo_1_match11 ? s1_axi_w_fifo1_wid : (s_fifo_1_match12 ? 
    //             s1_axi_w_fifo2_wid : (s_fifo_1_match20 ? s2_axi_w_fifo0_wid : (s_fifo_1_match21 ? s2_axi_w_fifo1_wid : (s_fifo_1_match22 ? s2_axi_w_fifo2_wid : s_axi_w_arb1_wid))))))));



    always @(*) begin
        if (s_fifo_1_match00) begin
           s_axi_w_arb1_payload = {s0_axi_w_fifo0_wid, s0_axi_w_fifo0_wdata, s0_axi_w_fifo0_wlast, s0_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_1_match01) begin
           s_axi_w_arb1_payload = {s0_axi_w_fifo1_wid, s0_axi_w_fifo1_wdata, s0_axi_w_fifo1_wlast, s0_axi_w_fifo1_wstrb};
        end 
        else if (s_fifo_1_match02) begin
           s_axi_w_arb1_payload = {s0_axi_w_fifo2_wid, s0_axi_w_fifo2_wdata, s0_axi_w_fifo2_wlast, s0_axi_w_fifo2_wstrb};
        end
        else if (s_fifo_1_match10) begin
           s_axi_w_arb1_payload = {s1_axi_w_fifo0_wid, s1_axi_w_fifo0_wdata, s1_axi_w_fifo0_wlast, s1_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_1_match11) begin
           s_axi_w_arb1_payload = {s1_axi_w_fifo1_wid, s1_axi_w_fifo1_wdata, s1_axi_w_fifo1_wlast, s1_axi_w_fifo1_wstrb};
        end
        else if (s_fifo_1_match12) begin
           s_axi_w_arb1_payload = {s1_axi_w_fifo2_wid, s1_axi_w_fifo2_wdata, s1_axi_w_fifo2_wlast, s1_axi_w_fifo2_wstrb};
        end 
        else if (s_fifo_1_match20) begin
           s_axi_w_arb1_payload = {s2_axi_w_fifo0_wid, s2_axi_w_fifo0_wdata, s2_axi_w_fifo0_wlast, s2_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_1_match21) begin
           s_axi_w_arb1_payload = {s2_axi_w_fifo1_wid, s2_axi_w_fifo1_wdata, s2_axi_w_fifo1_wlast, s2_axi_w_fifo1_wstrb};
        end 
        else if (s_fifo_1_match22) begin
           s_axi_w_arb1_payload = {s2_axi_w_fifo2_wid, s2_axi_w_fifo2_wdata, s2_axi_w_fifo2_wlast, s2_axi_w_fifo2_wstrb};
        end 
        else begin
           s_axi_w_arb1_payload = s_axi_w_arb1_payload;  
        end
    end

    assign s_axi_w_arb1_wid   = s_axi_w_arb1_payload[42:37];
    assign s_axi_w_arb1_wdata = s_axi_w_arb1_payload[36: 5];
    assign s_axi_w_arb1_wlast = s_axi_w_arb1_payload[4];
    assign s_axi_w_arb1_wstrb = s_axi_w_arb1_payload[3:0];


    wire [ 5:0]  s_axi_w_arb2_wid;
    wire [31:0]  s_axi_w_arb2_wdata;
    wire         s_axi_w_arb2_wlast;
    wire [ 3:0]  s_axi_w_arb2_wstrb;
    wire         req2;

    reg  [42:0]  s_axi_w_arb2_payload;


    wire s_fifo_2_match00 = s_valid[2] && (s_validid2 == s0_axi_w_fifo0_wid) && s0_axi_w_fifo0_valid && (s0_fifo0_IDgrant == 2'b00);
    wire s_fifo_2_match01 = s_valid[2] && (s_validid2 == s0_axi_w_fifo1_wid) && s0_axi_w_fifo1_valid && (s0_fifo1_IDgrant == 2'b00);
    wire s_fifo_2_match02 = s_valid[2] && (s_validid2 == s0_axi_w_fifo2_wid) && s0_axi_w_fifo2_valid && (s0_fifo2_IDgrant == 2'b00);

    wire s_fifo_2_match10 = s_valid[2] && (s_validid2 == s1_axi_w_fifo0_wid) && s1_axi_w_fifo0_valid && (s1_fifo0_IDgrant == 2'b00);
    wire s_fifo_2_match11 = s_valid[2] && (s_validid2 == s1_axi_w_fifo1_wid) && s1_axi_w_fifo1_valid && (s1_fifo1_IDgrant == 2'b00);
    wire s_fifo_2_match12 = s_valid[2] && (s_validid2 == s1_axi_w_fifo2_wid) && s1_axi_w_fifo2_valid && (s1_fifo2_IDgrant == 2'b00);

    wire s_fifo_2_match20 = s_valid[2] && (s_validid2 == s2_axi_w_fifo0_wid) && s2_axi_w_fifo0_valid && (s2_fifo0_IDgrant == 2'b00);
    wire s_fifo_2_match21 = s_valid[2] && (s_validid2 == s2_axi_w_fifo1_wid) && s2_axi_w_fifo1_valid && (s2_fifo1_IDgrant == 2'b00);
    wire s_fifo_2_match22 = s_valid[2] && (s_validid2 == s2_axi_w_fifo2_wid) && s2_axi_w_fifo2_valid && (s2_fifo2_IDgrant == 2'b00);

    assign req2 = s_fifo_2_match00 | s_fifo_2_match01 | s_fifo_2_match02 |
              s_fifo_2_match10 | s_fifo_2_match11 | s_fifo_2_match12 |
              s_fifo_2_match20 | s_fifo_2_match21 | s_fifo_2_match22;


    // assign s_axi_w_arb2_wid = s_fifo_2_match00 ? s0_axi_w_fifo0_wid : (s_fifo_2_match01 ? s0_axi_w_fifo1_wid : (s_fifo_2_match02 ? 
    //         s0_axi_w_fifo2_wid : (s_fifo_2_match10 ? s1_axi_w_fifo0_wid : (s_fifo_2_match11 ? s1_axi_w_fifo1_wid : (s_fifo_2_match12 ? 
    //             s1_axi_w_fifo2_wid : (s_fifo_2_match20 ? s2_axi_w_fifo0_wid : (s_fifo_2_match21 ? s2_axi_w_fifo1_wid : (s_fifo_2_match22 ? s2_axi_w_fifo2_wid : s_axi_w_arb2_wid))))))));



    always @(*) begin
        if (s_fifo_2_match00) begin
           s_axi_w_arb2_payload = {s0_axi_w_fifo0_wid, s0_axi_w_fifo0_wdata, s0_axi_w_fifo0_wlast, s0_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_2_match01) begin
           s_axi_w_arb2_payload = {s0_axi_w_fifo1_wid, s0_axi_w_fifo1_wdata, s0_axi_w_fifo1_wlast, s0_axi_w_fifo1_wstrb};
        end 
        else if (s_fifo_2_match02) begin
           s_axi_w_arb2_payload = {s0_axi_w_fifo2_wid, s0_axi_w_fifo2_wdata, s0_axi_w_fifo2_wlast, s0_axi_w_fifo2_wstrb};
        end
        else if (s_fifo_2_match10) begin
           s_axi_w_arb2_payload = {s1_axi_w_fifo0_wid, s1_axi_w_fifo0_wdata, s1_axi_w_fifo0_wlast, s1_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_2_match11) begin
           s_axi_w_arb2_payload = {s1_axi_w_fifo1_wid, s1_axi_w_fifo1_wdata, s1_axi_w_fifo1_wlast, s1_axi_w_fifo1_wstrb};
        end
        else if (s_fifo_2_match12) begin
           s_axi_w_arb2_payload = {s1_axi_w_fifo2_wid, s1_axi_w_fifo2_wdata, s1_axi_w_fifo2_wlast, s1_axi_w_fifo2_wstrb};
        end 
        else if (s_fifo_2_match20) begin
           s_axi_w_arb2_payload = {s2_axi_w_fifo0_wid, s2_axi_w_fifo0_wdata, s2_axi_w_fifo0_wlast, s2_axi_w_fifo0_wstrb};
        end 
        else if (s_fifo_2_match21) begin
           s_axi_w_arb2_payload = {s2_axi_w_fifo1_wid, s2_axi_w_fifo1_wdata, s2_axi_w_fifo1_wlast, s2_axi_w_fifo1_wstrb};
        end 
        else if (s_fifo_2_match22) begin
           s_axi_w_arb2_payload = {s2_axi_w_fifo2_wid, s2_axi_w_fifo2_wdata, s2_axi_w_fifo2_wlast, s2_axi_w_fifo2_wstrb};
        end 
        else begin
           s_axi_w_arb2_payload = s_axi_w_arb2_payload;  
        end
    end

    assign s_axi_w_arb2_wid   = s_axi_w_arb2_payload[42:37];
    assign s_axi_w_arb2_wdata = s_axi_w_arb2_payload[36: 5];
    assign s_axi_w_arb2_wlast = s_axi_w_arb2_payload[4];
    assign s_axi_w_arb2_wstrb = s_axi_w_arb2_payload[3:0];


    assign req = {req0, req1, req2};

    reg [2:0] priority;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            priority <= 3'd1;
        else if((|req) && m_axi_w_ready)
            priority <= {grant[1:0],grant[2]};
        else
            priority <= priority;
    end

    reg  [ 5:0] m_axi_arbitr_w_wid;
    reg  [31:0] m_axi_arbitr_w_wdata;
    reg         m_axi_arbitr_w_wlast;
    reg  [ 3:0] m_axi_arbitr_w_wstrb;


    always @(*) begin
        case(grant) 
            3'b001: begin
                m_axi_arbitr_w_wid   = s_axi_w_arb0_wid;
                m_axi_arbitr_w_wdata = s_axi_w_arb0_wdata;
                m_axi_arbitr_w_wlast = s_axi_w_arb0_wlast;
                m_axi_arbitr_w_wstrb = s_axi_w_arb0_wstrb;
            end
            3'b010: begin
                m_axi_arbitr_w_wid   = s_axi_w_arb0_wid;
                m_axi_arbitr_w_wdata = s_axi_w_arb0_wdata;
                m_axi_arbitr_w_wlast = s_axi_w_arb0_wlast;
                m_axi_arbitr_w_wstrb = s_axi_w_arb0_wstrb;
            end
            3'b100: begin
                m_axi_arbitr_w_wid   = s_axi_w_arb0_wid;
                m_axi_arbitr_w_wdata = s_axi_w_arb0_wdata;
                m_axi_arbitr_w_wlast = s_axi_w_arb0_wlast;
                m_axi_arbitr_w_wstrb = s_axi_w_arb0_wstrb;
            end
        endcase
    end

    wire [5:0] double_req = {req,req};

    wire [5:0] double_grant = double_req & ~(double_req - priority);


    reg lock;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            lock <= 1'b0;
        else if((|req) && !m_axi_w_ready)
            lock <= 1'b1;
        else if(m_axi_w_ready)
            lock <= 1'b0;
    end

    assign grant = lock ? grant :double_grant[5:3] | double_grant[2:0];

    assign s0_axi_w_fifo0_ready = ((grant[0] && s_fifo_0_match00) || (grant[1] && s_fifo_1_match00) || (grant[2] && s_fifo_2_match00)) && m_axi_w_ready;
    assign s0_axi_w_fifo1_ready = ((grant[0] && s_fifo_0_match01) || (grant[1] && s_fifo_1_match01) || (grant[2] && s_fifo_2_match01)) && m_axi_w_ready;
    assign s0_axi_w_fifo2_ready = ((grant[0] && s_fifo_0_match02) || (grant[1] && s_fifo_1_match02) || (grant[2] && s_fifo_2_match02)) && m_axi_w_ready;
 
    assign s1_axi_w_fifo0_ready = ((grant[0] && s_fifo_0_match10) || (grant[1] && s_fifo_1_match10) || (grant[2] && s_fifo_2_match10)) && m_axi_w_ready;
    assign s1_axi_w_fifo1_ready = ((grant[0] && s_fifo_0_match11) || (grant[1] && s_fifo_1_match11) || (grant[2] && s_fifo_2_match11)) && m_axi_w_ready;
    assign s1_axi_w_fifo2_ready = ((grant[0] && s_fifo_0_match12) || (grant[1] && s_fifo_1_match12) || (grant[2] && s_fifo_2_match12)) && m_axi_w_ready;
    
    assign s2_axi_w_fifo0_ready = ((grant[0] && s_fifo_0_match20) || (grant[1] && s_fifo_1_match00) || (grant[2] && s_fifo_2_match00)) && m_axi_w_ready;
    assign s2_axi_w_fifo1_ready = ((grant[0] && s_fifo_0_match21) || (grant[1] && s_fifo_1_match01) || (grant[2] && s_fifo_2_match01)) && m_axi_w_ready;
    assign s2_axi_w_fifo2_ready = ((grant[0] && s_fifo_0_match22) || (grant[1] && s_fifo_1_match02) || (grant[2] && s_fifo_2_match02)) && m_axi_w_ready;

    reg [7:0] s0_counter,s1_counter,s2_counter;

    reg s_valid0_reg,s_valid1_reg,s_valid2_reg;

    always @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         s_valid0_reg <= 1'b0;
      else
         s_valid0_reg <= s_valid[0];
    end

    always @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         s_valid1_reg <= 1'b0;
      else
         s_valid1_reg <= s_valid[1];
    end

    always @(posedge clk or negedge rst_n) begin
      if(!rst_n)
         s_valid2_reg <= 1'b0;
      else
         s_valid2_reg <= s_valid[2];
    end

    wire counterflag0,counterflag1,counterflag2;
    assign counterflag0 = s_valid[0] && (!s_valid0_reg);
    assign counterflag1 = s_valid[1] && (!s_valid1_reg);
    assign counterflag2 = s_valid[2] && (!s_valid2_reg);
    wire grant0_wlast;
    wire grant1_wlast;
    wire grant2_wlast;


    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) 
         s0_counter <= 8'd0;
      else if(counterflag0)
         s0_counter <= s_wlen0;
      else if(grant[0] && m_axi_w_ready)
         s0_counter <= s0_counter - 1;
    end 

    assign grant0_wlast = (s0_counter == 'd0);

    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) 
         s1_counter <= 8'd0;
      else if(counterflag0)
         s1_counter <= s_wlen1;
      else if(grant[1] && m_axi_w_ready)
         s1_counter <= s1_counter - 1;
    end 

    assign grant1_wlast = (s1_counter == 'd0);

    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) 
         s2_counter <= 8'd0;
      else if(counterflag0)
         s2_counter <= s_wlen2;
      else if(grant[2] && m_axi_w_ready)
         s2_counter <= s2_counter - 1;
    end 

    assign grant2_wlast = (s2_counter == 'd0);

    assign m_axi_w_wid = lock? m_axi_w_wid : m_axi_arbitr_w_wid;
    assign m_axi_w_wdata = lock? m_axi_w_wdata : m_axi_arbitr_w_wdata;
    assign m_axi_w_wlast = lock? m_axi_w_wlast : ((grant[0] && grant0_wlast) || (grant[1] && grant1_wlast) || (grant[2] && grant2_wlast) || m_axi_arbitr_w_wlast);
    assign m_axi_w_wstrb = lock? m_axi_w_wstrb : m_axi_arbitr_w_wstrb;
    assign m_axi_w_valid = |grant;















endmodule


