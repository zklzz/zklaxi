


module write_address(

    input   clk,
    input   rst_n,


    input  [13:0] s0_axi_aw_addr,
    input  [7:0]  s0_axi_aw_awlen,
    input  [2:0]  s0_axi_aw_awsize,
    input  [1:0]  s0_axi_aw_awburst,
    input  [3:0]  s0_axi_aw_awid,
    input         s0_axi_aw_valid,
    output        s0_axi_aw_ready,

    input   [3:0] s0_axi_b_bid,
    input         s0_axi_b_valid,
    input         s0_axi_b_ready,

    input  [13:0] s1_axi_aw_addr,
    input  [7:0]  s1_axi_aw_awlen,
    input  [2:0]  s1_axi_aw_awsize,
    input  [1:0]  s1_axi_aw_awburst,
    input  [3:0]  s1_axi_aw_awid,
    input         s1_axi_aw_valid,
    output        s1_axi_aw_ready,

    input   [3:0] s1_axi_b_bid,
    input         s1_axi_b_valid,
    input         s1_axi_b_ready,

    input  [13:0] s2_axi_aw_addr,
    input  [7:0]  s2_axi_aw_awlen,
    input  [2:0]  s2_axi_aw_awsize,
    input  [1:0]  s2_axi_aw_awburst,
    input  [3:0]  s2_axi_aw_awid,
    input         s2_axi_aw_valid,
    output        s2_axi_aw_ready,

    input   [3:0] s2_axi_b_bid,
    input         s2_axi_b_valid,
    input         s2_axi_b_ready,

    input   [2:0] region_write_table_m0,
    input   [2:0] region_write_table_m1,
    input   [2:0] region_write_table_m2,

//  清空fifo后的写返回仲裁成功正确握手 write_response
    input            s0_axi_invalid_fire,
    input            s0_axi_invalid_wid,
    input            s1_axi_invalid_fire,
    input            s1_axi_invalid_wid,
    input            s2_axi_invalid_fire,
    input            s2_axi_invalid_wid,

// 未合并的写返回，write_response中的b通道fifo提供 主机0
    input   [3:0] s0_axi_fifo_b_bid,
    input         s0_axi_fifo_b_valid,
    input         s0_axi_fifo_b_bresp, 
    input         s0_axi_fifo_b_ready,


// 未合并的写返回，write_response中的b通道fifo提供 主机1
    input   [3:0] s1_axi_fifo_b_bid,
    input         s1_axi_fifo_b_valid,
    input         s1_axi_fifo_b_bresp, 
    input         s1_axi_fifo_b_ready,

// 未合并的写返回，write_response中的b通道fifo提供 主机2
    input   [3:0] s2_axi_fifo_b_bid,
    input         s2_axi_fifo_b_valid,
    input         s2_axi_fifo_b_bresp, 
    input         s2_axi_fifo_b_ready,

// 由write_data_arbiter提供，与连接至从机的写数据通道相同
    input         m0_axi_w_wlast,
    input  [5:0]  m0_axi_w_wid,
    input         m0_axi_w_ready,
    input         m0_axi_w_valid,

    input         m1_axi_w_wlast,
    input  [5:0]  m1_axi_w_wid,
    input         m1_axi_w_ready,
    input         m1_axi_w_valid,

    input         m2_axi_w_wlast,
    input  [5:0]  m2_axi_w_wid,
    input         m2_axi_w_ready,
    input         m2_axi_w_valid,

    output [13:0] m0_axi_aw_addr,
    output [7:0]  m0_axi_aw_awlen,
    output [2:0]  m0_axi_aw_awsize,
    output [1:0]  m0_axi_aw_awburst,
    output [5:0]  m0_axi_aw_awid,
    output        m0_axi_aw_valid,
    input         m0_axi_aw_ready,

    output [13:0] m1_axi_aw_addr,
    output [7:0]  m1_axi_aw_awlen,
    output [2:0]  m1_axi_aw_awsize,
    output [1:0]  m1_axi_aw_awburst,
    output [5:0]  m1_axi_aw_awid,
    output        m1_axi_aw_valid,
    input         m1_axi_aw_ready,

    output [13:0] m2_axi_aw_addr,
    output [7:0]  m2_axi_aw_awlen,
    output [2:0]  m2_axi_aw_awsize,
    output [1:0]  m2_axi_aw_awburst,
    output [5:0]  m2_axi_aw_awid,
    output        m2_axi_aw_valid,
    input         m2_axi_aw_ready,

// 提供给write_data_arbiter 从机0
    output  [5:0] s0_validid0,
    output  [5:0] s0_validid1,
    output  [5:0] s0_validid2,
    output  [2:0] s0_valid,
    output  [7:0] s0_wlen0,
    output  [7:0] s0_wlen1,
    output  [7:0] s0_wlen2,

// 提供给write_data_arbiter 从机1
    output  [5:0] s1_validid0,
    output  [5:0] s1_validid1,
    output  [5:0] s1_validid2,
    output  [2:0] s1_valid,
    output  [7:0] s1_wlen0,
    output  [7:0] s1_wlen1,
    output  [7:0] s1_wlen2,

// 提供给write_data_arbiter 从机2
    output  [5:0] s2_validid0,
    output  [5:0] s2_validid1,
    output  [5:0] s2_validid2,
    output  [2:0] s2_valid,
    output  [7:0] s2_wlen0,
    output  [7:0] s2_wlen1,
    output  [7:0] s2_wlen2,

//连接至 write_response 主机0
    output   [3:0] m0_w_transactionid0,
    output   [3:0] m0_w_transactionid1,
    output   [3:0] m0_w_transactionid2,
    output   [2:0] m0_item_valid,
    output   [2:0] m0_fkflag,

//连接至 write_response 主机1
    output   [3:0] m1_w_transactionid0,
    output   [3:0] m1_w_transactionid1,
    output   [3:0] m1_w_transactionid2,
    output   [2:0] m1_item_valid,
    output   [2:0] m1_fkflag,

//连接至 write_response 主机02
    output   [3:0] m2_w_transactionid0,
    output   [3:0] m2_w_transactionid1,
    output   [3:0] m2_w_transactionid2,
    output   [2:0] m2_item_valid,
    output   [2:0] m2_fkflag,


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



);


