module read_data(
    input clk,
    input rst_n,


//从机侧
    input  [ 5:0] m0_axi_r_rid,
    input  [31:0] m0_axi_r_rdata,
    input  [ 1:0] m0_axi_r_rresp,
    input         m0_axi_r_rlast,
    input         m0_axi_r_valid,
    output        m0_axi_r_ready,

    input  [ 5:0] m1_axi_r_rid,
    input  [31:0] m1_axi_r_rdata,
    input  [ 1:0] m1_axi_r_rresp,
    input         m1_axi_r_rlast,
    input         m1_axi_r_valid,
    output        m1_axi_r_ready,

    input  [ 5:0] m2_axi_r_rid,
    input  [31:0] m2_axi_r_rdata,
    input  [ 1:0] m2_axi_r_rresp,
    input         m2_axi_r_rlast,
    input         m2_axi_r_valid,
    output        m2_axi_r_ready,


//主机侧
    output [ 3:0] s0_axi_r_rid,
    output [31:0] s0_axi_r_rdata,
    output [ 1:0] s0_axi_r_rresp,
    output        s0_axi_r_rlast,
    output        s0_axi_r_valid,
    input         s0_axi_r_ready,

    output        s0_axi_fifo_r_rlast,

    output [ 3:0] s1_axi_r_rid,
    output [31:0] s1_axi_r_rdata,
    output [ 1:0] s1_axi_r_rresp,
    output        s1_axi_r_rlast,
    output        s1_axi_r_valid,
    input         s1_axi_r_ready,

    output        s1_axi_fifo_r_rlast, 

    output [ 3:0] s2_axi_r_rid,
    output [31:0] s2_axi_r_rdata,
    output [ 1:0] s2_axi_r_rresp,
    output        s2_axi_r_rlast,
    output        s2_axi_r_valid,
    input         s2_axi_r_ready,

    output        s2_axi_fifo_r_rlast,     



//read_address_arbiter提供 invalid table
    input  [ 3:0]  m0_transaction_invalidid0,
    input  [ 3:0]  m0_transaction_invalidid1,
    input  [ 3:0]  m0_transaction_invalidid2,
    input  [ 7:0]  m0_invalid_len0,
    input  [ 7:0]  m0_invalid_len1,
    input  [ 7:0]  m0_invalid_len2,
    input  [ 2:0]  m0invalid,

    input  [ 3:0]  m1_transaction_invalidid0,
    input  [ 3:0]  m1_transaction_invalidid1,
    input  [ 3:0]  m1_transaction_invalidid2,
    input  [ 7:0]  m1_invalid_len0,
    input  [ 7:0]  m1_invalid_len1,
    input  [ 7:0]  m1_invalid_len2,
    input  [ 2:0]  m1invalid,

    input  [ 3:0]  m2_transaction_invalidid0,
    input  [ 3:0]  m2_transaction_invalidid1,
    input  [ 3:0]  m2_transaction_invalidid2,
    input  [ 7:0]  m2_invalid_len0,
    input  [ 7:0]  m2_invalid_len1,
    input  [ 7:0]  m2_invalid_len2,
    input  [ 2:0]  m2invalid,


// 虚拟从机的rlast
    output         s0_vir_rlast,
    output [ 2:0]  s0_vir_rid,

    output         s1_vir_rlast,
    output [ 2:0]  s1_vir_rid,

    output         s2_vir_rlast,
    output [ 2:0]  s2_vir_rid,


// read_address_decoder提供 itemtable
    input   [3:0] m0_r_transactionid0,
    input   [3:0] m0_r_transactionid1,
    input   [3:0] m0_r_transactionid2,
    input   [2:0] m0_itemvalid,
    input   [2:0] m0_fkflag,

    input   [3:0] m1_r_transactionid0,
    input   [3:0] m1_r_transactionid1,
    input   [3:0] m1_r_transactionid2,
    input   [2:0] m1_itemvalid,
    input   [2:0] m1_fkflag,

    input   [3:0] m2_r_transactionid0,
    input   [3:0] m2_r_transactionid1,
    input   [3:0] m2_r_transactionid2,
    input   [2:0] m2_itemvalid,
    input   [2:0] m2_fkflag


);


    wire [ 3:0] s0_to_m0_axi_r_rid;
    wire [31:0] s0_to_m0_axi_r_rdata;
    wire [ 1:0] s0_to_m0_axi_r_rresp;
    wire        s0_to_m0_axi_r_rlast;
    wire        s0_to_m0_axi_r_valid;
    wire        s0_to_m0_axi_r_ready;

    wire [ 3:0] s0_to_m1_axi_r_rid;
    wire [31:0] s0_to_m1_axi_r_rdata;
    wire [ 1:0] s0_to_m1_axi_r_rresp;
    wire        s0_to_m1_axi_r_rlast;
    wire        s0_to_m1_axi_r_valid;
    wire        s0_to_m1_axi_r_ready;

    wire [ 3:0] s0_to_m2_axi_r_rid;
    wire [31:0] s0_to_m2_axi_r_rdata;
    wire [ 1:0] s0_to_m2_axi_r_rresp;
    wire        s0_to_m2_axi_r_rlast;
    wire        s0_to_m2_axi_r_valid;
    wire        s0_to_m2_axi_r_ready;






