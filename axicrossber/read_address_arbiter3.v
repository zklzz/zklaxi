// 对于三个主机的访问针对每一个从机进行仲裁，这里会根据访问权限设置invalidtable，每个主机有一个独立的invalidtable


module read_address_arbiter3 (
    input clk,
    input rst_n,

    input [13:0] ar_decoder_araddr_s0,
    input [7:0]  ar_decoder_arlen_s0,
    input [2:0]  ar_decoder_arsize_s0,
    input [1:0]  ar_decoder_arburst_s0,
    input [5:0]  ar_decoder_arid_s0,
    input        ar_decoder_valid_s0,
    output       ar_decoder_ready_s0,

    input [13:0] ar_decoder_araddr_s1,
    input [7:0]  ar_decoder_arlen_s1,
    input [2:0]  ar_decoder_arsize_s1,
    input [1:0]  ar_decoder_arburst_s1,
    input [5:0]  ar_decoder_arid_s1,
    input        ar_decoder_valid_s1,
    output       ar_decoder_ready_s1,

    input [13:0]  ar_decoder_araddr_s2,
    input [7:0]   ar_decoder_arlen_s2,
    input [2:0]   ar_decoder_arsize_s2,
    input [1:0]   ar_decoder_arburst_s2,
    input [5:0]   ar_decoder_arid_s2,
    input         ar_decoder_valid_s2,
    output        ar_decoder_ready_s2,

    output [11:0] m0_axi_arbiter_araddr,
    output [7:0]  m0_axi_arbiter_arlen,
    output [2:0]  m0_axi_arbiter_arsize,
    output [1:0]  m0_axi_arbiter_arburst,
    output [5:0]  m0_axi_arbiter_arid,
    output        m0_axi_arbiter_valid,
    input         m0_axi_arbiter_ready,

    output [11:0] m1_axi_arbiter_araddr,
    output [7:0]  m1_axi_arbiter_arlen,
    output [2:0]  m1_axi_arbiter_arsize,
    output [1:0]  m1_axi_arbiter_arburst,
    output [5:0]  m1_axi_arbiter_arid,
    output        m1_axi_arbiter_valid,
    input         m1_axi_arbiter_ready,


    output [11:0] m2_axi_arbiter_araddr,
    output [7:0]  m2_axi_arbiter_arlen,
    output [2:0]  m2_axi_arbiter_arsize,
    output [1:0]  m2_axi_arbiter_arburst,
    output [5:0]  m2_axi_arbiter_arid,
    output        m2_axi_arbiter_valid,
    input         m2_axi_arbiter_ready,

    input   [2:0] region_read_table_m0,//主机m0对从机访问权限 高位从机2 低位从机0
    input   [2:0] region_read_table_m1,//主机m1对从机访问权限
    input   [2:0] region_read_table_m2,//主机m2对从机访问权限



// 虚拟从机的读rlast
    input         s0_vir_rlast,
    input   [2:0] s0_vir_rid,

    input         s1_vir_rlast,
    input   [2:0] s1_vir_rid,

    input         s2_vir_rlast,
    input   [2:0] s2_vir_rid,



// 与write_data_fifo_lut 交互
    output  [ 3:0]  m0_transaction_invalidid0,
    output  [ 3:0]  m0_transaction_invalidid1,
    output  [ 3:0]  m0_transaction_invalidid2,
    output  [ 7:0]  m0_invalid_len0,
    output  [ 7:0]  m0_invalid_len1,
    output  [ 7:0]  m0_invalid_len2,
    output  [ 2:0]  m0invalid,

    output  [ 3:0]  m1_transaction_invalidid0,
    output  [ 3:0]  m1_transaction_invalidid1,
    output  [ 3:0]  m1_transaction_invalidid2,
    output  [ 7:0]  m1_invalid_len0,
    output  [ 7:0]  m1_invalid_len1,
    output  [ 7:0]  m1_invalid_len2,
    output  [ 2:0]  m1invalid,


    output  [ 3:0]  m2_transaction_invalidid0,
    output  [ 3:0]  m2_transaction_invalidid1,
    output  [ 3:0]  m2_transaction_invalidid2,
    output  [ 7:0]  m2_invalid_len0,
    output  [ 7:0]  m2_invalid_len1,
    output  [ 7:0]  m2_invalid_len2,
    output  [ 2:0]  m2invalid




    // input         s0_axi_w_fifo_flush,
    // input         s1_axi_w_fifo_flush,
    // input         s2_axi_w_fifo_flush,

    // input    [3:0]  s0_axi_w_fifo_wid,
    // input    [3:0]  s1_axi_w_fifo_wid,
    // input    [3:0]  s2_axi_w_fifo_wid         

);

    // 从机 0 
    wire ar_decoder_m0_to_s0_valid;
    assign ar_decoder_m0_to_s0_valid = ar_decoder_valid_s0 && (ar_decoder_araddr_s0[13:12] == 2'b00) && region_read_table_m0[0];
    wire ar_decoder_m1_to_s0_valid;
    assign ar_decoder_m1_to_s0_valid = ar_decoder_valid_s1 && (ar_decoder_araddr_s1[13:12] == 2'b00) && region_read_table_m1[0];
    wire ar_decoder_m2_to_s0_valid;
    assign ar_decoder_m2_to_s0_valid = ar_decoder_valid_s2 && (ar_decoder_araddr_s2[13:12] == 2'b00) && region_read_table_m2[0]; 
    wire   ar_arbiter_s0_to_m0_ready;
    wire   ar_arbiter_s0_to_m1_ready;
    wire   ar_arbiter_s0_to_m2_ready;

    read_address_arbiter S0_dut(
        .clk(clk),
        .rst_n(rst_n),
        
        .ar_decoder_araddr_s0(ar_decoder_araddr_s0[11:0]),
        .ar_decoder_arlen_s0(ar_decoder_arlen_s0),
        .ar_decoder_arsize_s0(ar_decoder_arsize_s0),
        .ar_decoder_arburst_s0(ar_decoder_arburst_s0),
        .ar_decoder_arid_s0(ar_decoder_arid_s0),
        .ar_decoder_valid_s0(ar_decoder_m0_to_s0_valid ),
        .ar_decoder_ready_s0(ar_arbiter_s0_to_m0_ready),

        .ar_decoder_araddr_s1(ar_decoder_araddr_s1[11:0]),
        .ar_decoder_arlen_s1(ar_decoder_arlen_s1),
        .ar_decoder_arsize_s1(ar_decoder_arsize_s1),
        .ar_decoder_arburst_s1(ar_decoder_arburst_s1),
        .ar_decoder_arid_s1(ar_decoder_arid_s1),
        .ar_decoder_valid_s1(ar_decoder_m1_to_s0_valid),
        .ar_decoder_ready_s1(ar_arbiter_s0_to_m1_ready),

        .ar_decoder_araddr_s2(ar_decoder_araddr_s2[11:0]),
        .ar_decoder_arlen_s2(ar_decoder_arlen_s2),
        .ar_decoder_arsize_s2(ar_decoder_arsize_s2),
        .ar_decoder_arburst_s2(ar_decoder_arburst_s2),
        .ar_decoder_arid_s2(ar_decoder_arid_s2),
        .ar_decoder_valid_s2(ar_decoder_m2_to_s0_valid),
        .ar_decoder_ready_s2(ar_arbiter_s0_to_m2_ready),
        
        .m_axi_arbiter_araddr(m0_axi_arbiter_araddr),
        .m_axi_arbiter_arlen(m0_axi_arbiter_arlen),
        .m_axi_arbiter_arsize(m0_axi_arbiter_arsize),
        .m_axi_arbiter_arburst(m0_axi_arbiter_arburst),
        .m_axi_arbiter_arid(m0_axi_arbiter_arid),
        .m_axi_arbiter_valid(m0_axi_arbiter_valid),
        .m_axi_arbiter_ready(m0_axi_arbiter_ready)

    );




    // 从机1

    wire ar_decoder_m0_to_s1_valid;
    assign ar_decoder_m0_to_s1_valid = ar_decoder_valid_s0 && (ar_decoder_araddr_s0[13:12] == 2'b01) && region_read_table_m0[1];
    wire ar_decoder_m1_to_s1_valid;
    assign ar_decoder_m1_to_s1_valid = ar_decoder_valid_s1 && (ar_decoder_araddr_s1[13:12] == 2'b01) && region_read_table_m1[1];
    wire ar_decoder_m2_to_s1_valid;
    assign ar_decoder_m2_to_s1_valid = ar_decoder_valid_s2 && (ar_decoder_araddr_s2[13:12] == 2'b01) && region_read_table_m2[1]; 
    wire   ar_arbiter_s1_to_m0_ready;
    wire   ar_arbiter_s1_to_m1_ready;
    wire   ar_arbiter_s1_to_m2_ready;

    read_address_arbiter S1_dut(
        .clk(clk),
        .rst_n(rst_n),
        
        .ar_decoder_araddr_s0(ar_decoder_araddr_s0[11:0]),
        .ar_decoder_arlen_s0(ar_decoder_arlen_s0),
        .ar_decoder_arsize_s0(ar_decoder_arsize_s0),
        .ar_decoder_arburst_s0(ar_decoder_arburst_s0),
        .ar_decoder_arid_s0(ar_decoder_arid_s0),
        .ar_decoder_valid_s0(ar_decoder_m0_to_s1_valid ),
        .ar_decoder_ready_s0(ar_arbiter_s1_to_m0_ready),

        .ar_decoder_araddr_s1(ar_decoder_araddr_s1[11:0]),
        .ar_decoder_arlen_s1(ar_decoder_arlen_s1),
        .ar_decoder_arsize_s1(ar_decoder_arsize_s1),
        .ar_decoder_arburst_s1(ar_decoder_arburst_s1),
        .ar_decoder_arid_s1(ar_decoder_arid_s1),
        .ar_decoder_valid_s1(ar_decoder_m1_to_s1_valid),
        .ar_decoder_ready_s1(ar_arbiter_s1_to_m1_ready),

        .ar_decoder_araddr_s2(ar_decoder_araddr_s2[11:0]),
        .ar_decoder_arlen_s2(ar_decoder_arlen_s2),
        .ar_decoder_arsize_s2(ar_decoder_arsize_s2),
        .ar_decoder_arburst_s2(ar_decoder_arburst_s2),
        .ar_decoder_arid_s2(ar_decoder_arid_s2),
        .ar_decoder_valid_s2(ar_decoder_m2_to_s1_valid),
        .ar_decoder_ready_s2(ar_arbiter_s1_to_m2_ready),
        
        .m_axi_arbiter_araddr(m1_axi_arbiter_araddr),
        .m_axi_arbiter_arlen(m1_axi_arbiter_arlen),
        .m_axi_arbiter_arsize(m1_axi_arbiter_arsize),
        .m_axi_arbiter_arburst(m1_axi_arbiter_arburst),
        .m_axi_arbiter_arid(m1_axi_arbiter_arid),
        .m_axi_arbiter_valid(m1_axi_arbiter_valid),
        .m_axi_arbiter_ready(m1_axi_arbiter_ready)

    );

    // 从机2
    wire ar_decoder_m0_to_s2_valid;
    assign ar_decoder_m0_to_s2_valid = ar_decoder_valid_s0 && (ar_decoder_araddr_s0[13:12] == 2'b10) && region_read_table_m0[2];
    wire ar_decoder_m1_to_s2_valid;
    assign ar_decoder_m1_to_s2_valid = ar_decoder_valid_s1 && (ar_decoder_araddr_s1[13:12] == 2'b10) && region_read_table_m1[2];
    wire ar_decoder_m2_to_s2_valid;
    assign ar_decoder_m2_to_s2_valid = ar_decoder_valid_s2 && (ar_decoder_araddr_s2[13:12] == 2'b10) && region_read_table_m2[2];
    wire   ar_arbiter_s2_to_m0_ready;
    wire   ar_arbiter_s2_to_m1_ready;
    wire   ar_arbiter_s2_to_m2_ready;
     

    read_address_arbiter S2_dut(
        .clk(clk),
        .rst_n(rst_n),
        
        .ar_decoder_araddr_s0(ar_decoder_araddr_s0[11:0]),
        .ar_decoder_arlen_s0(ar_decoder_arlen_s0),
        .ar_decoder_arsize_s0(ar_decoder_arsize_s0),
        .ar_decoder_arburst_s0(ar_decoder_arburst_s0),
        .ar_decoder_arid_s0(ar_decoder_arid_s0),
        .ar_decoder_valid_s0(ar_decoder_m0_to_s2_valid ),
        .ar_decoder_ready_s0(ar_arbiter_s2_to_m0_ready),

        .ar_decoder_araddr_s1(ar_decoder_araddr_s1[11:0]),
        .ar_decoder_arlen_s1(ar_decoder_arlen_s1),
        .ar_decoder_arsize_s1(ar_decoder_arsize_s1),
        .ar_decoder_arburst_s1(ar_decoder_arburst_s1),
        .ar_decoder_arid_s1(ar_decoder_arid_s1),
        .ar_decoder_valid_s1(ar_decoder_m1_to_s2_valid),
        .ar_decoder_ready_s1(ar_arbiter_s2_to_m1_ready),

        .ar_decoder_araddr_s2(ar_decoder_araddr_s2[11:0]),
        .ar_decoder_arlen_s2(ar_decoder_arlen_s2),
        .ar_decoder_arsize_s2(ar_decoder_arsize_s2),
        .ar_decoder_arburst_s2(ar_decoder_arburst_s2),
        .ar_decoder_arid_s2(ar_decoder_arid_s2),
        .ar_decoder_valid_s2(ar_decoder_m2_to_s2_valid),
        .ar_decoder_ready_s2(ar_arbiter_s2_to_m2_ready),
        
        .m_axi_arbiter_araddr(m2_axi_arbiter_araddr),
        .m_axi_arbiter_arlen(m2_axi_arbiter_arlen),
        .m_axi_arbiter_arsize(m2_axi_arbiter_arsize),
        .m_axi_arbiter_arburst(m2_axi_arbiter_arburst),
        .m_axi_arbiter_arid(m2_axi_arbiter_arid),
        .m_axi_arbiter_valid(m2_axi_arbiter_valid),
        .m_axi_arbiter_ready(m2_axi_arbiter_ready)

    );


    reg s0_ar_ready_mux;
    reg s1_ar_ready_mux;
    reg s2_ar_ready_mux;

    

// 主机0 的invalidtable
    reg [3:0] m0_transaction_id[2:0];
    reg [2:0] m0_invalid;
    reg [7:0] m0_rlen[2:0];
    // wire m0_invalid_en;
    // assign m0_invalid_en = !(&m0_invalid);
    integer  i;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            m0_invalid <= 3'b0;
            for( i = 0 ; i < 3; i=i+1)  begin
                m0_transaction_id[i] <= 4'd0;
                m0_rlen[i]           <= 8'd0;
            end
        end
        else begin
            if(ar_decoder_valid_s0 && (((ar_decoder_araddr_s0[13:12] == 2'b00) && (!region_read_table_m0[0])) || ((ar_decoder_araddr_s0[13:12] == 2'b01) && (!region_read_table_m0[1])) || ((ar_decoder_araddr_s0[13:12] == 2'b10) && (!region_read_table_m0[2])) )) begin
                casez(m0_invalid)
                    3'b??0: begin
                            m0_invalid[0] <= 1'b1;
                            m0_transaction_id[0] <= ar_decoder_arid_s0[3:0];
                            m0_rlen[0]     <=  ar_decoder_arlen_s0;
                    end
                    3'b?01: begin
                            m0_invalid[1] <= 1'b1;
                            m0_transaction_id[1] <= ar_decoder_arid_s0[3:0];
                            m0_rlen[1]    <=  ar_decoder_arlen_s0;
                    end
                    3'b011: begin
                            m0_invalid[2] <= 1'b1;
                            m0_transaction_id[2] <= ar_decoder_arid_s0[3:0];
                            m0_rlen[2]    <=  ar_decoder_arlen_s0;
                    end
                endcase
            end
            if(s0_vir_rlast) begin
                if((m0_invalid[0]== 1'b1) && (m0_transaction_id[0] ==  s0_vir_rid))
                    m0_invalid[0] <= 1'b0;
                else if((m0_invalid[1]== 1'b1) && (m0_transaction_id[1] ==  s0_vir_rid))
                    m0_invalid[1] <= 1'b0;
                else if((m0_invalid[2]== 1'b1) && (m0_transaction_id[2] ==  s0_vir_rid))
                    m0_invalid[2] <= 1'b0;

            end
        end
    end


// 主机1 的invalidtable

    reg [3:0] m1_transaction_id[2:0];
    reg [2:0] m1_invalid;
    reg [7:0] m1_rlen[2:0];
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
            if(ar_decoder_valid_s1 && (((ar_decoder_araddr_s1[13:12] == 2'b00) && (!region_read_table_m1[0])) || ((ar_decoder_araddr_s1[13:12] == 2'b01) && (!region_read_table_m1[1])) || ((ar_decoder_araddr_s1[13:12] == 2'b10) && (!region_read_table_m1[2])) )) begin
                casez(m1_invalid)
                    3'b??0: begin
                            m1_invalid[0] <= 1'b1;
                            m1_transaction_id[0] <= ar_decoder_arid_s1[3:0];
                            m1_rlen[0]     <=  ar_decoder_arlen_s1;
                    end
                    3'b?01: begin
                            m1_invalid[1] <= 1'b1;
                            m1_transaction_id[1] <= ar_decoder_arid_s1[3:0];
                            m1_rlen[1]     <=  ar_decoder_arlen_s1;
                    end
                    3'b011: begin
                            m1_invalid[2] <= 1'b1;
                            m1_transaction_id[2] <= ar_decoder_arid_s1[3:0];
                            m1_rlen[2]     <=  ar_decoder_arlen_s1;
                    end
                endcase
            end
            if(s1_vir_rlast) begin
                if((m1_invalid[0]== 1'b1) && (m1_transaction_id[0] ==  s1_vir_rid))
                    m1_invalid[0] <= 1'b0;
                else if((m1_invalid[1]== 1'b1) && (m1_transaction_id[1] ==  s1_vir_rid))
                    m1_invalid[1] <= 1'b0;
                else if((m1_invalid[2]== 1'b1) && (m1_transaction_id[2] ==  s1_vir_rid))
                    m1_invalid[2] <= 1'b0;

            end
        end
    end



// 主机2 的invalidtable
    reg [3:0] m2_transaction_id[2:0];
    reg [2:0] m2_invalid;
    reg [7:0] m2_rlen[2:0];
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
            if(ar_decoder_valid_s2 && (((ar_decoder_araddr_s2[13:12] == 2'b00) && (!region_read_table_m2[0])) || ((ar_decoder_araddr_s2[13:12] == 2'b01) && (!region_read_table_m2[1])) || ((ar_decoder_araddr_s2[13:12] == 2'b10) && (!region_read_table_m2[2])) )) begin
                casez(m2_invalid)
                    3'b??0: begin
                            m2_invalid[0] <= 1'b1;
                            m2_transaction_id[0] <= ar_decoder_arid_s2[3:0];
                            m2_rlen[0]     <=  ar_decoder_arlen_s2;
                    end
                    3'b?01: begin
                            m2_invalid[1] <= 1'b1;
                            m2_transaction_id[1] <= ar_decoder_arid_s2[3:0];
                            m2_rlen[1]     <=  ar_decoder_arlen_s2;
                    end
                    3'b011: begin
                            m2_invalid[2] <= 1'b1;
                            m2_transaction_id[2] <= ar_decoder_arid_s2[3:0];
                            m2_rlen[2]     <=  ar_decoder_arlen_s2;
                    end
                endcase
            end
            if(s2_vir_rlast) begin
                if((m2_invalid[0]== 1'b1) && (m2_transaction_id[0] ==  s2_vir_rid))
                    m2_invalid[0] <= 1'b0;
                else if((m2_invalid[1]== 1'b1) && (m2_transaction_id[1] ==  s2_vir_rid))
                    m2_invalid[1] <= 1'b0;
                else if((m2_invalid[2]== 1'b1) && (m2_transaction_id[2] ==  s2_vir_rid))
                    m2_invalid[2] <= 1'b0;

            end
        end
    end


    always@(*) begin
        case(ar_decoder_araddr_s0[13:12]) 
            2'b00 : s0_ar_ready_mux = ar_arbiter_s0_to_m0_ready || (!region_read_table_m0[0]);
            2'b01 : s0_ar_ready_mux = ar_arbiter_s1_to_m0_ready || (!region_read_table_m0[1]);
            2'b10 : s0_ar_ready_mux = ar_arbiter_s2_to_m0_ready || (!region_read_table_m0[2]);
            default : s0_ar_ready_mux = 1'b1;
        endcase
    end

    always@(*) begin
        case(ar_decoder_araddr_s1[13:12]) 
            2'b00 : s1_ar_ready_mux = ar_arbiter_s0_to_m1_ready || (!region_read_table_m1[0]);
            2'b01 : s1_ar_ready_mux = ar_arbiter_s1_to_m1_ready || (!region_read_table_m1[1]);
            2'b10 : s1_ar_ready_mux = ar_arbiter_s2_to_m1_ready || (!region_read_table_m1[2]);
            default : s1_ar_ready_mux = 1'b1;
        endcase
    end

    always@(*) begin
        case(ar_decoder_araddr_s2[13:12]) 
            2'b00 : s2_ar_ready_mux = ar_arbiter_s0_to_m2_ready || (!region_read_table_m2[0]);
            2'b01 : s2_ar_ready_mux = ar_arbiter_s1_to_m2_ready || (!region_read_table_m2[1]);
            2'b10 : s2_ar_ready_mux = ar_arbiter_s2_to_m2_ready || (!region_read_table_m2[2]);
            default : s2_ar_ready_mux = 1'b1;
        endcase
    end

    assign ar_decoder_ready_s0 = s0_ar_ready_mux;
    assign ar_decoder_ready_s1 = s1_ar_ready_mux;
    assign ar_decoder_ready_s2 = s2_ar_ready_mux;

    assign m0_transaction_invalidid0 = m0_transaction_id[0];
    assign m0_transaction_invalidid1 = m0_transaction_id[1];
    assign m0_transaction_invalidid2 = m0_transaction_id[2];
    assign m0_invalid_len0 = m0_rlen[0];
    assign m0_invalid_len1 = m0_rlen[1];
    assign m0_invalid_len2 = m0_rlen[2];
    assign m0invalid = m0_invalid;


    assign m1_transaction_invalidid0 = m1_transaction_id[0];
    assign m1_transaction_invalidid1 = m1_transaction_id[1];
    assign m1_transaction_invalidid2 = m1_transaction_id[2];
    assign m1_invalid_len0 = m1_rlen[0];
    assign m1_invalid_len1 = m1_rlen[1];
    assign m1_invalid_len2 = m1_rlen[2];
    assign m1invalid = m1_invalid;

    assign m2_transaction_invalidid0 = m2_transaction_id[0];
    assign m2_transaction_invalidid1 = m2_transaction_id[1];
    assign m2_transaction_invalidid2 = m2_transaction_id[2];
    assign m2_invalid_len0 = m2_rlen[0];
    assign m2_invalid_len1 = m2_rlen[1];
    assign m2_invalid_len2 = m2_rlen[2];
    assign m2invalid = m2_invalid;


    










endmodule