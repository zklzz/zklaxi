
//主机侧
// 三个从机对应此主机的FIFO + 虚拟从机 进行仲裁

module read_data_arbiter(
    input clk,
    input rst_n,

    input  [ 5:0] s0_to_m_axi_r_rid,
    input  [31:0] s0_to_m_axi_r_rdata,
    input  [ 1:0] s0_to_m_axi_r_rresp,
    input         s0_to_m_axi_r_rlast,
    input         s0_to_m_axi_r_valid,
    output        s0_to_m_axi_r_ready,

    input  [ 5:0] s1_to_m_axi_r_rid,
    input  [31:0] s1_to_m_axi_r_rdata,
    input  [ 1:0] s1_to_m_axi_r_rresp,
    input         s1_to_m_axi_r_rlast,
    input         s1_to_m_axi_r_valid,
    output        s1_to_m_axi_r_ready,

    input  [ 5:0] s2_to_m_axi_r_rid,
    input  [31:0] s2_to_m_axi_r_rdata,
    input  [ 1:0] s2_to_m_axi_r_rresp,
    input         s2_to_m_axi_r_rlast,
    input         s2_to_m_axi_r_valid,
    output        s2_to_m_axi_r_ready,


    output [ 3:0] s_axi_r_rid,
    output [31:0] s_axi_r_rdata,
    output [ 1:0] s_axi_r_rresp,
    output        s_axi_r_rlast,
    output        s_axi_r_valid,
    input         s_axi_r_ready,

//未合并的读last 提供给read_address_arbiter
    output        s_axi_fifo_r_rlast,



//read_address_arbiter提供

    input  [ 3:0]  m_transaction_invalidid0,
    input  [ 3:0]  m_transaction_invalidid1,
    input  [ 3:0]  m_transaction_invalidid2,
    input  [ 7:0]  m_invalid_len0,
    input  [ 7:0]  m_invalid_len1,
    input  [ 7:0]  m_invalid_len2,
    input  [ 2:0]  minvalid,

// 虚拟从机的rlast
    output         s_vir_rlast,
    output [ 2:0]  s_vir_rid,

// read_address_decoder提供
    input   [3:0] r_transactionid0,
    input   [3:0] r_transactionid1,
    input   [3:0] r_transactionid2,
    input   [2:0] itemvalid,
    input   [2:0] fkflag

    

      




);

    reg [7:0] invalid_len;
    reg [7:0] invalid_count;

    reg [3:0] invalid_rid;

    wire      m_invalid = |minvalid && (invalid_count < invalid_len);
    wire      m_invalid_rlast;




    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            invalid_len <= 8'd0;
        else if(minvalid[0])
            invalid_len <= m_invalid_len0;
        else if(minvalid[1])
            invalid_len <= m_invalid_len1;
        else if(minvalid[2])
            invalid_len <= m_invalid_len2;
    end


    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            invalid_rid <= 4'd0;
        else if(minvalid[0])
            invalid_rid <= m_transaction_invalidid0;
        else if(minvalid[1])
            invalid_rid <= m_transaction_invalidid1;
        else if(minvalid[2])
            invalid_rid <= m_transaction_invalidid2;
    end

    wire [ 3:0]  req;
    wire [ 3:0]  grant;


    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            invalid_count <= 8'd0;
        else if(invalid_count == invalid_len)
                invalid_count <= 8'd0;
        else if(grant[3] && s_axi_r_ready )
                invalid_count <= invalid_count + 1'd1;
    end

    assign m_invalid_rlast = (grant[3] && s_axi_r_ready ) && (invalid_count == invalid_len - 1); 

    assign s_vir_rlast = m_invalid_rlast;
    assign s_vir_rid = invalid_rid;


    assign req = {m_invalid,s2_to_m_axi_r_valid,s1_to_m_axi_r_valid,s0_to_m_axi_r_valid};

    reg [3:0] priority;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            priority <= 3'd1;
        else if((|req) && s_axi_r_ready)
            priority <= {grant[1:0],grant[2]};
        else
            priority <= priority;
    end

    reg  [ 3:0] s_axi_arbiter_r_rid;
    reg  [31:0] s_axi_arbiter_r_rdata;
    reg  [ 1:0] s_axi_arbiter_r_rresp;
    reg         s_axi_arbiter_r_rlast;

    always @(*) begin
        case(grant) 
            4'b0001: begin
                s_axi_arbiter_r_rid    = s0_to_m_axi_r_rid;  
                s_axi_arbiter_r_rdata  = s0_to_m_axi_r_rdata;
                s_axi_arbiter_r_rresp  = s0_to_m_axi_r_rresp;
                s_axi_arbiter_r_rlast  = s0_to_m_axi_r_rlast;  
                
            end
            4'b0010: begin
                s_axi_arbiter_r_rid    = s1_to_m_axi_r_rid;  
                s_axi_arbiter_r_rdata  = s1_to_m_axi_r_rdata;
                s_axi_arbiter_r_rresp  = s1_to_m_axi_r_rresp;
                s_axi_arbiter_r_rlast  = s1_to_m_axi_r_rlast;
                
            end
            4'b0100: begin
                s_axi_arbiter_r_rid    = s2_to_m_axi_r_rid;  
                s_axi_arbiter_r_rdata  = s2_to_m_axi_r_rdata;
                s_axi_arbiter_r_rresp  = s2_to_m_axi_r_rresp;
                s_axi_arbiter_r_rlast  = s2_to_m_axi_r_rlast;
            end
            4'b1000: begin
                s_axi_arbiter_r_rid    = invalid_rid;  
                s_axi_arbiter_r_rdata  = 32'd0;
                s_axi_arbiter_r_rresp  = 2'b11;
                s_axi_arbiter_r_rlast  = m_invalid_rlast;
            end
        endcase
    end

    wire [7:0] double_req = {req,req};
    wire [7:0] double_grant = double_req & ~(double_req - priority);


    reg lock;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            lock <= 1'b0;
        else if((|req) && !s_axi_r_ready)
            lock <= 1'b1;
        else if(s_axi_r_ready)
            lock <= 1'b0;
    end


    assign grant = lock ? grant :double_grant[7:4] | double_grant[3:0];

    assign s0_to_m_axi_r_ready = grant[0] && s_axi_r_ready;
    assign s1_to_m_axi_r_ready = grant[1] && s_axi_r_ready;
    assign s2_to_m_axi_r_ready = grant[2] && s_axi_r_ready;


    wire [ 3:0]  fifo_push_payload_rid;
    wire [31:0]  fifo_push_payload_rdata;
    wire [ 1:0]  fifo_push_payload_rresp;
    wire         fifo_push_payload_last;


     wire rid_match0,rid_match1,rid_match2;

     assign rid_match0 = (s_axi_arbiter_r_rid == r_transactionid0) && itemvalid[0] && s_axi_r_valid;
     assign rid_match1 = (s_axi_arbiter_r_rid == r_transactionid1) && itemvalid[1] && s_axi_r_valid;
     assign rid_match2 = (s_axi_arbiter_r_rid == r_transactionid2) && itemvalid[2] && s_axi_r_valid;

     //确保当前table中只有一项匹配且该项为4k边界拆分事务的第一项

     wire [2:0] rid_fk = {rid_match0,rid_match1,rid_match2};

     wire rid_fkmatchleast = (rid_match0 && fkflag[0]) || (rid_match1 && fkflag[1]) || (rid_match2 && fkflag[2]);

     wire rid_fkmatch = ((rid_fk == 3'b100) || (rid_fk == 3'b010) || (rid_fk == 3'b001)) && rid_fkmatchleast;



    assign  s_axi_r_rid   = lock? s_axi_r_rid : s_axi_arbiter_r_rid;
    assign  s_axi_r_rresp = lock? s_axi_r_rresp : s_axi_arbiter_r_rresp;
    assign  s_axi_r_rlast = lock? s_axi_r_rlast  : (s_axi_arbiter_r_rlast && (!rid_fkmatch));
    assign  s_axi_r_rdata = lock? s_axi_r_rdata : s_axi_arbiter_r_rdata;

    assign  s_axi_fifo_r_rlast = lock? s_axi_fifo_r_rlast : s_axi_arbiter_r_rlast;


     assign s_axi_r_valid = |grant;





















endmodule