read_data_fifo slave0rdata(
    .clk                 (clk),
    .rst_n               (rst_n),

    .m_axi_r_rid           (m0_axi_r_rid  ),
    .m_axi_r_rdata         (m0_axi_r_rdata),
    .m_axi_r_rresp         (m0_axi_r_rresp),
    .m_axi_r_rlast         (m0_axi_r_rlast),
    .m_axi_r_valid         (m0_axi_r_valid),
    .m_axi_r_ready         (m0_axi_r_ready),

    .s_to_m0_axi_r_rid     (s0_to_m0_axi_r_rid  ),               
    .s_to_m0_axi_r_rdata   (s0_to_m0_axi_r_rdata),               
    .s_to_m0_axi_r_rresp   (s0_to_m0_axi_r_rresp),               
    .s_to_m0_axi_r_rlast   (s0_to_m0_axi_r_rlast),               
    .s_to_m0_axi_r_valid   (s0_to_m0_axi_r_valid),               
    .s_to_m0_axi_r_ready   (s0_to_m0_axi_r_ready),               

    .s_to_m1_axi_r_rid     (s0_to_m1_axi_r_rid),  
    .s_to_m1_axi_r_rdata   (s0_to_m1_axi_r_rdata),
    .s_to_m1_axi_r_rresp   (s0_to_m1_axi_r_rresp),
    .s_to_m1_axi_r_rlast   (s0_to_m1_axi_r_rlast),
    .s_to_m1_axi_r_valid   (s0_to_m1_axi_r_valid),
    .s_to_m1_axi_r_ready   (s0_to_m1_axi_r_ready),

    .s_to_m2_axi_r_rid     (s0_to_m2_axi_r_rid),  
    .s_to_m2_axi_r_rdata   (s0_to_m2_axi_r_rdata),
    .s_to_m2_axi_r_rresp   (s0_to_m2_axi_r_rresp),
    .s_to_m2_axi_r_rlast   (s0_to_m2_axi_r_rlast),
    .s_to_m2_axi_r_valid   (s0_to_m2_axi_r_valid),
    .s_to_m2_axi_r_ready   (s0_to_m2_axi_r_ready)

    );


    wire [ 3:0] s1_to_m0_axi_r_rid;
    wire [31:0] s1_to_m0_axi_r_rdata;
    wire [ 1:0] s1_to_m0_axi_r_rresp;
    wire        s1_to_m0_axi_r_rlast;
    wire        s1_to_m0_axi_r_valid;
    wire        s1_to_m0_axi_r_ready;

    wire [ 3:0] s1_to_m1_axi_r_rid;
    wire [31:0] s1_to_m1_axi_r_rdata;
    wire [ 1:0] s1_to_m1_axi_r_rresp;
    wire        s1_to_m1_axi_r_rlast;
    wire        s1_to_m1_axi_r_valid;
    wire        s1_to_m1_axi_r_ready;

    wire [ 3:0] s1_to_m2_axi_r_rid;
    wire [31:0] s1_to_m2_axi_r_rdata;
    wire [ 1:0] s1_to_m2_axi_r_rresp;
    wire        s1_to_m2_axi_r_rlast;
    wire        s1_to_m2_axi_r_valid;
    wire        s1_to_m2_axi_r_ready;