// 主机0
    wire  [13:0] m0_decoder_axi_aw_addr;
    wire  [7:0]  m0_decoder_axi_aw_awlen;
    wire  [2:0]  m0_decoder_axi_aw_awsize;
    wire  [1:0]  m0_decoder_axi_aw_awburst;
    wire  [5:0]  m0_decoder_axi_aw_awid;
    wire         m0_decoder_axi_aw_valid;
    wire         m0_decoder_axi_aw_ready;


    write_address_decoder m0_decoder(
    .clk                 (clk),
    .rst_n               (rst_n),

    .s_axi_index         (2'b00), 
    .s_axi_aw_addr     (s0_axi_aw_addr),
    .s_axi_aw_awlen    (s0_axi_aw_awlen),
    .s_axi_aw_awsize   (s0_axi_aw_awsize),
    .s_axi_aw_awburst  (s0_axi_aw_awburst),
    .s_axi_aw_awid     (s0_axi_aw_awid),
    .s_axi_aw_valid    (s0_axi_aw_valid),
    .s_axi_aw_ready    (s0_axi_aw_ready),


    .m_axi_aw_addr     (m0_decoder_axi_aw_addr),
    .m_axi_aw_awlen    (m0_decoder_axi_aw_awlen),
    .m_axi_aw_awsize   (m0_decoder_axi_aw_awsize),
    .m_axi_aw_awburst  (m0_decoder_axi_aw_awburst),
    .m_axi_aw_awid     (m0_decoder_axi_aw_awid),
    .m_axi_aw_valid    (m0_decoder_axi_aw_valid),
    .m_axi_aw_ready    (m0_decoder_axi_aw_ready),

    .s_axi_fifo_b_bid   (s0_axi_fifo_b_bid),
    .s_axi_fifo_b_valid (s0_axi_fifo_b_valid),
    .s_axi_fifo_b_bresp (s0_axi_fifo_b_bresp),
    .s_axi_fifo_b_ready (s0_axi_fifo_b_ready),

    //    .s_axi_b_bid         (s0_axi_b_bid),
    .s_axi_b_valid       (s0_axi_b_valid),
    .s_axi_b_ready       (s0_axi_b_ready),
    
    .w_transactionid0    (m0_w_transactionid0),
    .w_transactionid1    (m0_w_transactionid1),      
    .w_transactionid2    (m0_w_transactionid2),   
    .item_valid          (m0_item_valid), 
    .fkflag              (m0_fkflag)




    );






// 主机1

    wire  [13:0] m1_decoder_axi_aw_addr;
    wire  [7:0]  m1_decoder_axi_aw_awlen;
    wire  [2:0]  m1_decoder_axi_aw_awsize;
    wire  [1:0]  m1_decoder_axi_aw_awburst;
    wire  [5:0]  m1_decoder_axi_aw_awid;
    wire         m1_decoder_axi_aw_valid;
    wire         m1_decoder_axi_aw_ready;


    write_address_decoder m1_decoder(
    .clk                 (clk),
    .rst_n               (rst_n),

    .s_axi_index         (2'b01), 
    .s_axi_aw_addr     (s1_axi_aw_addr),
    .s_axi_aw_awlen    (s1_axi_aw_awlen),
    .s_axi_aw_awsize   (s1_axi_aw_awsize),
    .s_axi_aw_awburst  (s1_axi_aw_awburst),
    .s_axi_aw_awid     (s1_axi_aw_awid),
    .s_axi_aw_valid    (s1_axi_aw_valid),
    .s_axi_aw_ready    (s1_axi_aw_ready),


    .m_axi_aw_addr     (m1_decoder_axi_aw_addr),
    .m_axi_aw_awlen    (m1_decoder_axi_aw_awlen),
    .m_axi_aw_awsize   (m1_decoder_axi_aw_awsize),
    .m_axi_aw_awburst  (m1_decoder_axi_aw_awburst),
    .m_axi_aw_awid     (m1_decoder_axi_aw_awid),
    .m_axi_aw_valid    (m1_decoder_axi_aw_valid),
    .m_axi_aw_ready    (m1_decoder_axi_aw_ready),

    .s_axi_fifo_b_bid   (s1_axi_fifo_b_bid),
    .s_axi_fifo_b_valid (s1_axi_fifo_b_valid),
    .s_axi_fifo_b_bresp (s1_axi_fifo_b_bresp),
    .s_axi_fifo_b_ready (s1_axi_fifo_b_ready),


    //.s_axi_b_bid         (s1_axi_b_bid),
    .s_axi_b_valid       (s1_axi_b_valid),
    .s_axi_b_ready       (s1_axi_b_ready),

    .w_transactionid0    (m1_w_transactionid0),
    .w_transactionid1    (m1_w_transactionid1),      
    .w_transactionid2    (m1_w_transactionid2),   
    .item_valid          (m1_item_valid), 
    .fkflag              (m1_fkflag)
    );


//主机2
    wire  [13:0] m2_decoder_axi_aw_addr;
    wire  [7:0]  m2_decoder_axi_aw_awlen;
    wire  [2:0]  m2_decoder_axi_aw_awsize;
    wire  [1:0]  m2_decoder_axi_aw_awburst;
    wire  [5:0]  m2_decoder_axi_aw_awid;
    wire         m2_decoder_axi_aw_valid;
    wire         m2_decoder_axi_aw_ready;

    write_address_decoder m2_decoder(
    .clk                 (clk),
    .rst_n               (rst_n),

    .s_axi_index         (2'b10), 
    .s_axi_aw_addr     (s2_axi_aw_addr),
    .s_axi_aw_awlen    (s2_axi_aw_awlen),
    .s_axi_aw_awsize   (s2_axi_aw_awsize),
    .s_axi_aw_awburst  (s2_axi_aw_awburst),
    .s_axi_aw_awid     (s2_axi_aw_awid),
    .s_axi_aw_valid    (s2_axi_aw_valid),
    .s_axi_aw_ready    (s2_axi_aw_ready),


    .m_axi_aw_addr     (m2_decoder_axi_aw_addr),
    .m_axi_aw_awlen    (m2_decoder_axi_aw_awlen),
    .m_axi_aw_awsize   (m2_decoder_axi_aw_awsize),
    .m_axi_aw_awburst  (m2_decoder_axi_aw_awburst),
    .m_axi_aw_awid     (m2_decoder_axi_aw_awid),
    .m_axi_aw_valid    (m2_decoder_axi_aw_valid),
    .m_axi_aw_ready    (m2_decoder_axi_aw_ready),

    .s_axi_fifo_b_bid   (s2_axi_fifo_b_bid),
    .s_axi_fifo_b_valid (s2_axi_fifo_b_valid),
    .s_axi_fifo_b_bresp (s2_axi_fifo_b_bresp),
    .s_axi_fifo_b_ready (s2_axi_fifo_b_ready),

    //.s_axi_b_bid         (s2_axi_b_bid),
    .s_axi_b_valid       (s2_axi_b_valid),
    .s_axi_b_ready       (s2_axi_b_ready),

    .w_transactionid0    (m2_w_transactionid0),
    .w_transactionid1    (m2_w_transactionid1),      
    .w_transactionid2    (m2_w_transactionid2),   
    .item_valid          (m2_item_valid), 
    .fkflag              (m2_fkflag)
    );



    wire  [13:0] m0_axi_arbiter_awaddr;
    wire  [7:0]  m0_axi_arbiter_awlen;
    wire  [2:0]  m0_axi_arbiter_awsize;
    wire  [1:0]  m0_axi_arbiter_awburst;
    wire  [5:0]  m0_axi_arbiter_awid;
    wire         m0_axi_arbiter_valid;
    wire         m0_axi_arbiter_ready;

    wire  [13:0] m1_axi_arbiter_awaddr;
    wire  [7:0]  m1_axi_arbiter_awlen;
    wire  [2:0]  m1_axi_arbiter_awsize;
    wire  [1:0]  m1_axi_arbiter_awburst;
    wire  [5:0]  m1_axi_arbiter_awid;
    wire         m1_axi_arbiter_valid;
    wire         m1_axi_arbiter_ready;

    wire  [13:0] m2_axi_arbiter_awaddr;
    wire  [7:0]  m2_axi_arbiter_awlen;
    wire  [2:0]  m2_axi_arbiter_awsize;
    wire  [1:0]  m2_axi_arbiter_awburst;
    wire  [5:0]  m2_axi_arbiter_awid;
    wire         m2_axi_arbiter_valid;
    wire         m2_axi_arbiter_ready;

    write_address_arbiter3  arbiter(
    .clk                 (clk),
    .rst_n               (rst_n),

    .aw_decoder_awaddr_s0      (m0_decoder_axi_aw_addr),        
    .aw_decoder_awlen_s0       (m0_decoder_axi_aw_awlen),    
    .aw_decoder_awsize_s0      (m0_decoder_axi_aw_awsize),        
    .aw_decoder_awburst_s0     (m0_decoder_axi_aw_awburst),        
    .aw_decoder_awid_s0        (m0_decoder_axi_aw_awid),    
    .aw_decoder_valid_s0       (m0_decoder_axi_aw_valid),    
    .aw_decoder_ready_s0       (m0_decoder_axi_aw_ready),    

    .aw_decoder_awaddr_s1      (m1_decoder_axi_aw_addr),            
    .aw_decoder_awlen_s1       (m1_decoder_axi_aw_awlen),    
    .aw_decoder_awsize_s1      (m1_decoder_axi_aw_awsize),    
    .aw_decoder_awburst_s1     (m1_decoder_axi_aw_awburst),    
    .aw_decoder_awid_s1        (m1_decoder_axi_aw_awid),
    .aw_decoder_valid_s1       (m1_decoder_axi_aw_valid),    
    .aw_decoder_ready_s1       (m1_decoder_axi_aw_ready),    

    .aw_decoder_awaddr_s2      (m2_decoder_axi_aw_addr),     
    .aw_decoder_awlen_s2       (m2_decoder_axi_aw_awlen),     
    .aw_decoder_awsize_s2      (m2_decoder_axi_aw_awsize),     
    .aw_decoder_awburst_s2     (m2_decoder_axi_aw_awburst),     
    .aw_decoder_awid_s2        (m2_decoder_axi_aw_awid), 
    .aw_decoder_valid_s2       (m2_decoder_axi_aw_valid),     
    .aw_decoder_ready_s2       (m2_decoder_axi_aw_ready),     

    .m0_axi_arbiter_awaddr    (m0_axi_arbiter_awaddr),        
    .m0_axi_arbiter_awlen     (m0_axi_arbiter_awlen),        
    .m0_axi_arbiter_awsize    (m0_axi_arbiter_awsize),        
    .m0_axi_arbiter_awburst   (m0_axi_arbiter_awburst),            
    .m0_axi_arbiter_awid      (m0_axi_arbiter_awid),        
    .m0_axi_arbiter_valid     (m0_axi_arbiter_valid),        
    .m0_axi_arbiter_ready     (m0_axi_arbiter_ready),        

    .m1_axi_arbiter_awaddr    (m1_axi_arbiter_awaddr),    
    .m1_axi_arbiter_awlen     (m1_axi_arbiter_awlen),    
    .m1_axi_arbiter_awsize    (m1_axi_arbiter_awsize),    
    .m1_axi_arbiter_awburst   (m1_axi_arbiter_awburst),        
    .m1_axi_arbiter_awid      (m1_axi_arbiter_awid),    
    .m1_axi_arbiter_valid     (m1_axi_arbiter_valid),    
    .m1_axi_arbiter_ready     (m1_axi_arbiter_ready),    


    .m2_axi_arbiter_awaddr    (m2_axi_arbiter_awaddr),
    .m2_axi_arbiter_awlen     (m2_axi_arbiter_awlen),
    .m2_axi_arbiter_awsize    (m2_axi_arbiter_awsize),
    .m2_axi_arbiter_awburst   (m2_axi_arbiter_awburst),  
    .m2_axi_arbiter_awid      (m2_axi_arbiter_awid),
    .m2_axi_arbiter_valid     (m2_axi_arbiter_valid),
    .m2_axi_arbiter_ready     (m2_axi_arbiter_ready),

    .region_write_table_m0    (region_write_table_m0),
    .region_write_table_m1    (region_write_table_m1),
    .region_write_table_m2    (region_write_table_m2),

    
    .s0_axi_invalid_fire      ( s0_axi_invalid_fire) ,        
    .s0_axi_invalid_wid       ( s0_axi_invalid_wid)  ,      
    .s1_axi_invalid_fire      ( s1_axi_invalid_fire) ,        
    .s1_axi_invalid_wid       ( s1_axi_invalid_wid)  ,      
    .s2_axi_invalid_fire      ( s2_axi_invalid_fire) ,        
    .s2_axi_invalid_wid       ( s2_axi_invalid_wid)  ,   

    .m0_transaction_invalidid0 (m0_transaction_invalidid0),                       
    .m0_transaction_invalidid1 (m0_transaction_invalidid1),                       
    .m0_transaction_invalidid2 (m0_transaction_invalidid2),                       
    .m0invalid                 (m0invalid),       
    .m1_transaction_invalidid0 (m1_transaction_invalidid0),                       
    .m1_transaction_invalidid1 (m1_transaction_invalidid1),                       
    .m1_transaction_invalidid2 (m1_transaction_invalidid2),                       
    .m1invalid                 (m1invalid),       
    .m2_transaction_invalidid0 (m2_transaction_invalidid0),                       
    .m2_transaction_invalidid1 (m2_transaction_invalidid1),                       
    .m2_transaction_invalidid2 (m2_transaction_invalidid2),                       
    .m2invalid                 (m2invalid)          


             

);


//从机0
    write_address_log_table  # (
    .interve_mode(1)
    ) S0_logtable
    (

    .s_axi_arbiter_awaddr       (m0_axi_arbiter_awaddr), 
    .s_axi_arbiter_awlen        (m0_axi_arbiter_awlen),  
    .s_axi_arbiter_awsize       (m0_axi_arbiter_awsize), 
    .s_axi_arbiter_awburst      (m0_axi_arbiter_awburst),
    .s_axi_arbiter_awid         (m0_axi_arbiter_awid),   
    .s_axi_arbiter_valid        (m0_axi_arbiter_valid),  
    .s_axi_arbiter_ready        (m0_axi_arbiter_ready),  



    .m_axi_arbiter_awaddr       (m0_axi_aw_addr),     
    .m_axi_arbiter_awlen        (m0_axi_aw_awlen),     
    .m_axi_arbiter_awsize       (m0_axi_aw_awsize),     
    .m_axi_arbiter_awburst      (m0_axi_aw_awburst),     
    .m_axi_arbiter_awid         (m0_axi_aw_awid), 
    .m_axi_arbiter_valid        (m0_axi_aw_valid),     
    .m_axi_arbiter_ready        (m0_axi_aw_ready),     

    .m_axi_w_wlast              (m0_axi_w_wlast),
    .m_axi_w_wid                (m0_axi_w_wid),
    .m_axi_w_ready              (m0_axi_w_ready),
    .m_axi_w_valid              (m0_axi_w_valid),

    .s_validid0                 (s0_validid0),
    .s_validid1                 (s0_validid1),
    .s_validid2                 (s0_validid2),
    .s_valid                    (s0_valid),
    .s_wlen0                    (s0_wlen0),
    .s_wlen1                    (s0_wlen1),
    .s_wlen2                    (s0_wlen2)


);


// 从机1
    write_address_log_table  # (
    .interve_mode(1)
    ) S1_logtable
    (

    .s_axi_arbiter_awaddr       (m1_axi_arbiter_awaddr), 
    .s_axi_arbiter_awlen        (m1_axi_arbiter_awlen),  
    .s_axi_arbiter_awsize       (m1_axi_arbiter_awsize), 
    .s_axi_arbiter_awburst      (m1_axi_arbiter_awburst),
    .s_axi_arbiter_awid         (m1_axi_arbiter_awid),   
    .s_axi_arbiter_valid        (m1_axi_arbiter_valid),  
    .s_axi_arbiter_ready        (m1_axi_arbiter_ready),  



    .m_axi_arbiter_awaddr       (m1_axi_aw_addr),     
    .m_axi_arbiter_awlen        (m1_axi_aw_awlen),     
    .m_axi_arbiter_awsize       (m1_axi_aw_awsize),     
    .m_axi_arbiter_awburst      (m1_axi_aw_awburst),     
    .m_axi_arbiter_awid         (m1_axi_aw_awid), 
    .m_axi_arbiter_valid        (m1_axi_aw_valid),     
    .m_axi_arbiter_ready        (m1_axi_aw_ready),     

    .m_axi_w_wlast              (m1_axi_w_wlast),
    .m_axi_w_wid                (m1_axi_w_wid),
    .m_axi_w_ready              (m1_axi_w_ready),
    .m_axi_w_valid              (m1_axi_w_valid),

    .s_validid0                 (s1_validid0),
    .s_validid1                 (s1_validid1),
    .s_validid2                 (s1_validid2),
    .s_valid                    (s1_valid),
    .s_wlen0                    (s1_wlen0),
    .s_wlen1                    (s1_wlen1),
    .s_wlen2                    (s1_wlen2)



);

// 从机2
    write_address_log_table  # (
    .interve_mode(1)
    ) S2_logtable
    (

    .s_axi_arbiter_awaddr       (m2_axi_arbiter_awaddr), 
    .s_axi_arbiter_awlen        (m2_axi_arbiter_awlen),  
    .s_axi_arbiter_awsize       (m2_axi_arbiter_awsize), 
    .s_axi_arbiter_awburst      (m2_axi_arbiter_awburst),
    .s_axi_arbiter_awid         (m2_axi_arbiter_awid),   
    .s_axi_arbiter_valid        (m2_axi_arbiter_valid),  
    .s_axi_arbiter_ready        (m2_axi_arbiter_ready),  



    .m_axi_arbiter_awaddr       (m2_axi_aw_addr),     
    .m_axi_arbiter_awlen        (m2_axi_aw_awlen),     
    .m_axi_arbiter_awsize       (m2_axi_aw_awsize),     
    .m_axi_arbiter_awburst      (m2_axi_aw_awburst),     
    .m_axi_arbiter_awid         (m2_axi_aw_awid), 
    .m_axi_arbiter_valid        (m2_axi_aw_valid),     
    .m_axi_arbiter_ready        (m2_axi_aw_ready),     

    .m_axi_w_wlast              (m2_axi_w_wlast),
    .m_axi_w_wid                (m2_axi_w_wid),
    .m_axi_w_ready              (m2_axi_w_ready),
    .m_axi_w_valid              (m2_axi_w_valid),

    .s_validid0                 (s2_validid0),
    .s_validid1                 (s2_validid1),
    .s_validid2                 (s2_validid2),
    .s_valid                    (s2_valid),
    .s_wlen0                    (s2_wlen0),
    .s_wlen1                    (s2_wlen1),
    .s_wlen2                    (s2_wlen2)



);



endmodule