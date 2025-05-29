module write_address_arbiter3 (
    input clk,
    input rst_n,

    input [13:0] aw_decoder_awaddr_s0,
    input [7:0]  aw_decoder_awlen_s0,
    input [2:0]  aw_decoder_awsize_s0,
    input [1:0]  aw_decoder_awburst_s0,
    input [5:0]  aw_decoder_awid_s0,
    input        aw_decoder_valid_s0,
    output       aw_decoder_ready_s0,

    input [13:0] aw_decoder_awaddr_s1,
    input [7:0]  aw_decoder_awlen_s1,
    input [2:0]  aw_decoder_awsize_s1,
    input [1:0]  aw_decoder_awburst_s1,
    input [5:0]  aw_decoder_awid_s1,
    input        aw_decoder_valid_s1,
    output       aw_decoder_ready_s1,

    input [13:0]  aw_decoder_awaddr_s2,
    input [7:0]   aw_decoder_awlen_s2,
    input [2:0]   aw_decoder_awsize_s2,
    input [1:0]   aw_decoder_awburst_s2,
    input [5:0]   aw_decoder_awid_s2,
    input         aw_decoder_valid_s2,
    output        aw_decoder_ready_s2,

    output [11:0] m0_axi_arbiter_awaddr,
    output [7:0]  m0_axi_arbiter_awlen,
    output [2:0]  m0_axi_arbiter_awsize,
    output [1:0]  m0_axi_arbiter_awburst,
    output [5:0]  m0_axi_arbiter_awid,
    output        m0_axi_arbiter_valid,
    input         m0_axi_arbiter_ready,

    output [11:0] m1_axi_arbiter_awaddr,
    output [7:0]  m1_axi_arbiter_awlen,
    output [2:0]  m1_axi_arbiter_awsize, 
    output [1:0]  m1_axi_arbiter_awburst,
    output [5:0]  m1_axi_arbiter_awid,
    output        m1_axi_arbiter_valid,
    input         m1_axi_arbiter_ready,


    output [11:0] m2_axi_arbiter_awaddr,
    output [7:0]  m2_axi_arbiter_awlen,
    output [2:0]  m2_axi_arbiter_awsize,
    output [1:0]  m2_axi_arbiter_awburst,
    output [5:0]  m2_axi_arbiter_awid,
    output        m2_axi_arbiter_valid,
    input         m2_axi_arbiter_ready,

    input   [2:0] region_write_table_m0,//主机m0对从机访问权限 高位从机2 低位从机0
    input   [2:0] region_write_table_m1,//主机m1对从机访问权限
    input   [2:0] region_write_table_m2,//主机m2对从机访问权限



//  清空fifo后的写返回仲裁成功正确握手 write_response
    input            s0_axi_invalid_fire,
    input            s0_axi_invalid_wid,
    input            s1_axi_invalid_fire,
    input            s1_axi_invalid_wid,
    input            s2_axi_invalid_fire,
    input            s2_axi_invalid_wid,

// 与write_data_fifo_lut 交互
    output  [ 5:0]  m0_transaction_invalidid0,
    output  [ 5:0]  m0_transaction_invalidid1,
    output  [ 5:0]  m0_transaction_invalidid2,
    output  [ 2:0]  m0invalid,

    output  [ 5:0]  m1_transaction_invalidid0,
    output  [ 5:0]  m1_transaction_invalidid1,
    output  [ 5:0]  m1_transaction_invalidid2,
    output  [ 2:0]  m1invalid,


    output  [ 5:0]  m2_transaction_invalidid0,
    output  [ 5:0]  m2_transaction_invalidid1,
    output  [ 5:0]  m2_transaction_invalidid2,
    output  [ 2:0]  m2invalid




    // input         s0_axi_w_fifo_flush,
    // input         s1_axi_w_fifo_flush,
    // input         s2_axi_w_fifo_flush,

    // input    [3:0]  s0_axi_w_fifo_wid,
    // input    [3:0]  s1_axi_w_fifo_wid,
    // input    [3:0]  s2_axi_w_fifo_wid         

);

    // 从机 0 
    wire aw_decoder_m0_to_s0_valid;
    assign aw_decoder_m0_to_s0_valid = aw_decoder_valid_s0 && (aw_decoder_awaddr_s0[13:12] == 2'b00) && region_write_table_m0[0];
    wire aw_decoder_m1_to_s0_valid;
    assign aw_decoder_m1_to_s0_valid = aw_decoder_valid_s1 && (aw_decoder_awaddr_s1[13:12] == 2'b00) && region_write_table_m1[0];
    wire aw_decoder_m2_to_s0_valid;
    assign aw_decoder_m2_to_s0_valid = aw_decoder_valid_s2 && (aw_decoder_awaddr_s2[13:12] == 2'b00) && region_write_table_m2[0]; 
    wire   aw_arbiter_s0_to_m0_ready;
    wire   aw_arbiter_s0_to_m1_ready;
    wire   aw_arbiter_s0_to_m2_ready;

    write_address_arbiter S0_dut(
        .clk(clk),
        .rst_n(rst_n),
        
        .aw_decoder_awaddr_s0(aw_decoder_awaddr_s0[11:0]),
        .aw_decoder_awlen_s0(aw_decoder_awlen_s0),
        .aw_decoder_awsize_s0(aw_decoder_awsize_s0),
        .aw_decoder_awburst_s0(aw_decoder_awburst_s0),
        .aw_decoder_awid_s0(aw_decoder_awid_s0),
        .aw_decoder_valid_s0(aw_decoder_m0_to_s0_valid ),
        .aw_decoder_ready_s0(aw_arbiter_s0_to_m0_ready),

        .aw_decoder_awaddr_s1(aw_decoder_awaddr_s1[11:0]),
        .aw_decoder_awlen_s1(aw_decoder_awlen_s1),
        .aw_decoder_awsize_s1(aw_decoder_awsize_s1),
        .aw_decoder_awburst_s1(aw_decoder_awburst_s1),
        .aw_decoder_awid_s1(aw_decoder_awid_s1),
        .aw_decoder_valid_s1(aw_decoder_m1_to_s0_valid),
        .aw_decoder_ready_s1(aw_arbiter_s0_to_m1_ready),

        .aw_decoder_awaddr_s2(aw_decoder_awaddr_s2[11:0]),
        .aw_decoder_awlen_s2(aw_decoder_awlen_s2),
        .aw_decoder_awsize_s2(aw_decoder_awsize_s2),
        .aw_decoder_awburst_s2(aw_decoder_awburst_s2),
        .aw_decoder_awid_s2(aw_decoder_awid_s2),
        .aw_decoder_valid_s2(aw_decoder_m2_to_s0_valid),
        .aw_decoder_ready_s2(aw_arbiter_s0_to_m2_ready),
        
        .m_axi_arbiter_awaddr(m0_axi_arbiter_awaddr),
        .m_axi_arbiter_awlen(m0_axi_arbiter_awlen),
        .m_axi_arbiter_awsize(m0_axi_arbiter_awsize),
        .m_axi_arbiter_awburst(m0_axi_arbiter_awburst),
        .m_axi_arbiter_awid(m0_axi_arbiter_awid),
        .m_axi_arbiter_valid(m0_axi_arbiter_valid),
        .m_axi_arbiter_ready(m0_axi_arbiter_ready)

    );




    // 从机1

    wire aw_decoder_m0_to_s1_valid;
    assign aw_decoder_m0_to_s1_valid = aw_decoder_valid_s0 && (aw_decoder_awaddr_s0[13:12] == 2'b01) && region_write_table_m0[1];
    wire aw_decoder_m1_to_s1_valid;
    assign aw_decoder_m1_to_s1_valid = aw_decoder_valid_s1 && (aw_decoder_awaddr_s1[13:12] == 2'b01) && region_write_table_m1[1];
    wire aw_decoder_m2_to_s1_valid;
    assign aw_decoder_m2_to_s1_valid = aw_decoder_valid_s2 && (aw_decoder_awaddr_s2[13:12] == 2'b01) && region_write_table_m2[1]; 
    wire   aw_arbiter_s1_to_m0_ready;
    wire   aw_arbiter_s1_to_m1_ready;
    wire   aw_arbiter_s1_to_m2_ready;

    write_address_arbiter S1_dut(
        .clk(clk),
        .rst_n(rst_n),
        
        .aw_decoder_awaddr_s0(aw_decoder_awaddr_s0[11:0]),
        .aw_decoder_awlen_s0(aw_decoder_awlen_s0),
        .aw_decoder_awsize_s0(aw_decoder_awsize_s0),
        .aw_decoder_awburst_s0(aw_decoder_awburst_s0),
        .aw_decoder_awid_s0(aw_decoder_awid_s0),
        .aw_decoder_valid_s0(aw_decoder_m0_to_s1_valid ),
        .aw_decoder_ready_s0(aw_arbiter_s1_to_m0_ready),

        .aw_decoder_awaddr_s1(aw_decoder_awaddr_s1[11:0]),
        .aw_decoder_awlen_s1(aw_decoder_awlen_s1),
        .aw_decoder_awsize_s1(aw_decoder_awsize_s1),
        .aw_decoder_awburst_s1(aw_decoder_awburst_s1),
        .aw_decoder_awid_s1(aw_decoder_awid_s1),
        .aw_decoder_valid_s1(aw_decoder_m1_to_s1_valid),
        .aw_decoder_ready_s1(aw_arbiter_s1_to_m1_ready),

        .aw_decoder_awaddr_s2(aw_decoder_awaddr_s2[11:0]),
        .aw_decoder_awlen_s2(aw_decoder_awlen_s2),
        .aw_decoder_awsize_s2(aw_decoder_awsize_s2),
        .aw_decoder_awburst_s2(aw_decoder_awburst_s2),
        .aw_decoder_awid_s2(aw_decoder_awid_s2),
        .aw_decoder_valid_s2(aw_decoder_m2_to_s1_valid),
        .aw_decoder_ready_s2(aw_arbiter_s1_to_m2_ready),
        
        .m_axi_arbiter_awaddr(m1_axi_arbiter_awaddr),
        .m_axi_arbiter_awlen(m1_axi_arbiter_awlen),
        .m_axi_arbiter_awsize(m1_axi_arbiter_awsize),
        .m_axi_arbiter_awburst(m1_axi_arbiter_awburst),
        .m_axi_arbiter_awid(m1_axi_arbiter_awid),
        .m_axi_arbiter_valid(m1_axi_arbiter_valid),
        .m_axi_arbiter_ready(m1_axi_arbiter_ready)

    );

    // 从机2
    wire aw_decoder_m0_to_s2_valid;
    assign aw_decoder_m0_to_s2_valid = aw_decoder_valid_s0 && (aw_decoder_awaddr_s0[13:12] == 2'b10) && region_write_table_m0[2];
    wire aw_decoder_m1_to_s2_valid;
    assign aw_decoder_m1_to_s2_valid = aw_decoder_valid_s1 && (aw_decoder_awaddr_s1[13:12] == 2'b10) && region_write_table_m1[2];
    wire aw_decoder_m2_to_s2_valid;
    assign aw_decoder_m2_to_s2_valid = aw_decoder_valid_s2 && (aw_decoder_awaddr_s2[13:12] == 2'b10) && region_write_table_m2[2];
    wire   aw_arbiter_s2_to_m0_ready;
    wire   aw_arbiter_s2_to_m1_ready;
    wire   aw_arbiter_s2_to_m2_ready;
     

    write_address_arbiter S2_dut(
        .clk(clk),
        .rst_n(rst_n),
        
        .aw_decoder_awaddr_s0(aw_decoder_awaddr_s0[11:0]),
        .aw_decoder_awlen_s0(aw_decoder_awlen_s0),
        .aw_decoder_awsize_s0(aw_decoder_awsize_s0),
        .aw_decoder_awburst_s0(aw_decoder_awburst_s0),
        .aw_decoder_awid_s0(aw_decoder_awid_s0),
        .aw_decoder_valid_s0(aw_decoder_m0_to_s2_valid ),
        .aw_decoder_ready_s0(aw_arbiter_s2_to_m0_ready),

        .aw_decoder_awaddr_s1(aw_decoder_awaddr_s1[11:0]),
        .aw_decoder_awlen_s1(aw_decoder_awlen_s1),
        .aw_decoder_awsize_s1(aw_decoder_awsize_s1),
        .aw_decoder_awburst_s1(aw_decoder_awburst_s1),
        .aw_decoder_awid_s1(aw_decoder_awid_s1),
        .aw_decoder_valid_s1(aw_decoder_m1_to_s2_valid),
        .aw_decoder_ready_s1(aw_arbiter_s2_to_m1_ready),

        .aw_decoder_awaddr_s2(aw_decoder_awaddr_s2[11:0]),
        .aw_decoder_awlen_s2(aw_decoder_awlen_s2),
        .aw_decoder_awsize_s2(aw_decoder_awsize_s2),
        .aw_decoder_awburst_s2(aw_decoder_awburst_s2),
        .aw_decoder_awid_s2(aw_decoder_awid_s2),
        .aw_decoder_valid_s2(aw_decoder_m2_to_s2_valid),
        .aw_decoder_ready_s2(aw_arbiter_s2_to_m2_ready),
        
        .m_axi_arbiter_awaddr(m2_axi_arbiter_awaddr),
        .m_axi_arbiter_awlen(m2_axi_arbiter_awlen),
        .m_axi_arbiter_awsize(m2_axi_arbiter_awsize),
        .m_axi_arbiter_awburst(m2_axi_arbiter_awburst),
        .m_axi_arbiter_awid(m2_axi_arbiter_awid),
        .m_axi_arbiter_valid(m2_axi_arbiter_valid),
        .m_axi_arbiter_ready(m2_axi_arbiter_ready)

    );


    reg s0_aw_ready_mux;
    reg s1_aw_ready_mux;
    reg s2_aw_ready_mux;

    

// 主机 0 invalidtable
    reg [3:0] m0_transaction_id[2:0];
    reg [2:0] m0_invalid;
    // wire m0_invalid_en;
    // assign m0_invalid_en = !(&m0_invalid);
    integer  i;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            m0_invalid <= 3'b0;
            for( i = 0 ; i < 3; i=i+1)  begin
                m0_transaction_id[i] <= 4'd0;
            end
        end
        else begin
            if(aw_decoder_valid_s0 && (((aw_decoder_awaddr_s0[13:12] == 2'b00) && (!region_write_table_m0[0])) || ((aw_decoder_awaddr_s0[13:12] == 2'b01) && (!region_write_table_m0[1])) || ((aw_decoder_awaddr_s0[13:12] == 2'b10) && (!region_write_table_m0[2])) )) begin
                casez(m0_invalid)
                    3'b??0: begin
                            m0_invalid[0] <= 1'b1;
                            m0_transaction_id[0] <= aw_decoder_awid_s0[3:0];
                    end
                    3'b?01: begin
                            m0_invalid[1] <= 1'b1;
                            m0_transaction_id[1] <= aw_decoder_awid_s0[3:0];
                    end
                    3'b011: begin
                            m0_invalid[2] <= 1'b1;
                            m0_transaction_id[2] <= aw_decoder_awid_s0[3:0];
                    end
                endcase
            end
            if(s0_axi_invalid_fire) begin
                if((m0_invalid[0]== 1'b1) && (m0_transaction_id[0] ==  s0_axi_invalid_wid))
                    m0_invalid[0] <= 1'b0;
                else if((m0_invalid[1]== 1'b1) && (m0_transaction_id[1] ==  s0_axi_invalid_wid))
                    m0_invalid[1] <= 1'b0;
                else if((m0_invalid[2]== 1'b1) && (m0_transaction_id[2] ==  s0_axi_invalid_wid))
                    m0_invalid[2] <= 1'b0;

            end
        end
    end




// 主机 1 invalidtable
    reg [3:0] m1_transaction_id[2:0];
    reg [2:0] m1_invalid;
    // wire m1_invalid_en;
    // assign m1_invalid_en = !(&m1_invalid);

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            m1_invalid <= 3'b0;
            for( i = 0 ; i < 3; i=i+1)  begin
                m1_transaction_id[i] <= 4'd0;
            end
        end
        else begin
            if(aw_decoder_valid_s1 && (((aw_decoder_awaddr_s1[13:12] == 2'b00) && (!region_write_table_m1[0])) || ((aw_decoder_awaddr_s1[13:12] == 2'b01) && (!region_write_table_m1[1])) || ((aw_decoder_awaddr_s1[13:12] == 2'b10) && (!region_write_table_m1[2])) )) begin
                casez(m1_invalid)
                    3'b??0: begin
                            m1_invalid[0] <= 1'b1;
                            m1_transaction_id[0] <= aw_decoder_awid_s1[3:0];
                    end
                    3'b?01: begin
                            m1_invalid[1] <= 1'b1;
                            m1_transaction_id[1] <= aw_decoder_awid_s1[3:0];
                    end
                    3'b011: begin
                            m1_invalid[2] <= 1'b1;
                            m1_transaction_id[2] <= aw_decoder_awid_s1[3:0];
                    end
                endcase
            end
            if(s1_axi_invalid_fire) begin
                if((m1_invalid[0]== 1'b1) && (m1_transaction_id[0] ==  s1_axi_invalid_wid))
                    m1_invalid[0] <= 1'b0;
                else if((m1_invalid[1]== 1'b1) && (m1_transaction_id[1] ==  s1_axi_invalid_wid))
                    m1_invalid[1] <= 1'b0;
                else if((m1_invalid[2]== 1'b1) && (m1_transaction_id[2] ==  s1_axi_invalid_wid))
                    m1_invalid[2] <= 1'b0;

            end
        end
    end


    

// 主机 2 invalidtable
    reg [3:0] m2_transaction_id[2:0];
    reg [2:0] m2_invalid;
    // wire      m2_invalid_en;
    // assign    m2_invalid_en = !(&m2_invalid);

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            m2_invalid <= 3'b0;
            for( i = 0 ; i < 3; i=i+1)  begin
                m2_transaction_id[i] <= 4'd0;
            end
        end
        else begin
            if(aw_decoder_valid_s2 && (((aw_decoder_awaddr_s2[13:12] == 2'b00) && (!region_write_table_m2[0])) || ((aw_decoder_awaddr_s2[13:12] == 2'b01) && (!region_write_table_m2[1])) || ((aw_decoder_awaddr_s2[13:12] == 2'b10) && (!region_write_table_m2[2])) )) begin
                casez(m2_invalid)
                    3'b??0: begin
                            m2_invalid[0] <= 1'b1;
                            m2_transaction_id[0] <= aw_decoder_awid_s2[3:0];
                    end
                    3'b?01: begin
                            m2_invalid[1] <= 1'b1;
                            m2_transaction_id[1] <= aw_decoder_awid_s2[3:0];
                    end
                    3'b011: begin
                            m2_invalid[2] <= 1'b1;
                            m2_transaction_id[2] <= aw_decoder_awid_s2[3:0];
                    end
                endcase
            end
            if(s2_axi_invalid_fire) begin
                if((m2_invalid[0]== 1'b1) && (m2_transaction_id[0] ==  s2_axi_invalid_wid))
                    m2_invalid[0] <= 1'b0;
                else if((m2_invalid[1]== 1'b1) && (m2_transaction_id[1] ==  s2_axi_invalid_wid))
                    m2_invalid[1] <= 1'b0;
                else if((m2_invalid[2]== 1'b1) && (m2_transaction_id[2] ==  s2_axi_invalid_wid))
                    m2_invalid[2] <= 1'b0;

            end
        end
    end


    always@(*) begin
        case(aw_decoder_awaddr_s0[13:12]) 
            2'b00 : s0_aw_ready_mux = aw_arbiter_s0_to_m0_ready || (!region_write_table_m0[0]);
            2'b01 : s0_aw_ready_mux = aw_arbiter_s1_to_m0_ready || (!region_write_table_m0[1]);
            2'b10 : s0_aw_ready_mux = aw_arbiter_s2_to_m0_ready || (!region_write_table_m0[2]);
            default : s0_aw_ready_mux = 1'b1;
        endcase
    end

    always@(*) begin
        case(aw_decoder_awaddr_s1[13:12]) 
            2'b00 : s1_aw_ready_mux = aw_arbiter_s0_to_m1_ready || (!region_write_table_m1[0]);
            2'b01 : s1_aw_ready_mux = aw_arbiter_s1_to_m1_ready || (!region_write_table_m1[1]);
            2'b10 : s1_aw_ready_mux = aw_arbiter_s2_to_m1_ready || (!region_write_table_m1[2]);
            default : s1_aw_ready_mux = 1'b1;
        endcase
    end

    always@(*) begin
        case(aw_decoder_awaddr_s2[13:12]) 
            2'b00 : s2_aw_ready_mux = aw_arbiter_s0_to_m2_ready || (!region_write_table_m2[0]);
            2'b01 : s2_aw_ready_mux = aw_arbiter_s1_to_m2_ready || (!region_write_table_m2[1]);
            2'b10 : s2_aw_ready_mux = aw_arbiter_s2_to_m2_ready || (!region_write_table_m2[2]);
            default : s2_aw_ready_mux = 1'b1;
        endcase
    end

    assign aw_decoder_ready_s0 = s0_aw_ready_mux;
    assign aw_decoder_ready_s1 = s1_aw_ready_mux;
    assign aw_decoder_ready_s2 = s2_aw_ready_mux;

    assign m0_transaction_invalidid0 = m0_transaction_id[0];
    assign m0_transaction_invalidid1 = m0_transaction_id[1];
    assign m0_transaction_invalidid2 = m0_transaction_id[2];
    assign m0invalid = m0_invalid;


    assign m1_transaction_invalidid0 = m1_transaction_id[0];
    assign m1_transaction_invalidid1 = m1_transaction_id[1];
    assign m1_transaction_invalidid2 = m1_transaction_id[2];
    assign m1invalid = m1_invalid;

    assign m2_transaction_invalidid0 = m2_transaction_id[0];
    assign m2_transaction_invalidid1 = m2_transaction_id[1];
    assign m2_transaction_invalidid2 = m2_transaction_id[2];
    assign m2invalid = m2_invalid;


    










endmodule