read_data_fifo slave1rdata(
    .clk                 (clk),
    .rst_n               (rst_n),

    .m_axi_r_rid           (m1_axi_r_rid  ),
    .m_axi_r_rdata         (m1_axi_r_rdata),
    .m_axi_r_rresp         (m1_axi_r_rresp),
    .m_axi_r_rlast         (m1_axi_r_rlast),
    .m_axi_r_valid         (m1_axi_r_valid),
    .m_axi_r_ready         (m1_axi_r_ready),

    .s_to_m0_axi_r_rid     (s1_to_m0_axi_r_rid),               
    .s_to_m0_axi_r_rdata   (s1_to_m0_axi_r_rdata),               
    .s_to_m0_axi_r_rresp   (s1_to_m0_axi_r_rresp),               
    .s_to_m0_axi_r_rlast   (s1_to_m0_axi_r_rlast),               
    .s_to_m0_axi_r_valid   (s1_to_m0_axi_r_valid),               
    .s_to_m0_axi_r_ready   (s1_to_m0_axi_r_ready),               

    .s_to_m1_axi_r_rid     (s1_to_m1_axi_r_rid),  
    .s_to_m1_axi_r_rdata   (s1_to_m1_axi_r_rdata),
    .s_to_m1_axi_r_rresp   (s1_to_m1_axi_r_rresp),
    .s_to_m1_axi_r_rlast   (s1_to_m1_axi_r_rlast),
    .s_to_m1_axi_r_valid   (s1_to_m1_axi_r_valid),
    .s_to_m1_axi_r_ready   (s1_to_m1_axi_r_ready),

    .s_to_m2_axi_r_rid     (s1_to_m2_axi_r_rid),  
    .s_to_m2_axi_r_rdata   (s1_to_m2_axi_r_rdata),
    .s_to_m2_axi_r_rresp   (s1_to_m2_axi_r_rresp),
    .s_to_m2_axi_r_rlast   (s1_to_m2_axi_r_rlast),
    .s_to_m2_axi_r_valid   (s1_to_m2_axi_r_valid),
    .s_to_m2_axi_r_ready   (s1_to_m2_axi_r_ready)

    );


    wire [ 3:0] s2_to_m0_axi_r_rid;
    wire [31:0] s2_to_m0_axi_r_rdata;
    wire [ 1:0] s2_to_m0_axi_r_rresp;
    wire        s2_to_m0_axi_r_rlast;
    wire        s2_to_m0_axi_r_valid;
    wire        s2_to_m0_axi_r_ready;

    wire [ 3:0] s2_to_m1_axi_r_rid;
    wire [31:0] s2_to_m1_axi_r_rdata;
    wire [ 1:0] s2_to_m1_axi_r_rresp;
    wire        s2_to_m1_axi_r_rlast;
    wire        s2_to_m1_axi_r_valid;
    wire        s2_to_m1_axi_r_ready;

    wire [ 3:0] s2_to_m2_axi_r_rid;
    wire [31:0] s2_to_m2_axi_r_rdata;
    wire [ 1:0] s2_to_m2_axi_r_rresp;
    wire        s2_to_m2_axi_r_rlast;
    wire        s2_to_m2_axi_r_valid;
    wire        s2_to_m2_axi_r_ready;






read_data_fifo slave2rdata(
    .clk                 (clk),
    .rst_n               (rst_n),

    .m_axi_r_rid           (m2_axi_r_rid  ),
    .m_axi_r_rdata         (m2_axi_r_rdata),
    .m_axi_r_rresp         (m2_axi_r_rresp),
    .m_axi_r_rlast         (m2_axi_r_rlast),
    .m_axi_r_valid         (m2_axi_r_valid),
    .m_axi_r_ready         (m2_axi_r_ready),

    .s_to_m0_axi_r_rid     (s2_to_m0_axi_r_rid),               
    .s_to_m0_axi_r_rdata   (s2_to_m0_axi_r_rdata),               
    .s_to_m0_axi_r_rresp   (s2_to_m0_axi_r_rresp),               
    .s_to_m0_axi_r_rlast   (s2_to_m0_axi_r_rlast),               
    .s_to_m0_axi_r_valid   (s2_to_m0_axi_r_valid),               
    .s_to_m0_axi_r_ready   (s2_to_m0_axi_r_ready),               

    .s_to_m1_axi_r_rid     (s2_to_m1_axi_r_rid),  
    .s_to_m1_axi_r_rdata   (s2_to_m1_axi_r_rdata),
    .s_to_m1_axi_r_rresp   (s2_to_m1_axi_r_rresp),
    .s_to_m1_axi_r_rlast   (s2_to_m1_axi_r_rlast),
    .s_to_m1_axi_r_valid   (s2_to_m1_axi_r_valid),
    .s_to_m1_axi_r_ready   (s2_to_m1_axi_r_ready),

    .s_to_m2_axi_r_rid     (s2_to_m2_axi_r_rid),  
    .s_to_m2_axi_r_rdata   (s2_to_m2_axi_r_rdata),
    .s_to_m2_axi_r_rresp   (s2_to_m2_axi_r_rresp),
    .s_to_m2_axi_r_rlast   (s2_to_m2_axi_r_rlast),
    .s_to_m2_axi_r_valid   (s2_to_m2_axi_r_valid),
    .s_to_m2_axi_r_ready   (s2_to_m2_axi_r_ready)

    );




read_data_arbiter m0_rdarb(
    .clk                 (clk),
    .rst_n               (rst_n),


    .s0_to_m_axi_r_rid       (s0_to_m0_axi_r_rid),  
    .s0_to_m_axi_r_rdata     (s0_to_m0_axi_r_rdata),
    .s0_to_m_axi_r_rresp     (s0_to_m0_axi_r_rresp),
    .s0_to_m_axi_r_rlast     (s0_to_m0_axi_r_rlast),
    .s0_to_m_axi_r_valid     (s0_to_m0_axi_r_valid),
    .s0_to_m_axi_r_ready     (s0_to_m0_axi_r_ready),

    .s1_to_m_axi_r_rid       (s1_to_m0_axi_r_rid),  
    .s1_to_m_axi_r_rdata     (s1_to_m0_axi_r_rdata),
    .s1_to_m_axi_r_rresp     (s1_to_m0_axi_r_rresp),
    .s1_to_m_axi_r_rlast     (s1_to_m0_axi_r_rlast),
    .s1_to_m_axi_r_valid     (s1_to_m0_axi_r_valid),
    .s1_to_m_axi_r_ready     (s1_to_m0_axi_r_ready),

    .s2_to_m_axi_r_rid       (s2_to_m0_axi_r_rid),  
    .s2_to_m_axi_r_rdata     (s2_to_m0_axi_r_rdata),
    .s2_to_m_axi_r_rresp     (s2_to_m0_axi_r_rresp),
    .s2_to_m_axi_r_rlast     (s2_to_m0_axi_r_rlast),
    .s2_to_m_axi_r_valid     (s2_to_m0_axi_r_valid),
    .s2_to_m_axi_r_ready     (s2_to_m0_axi_r_ready),

    .s_axi_r_rid        (s0_axi_r_rid),               
    .s_axi_r_rdata      (s0_axi_r_rdata),               
    .s_axi_r_rresp      (s0_axi_r_rresp),               
    .s_axi_r_rlast      (s0_axi_r_rlast),               
    .s_axi_r_valid      (s0_axi_r_valid),               
    .s_axi_r_ready      (s0_axi_r_ready),               
    .s_axi_fifo_r_rlast (s0_axi_fifo_r_rlast),


    .m_transaction_invalidid0(m0_transaction_invalidid0),                           
    .m_transaction_invalidid1(m0_transaction_invalidid1),                           
    .m_transaction_invalidid2(m0_transaction_invalidid2),                           
    .m_invalid_len0          (m0_invalid_len0),               
    .m_invalid_len1          (m0_invalid_len1),               
    .m_invalid_len2          (m0_invalid_len2),               
    .minvalid                (m0invalid),                                      

    .s_vir_rlast             (s0_vir_rlast),                            
    .s_vir_rid               (s0_vir_rid),    

    .r_transactionid0        (m0_r_transactionid0),                       
    .r_transactionid1        (m0_r_transactionid1),                       
    .r_transactionid2        (m0_r_transactionid2),                       
    .itemvalid               (m0_itemvalid),               
    .fkflag                  (m0_fkflag)

    );

read_data_arbiter m1_rdarb(
    .clk                 (clk),
    .rst_n               (rst_n),


    .s0_to_m_axi_r_rid      (s0_to_m1_axi_r_rid),  
    .s0_to_m_axi_r_rdata    (s0_to_m1_axi_r_rdata),
    .s0_to_m_axi_r_rresp    (s0_to_m1_axi_r_rresp),
    .s0_to_m_axi_r_rlast    (s0_to_m1_axi_r_rlast),
    .s0_to_m_axi_r_valid    (s0_to_m1_axi_r_valid),
    .s0_to_m_axi_r_ready    (s0_to_m1_axi_r_ready),

    .s1_to_m_axi_r_rid      (s1_to_m1_axi_r_rid),  
    .s1_to_m_axi_r_rdata    (s1_to_m1_axi_r_rdata),
    .s1_to_m_axi_r_rresp    (s1_to_m1_axi_r_rresp),
    .s1_to_m_axi_r_rlast    (s1_to_m1_axi_r_rlast),
    .s1_to_m_axi_r_valid    (s1_to_m1_axi_r_valid),
    .s1_to_m_axi_r_ready    (s1_to_m1_axi_r_ready),

    .s2_to_m_axi_r_rid      (s2_to_m1_axi_r_rid),  
    .s2_to_m_axi_r_rdata    (s2_to_m1_axi_r_rdata),
    .s2_to_m_axi_r_rresp    (s2_to_m1_axi_r_rresp),
    .s2_to_m_axi_r_rlast    (s2_to_m1_axi_r_rlast),
    .s2_to_m_axi_r_valid    (s2_to_m1_axi_r_valid),
    .s2_to_m_axi_r_ready    (s2_to_m1_axi_r_ready),

    .s_axi_r_rid        (s1_axi_r_rid),               
    .s_axi_r_rdata      (s1_axi_r_rdata),               
    .s_axi_r_rresp      (s1_axi_r_rresp),               
    .s_axi_r_rlast      (s1_axi_r_rlast),               
    .s_axi_r_valid      (s1_axi_r_valid),               
    .s_axi_r_ready      (s1_axi_r_ready),               
    .s_axi_fifo_r_rlast (s1_axi_fifo_r_rlast),


    .m_transaction_invalidid0(m1_transaction_invalidid0),                           
    .m_transaction_invalidid1(m1_transaction_invalidid1),                           
    .m_transaction_invalidid2(m1_transaction_invalidid2),                           
    .m_invalid_len0          (m1_invalid_len0),               
    .m_invalid_len1          (m1_invalid_len1),               
    .m_invalid_len2          (m1_invalid_len2),               
    .minvalid                (m1invalid),                                      

    .s_vir_rlast             (s1_vir_rlast),                            
    .s_vir_rid               (s1_vir_rid),    

    .r_transactionid0        (m1_r_transactionid0),                       
    .r_transactionid1        (m1_r_transactionid1),                       
    .r_transactionid2        (m1_r_transactionid2),                       
    .itemvalid               (m1_itemvalid),               
    .fkflag                  (m1_fkflag)

    );


read_data_arbiter m2_rdarb(
    .clk                 (clk),
    .rst_n               (rst_n),


    .s0_to_m_axi_r_rid     (s0_to_m2_axi_r_rid),  
    .s0_to_m_axi_r_rdata   (s0_to_m2_axi_r_rdata),
    .s0_to_m_axi_r_rresp   (s0_to_m2_axi_r_rresp),
    .s0_to_m_axi_r_rlast   (s0_to_m2_axi_r_rlast),
    .s0_to_m_axi_r_valid   (s0_to_m2_axi_r_valid),
    .s0_to_m_axi_r_ready   (s0_to_m2_axi_r_ready),

    .s1_to_m_axi_r_rid     (s1_to_m2_axi_r_rid),  
    .s1_to_m_axi_r_rdata   (s1_to_m2_axi_r_rdata),
    .s1_to_m_axi_r_rresp   (s1_to_m2_axi_r_rresp),
    .s1_to_m_axi_r_rlast   (s1_to_m2_axi_r_rlast),
    .s1_to_m_axi_r_valid   (s1_to_m2_axi_r_valid),
    .s1_to_m_axi_r_ready   (s1_to_m2_axi_r_ready),

    .s2_to_m_axi_r_rid     (s2_to_m2_axi_r_rid),  
    .s2_to_m_axi_r_rdata   (s2_to_m2_axi_r_rdata),
    .s2_to_m_axi_r_rresp   (s2_to_m2_axi_r_rresp),
    .s2_to_m_axi_r_rlast   (s2_to_m2_axi_r_rlast),
    .s2_to_m_axi_r_valid   (s2_to_m2_axi_r_valid),
    .s2_to_m_axi_r_ready   (s2_to_m2_axi_r_ready),


    .s_axi_r_rid        (s2_axi_r_rid),               
    .s_axi_r_rdata      (s2_axi_r_rdata),               
    .s_axi_r_rresp      (s2_axi_r_rresp),               
    .s_axi_r_rlast      (s2_axi_r_rlast),               
    .s_axi_r_valid      (s2_axi_r_valid),               
    .s_axi_r_ready      (s2_axi_r_ready),               
    .s_axi_fifo_r_rlast (s2_axi_fifo_r_rlast),


    .m_transaction_invalidid0(m2_transaction_invalidid0),                           
    .m_transaction_invalidid1(m2_transaction_invalidid1),                           
    .m_transaction_invalidid2(m2_transaction_invalidid2),                           
    .m_invalid_len0          (m2_invalid_len0),               
    .m_invalid_len1          (m2_invalid_len1),               
    .m_invalid_len2          (m2_invalid_len2),               
    .minvalid                (m2invalid),                                      

    .s_vir_rlast             (s2_vir_rlast),                            
    .s_vir_rid               (s2_vir_rid),    

    .r_transactionid0        (m2_r_transactionid0),                       
    .r_transactionid1        (m2_r_transactionid1),                       
    .r_transactionid2        (m2_r_transactionid2),                       
    .itemvalid               (m2_itemvalid),               
    .fkflag                  (m2_fkflag)

    );






endmodule