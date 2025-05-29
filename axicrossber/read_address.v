module read_address(
    input   clk,
    input   rst_n,


    input  [13:0] s0_axi_ar_addr,
    input  [7:0]  s0_axi_ar_arlen,
    input  [2:0]  s0_axi_ar_arsize,
    input  [1:0]  s0_axi_ar_arburst,
    input  [3:0]  s0_axi_ar_arid,
    input         s0_axi_ar_valid,
    output        s0_axi_ar_ready,

    input  [13:0] s1_axi_ar_addr,
    input  [7:0]  s1_axi_ar_arlen,
    input  [2:0]  s1_axi_ar_arsize,
    input  [1:0]  s1_axi_ar_arburst,
    input  [3:0]  s1_axi_ar_arid,
    input         s1_axi_ar_valid,
    output        s1_axi_ar_ready,


    input  [13:0] s2_axi_ar_addr,
    input  [7:0]  s2_axi_ar_arlen,
    input  [2:0]  s2_axi_ar_arsize,
    input  [1:0]  s2_axi_ar_arburst,
    input  [3:0]  s2_axi_ar_arid,
    input         s2_axi_ar_valid,
    output        s2_axi_ar_ready,


    output  [13:0] m0_axi_ar_addr,
    output  [7:0]  m0_axi_ar_arlen,
    output  [2:0]  m0_axi_ar_arsize,
    output  [1:0]  m0_axi_ar_arburst,
    output  [5:0]  m0_axi_ar_arid,
    output         m0_axi_ar_valid,
    input          m0_axi_ar_ready,

    output  [13:0] m1_axi_ar_addr,
    output  [7:0]  m1_axi_ar_arlen,
    output  [2:0]  m1_axi_ar_arsize,
    output  [1:0]  m1_axi_ar_arburst,
    output  [5:0]  m1_axi_ar_arid,
    output         m1_axi_ar_valid,
    input          m1_axi_ar_ready,

    output  [13:0] m2_axi_ar_addr,
    output  [7:0]  m2_axi_ar_arlen,
    output  [2:0]  m2_axi_ar_arsize,
    output  [1:0]  m2_axi_ar_arburst,
    output  [5:0]  m2_axi_ar_arid,
    output         m2_axi_ar_valid,
    input          m2_axi_ar_ready,

//  需要两个rlast
//  拆分事务的rlast
    input   [3:0] s0_axi_fifo_r_rid,
    input         s0_axi_fifo_r_rlast,
    input         s0_axi_fifo_r_valid, 
    input         s0_axi_fifo_r_ready,

    input   [3:0] s1_axi_fifo_r_rid,
    input         s1_axi_fifo_r_rlast,
    input         s1_axi_fifo_r_valid, 
    input         s1_axi_fifo_r_ready,

    input   [3:0] s2_axi_fifo_r_rid,
    input         s2_axi_fifo_r_rlast,
    input         s2_axi_fifo_r_valid, 
    input         s2_axi_fifo_r_ready,

// 合并之后的rlast
    input         s0_axi_r_valid,
    input         s0_axi_r_ready,
    input         s0_axi_r_rlast,

    input         s1_axi_r_valid,
    input         s1_axi_r_ready,
    input         s1_axi_r_rlast,

    input         s2_axi_r_valid,
    input         s2_axi_r_ready,
    input         s2_axi_r_rlast,


//连接至 read_data_arbiter
    output   [3:0] m0_r_transactionid0,
    output   [3:0] m0_r_transactionid1,
    output   [3:0] m0_r_transactionid2,
    output   [2:0] m0_itemvalid,
    output   [2:0] m0_fkflag,

    output   [3:0] m1_r_transactionid0,
    output   [3:0] m1_r_transactionid1,
    output   [3:0] m1_r_transactionid2,
    output   [2:0] m1_itemvalid,
    output   [2:0] m1_fkflag,

    output   [3:0] m2_r_transactionid0,
    output   [3:0] m2_r_transactionid1,
    output   [3:0] m2_r_transactionid2,
    output   [2:0] m2_itemvalid,
    output   [2:0] m2_fkflag,

//主机对从机访问权限
    input   [2:0] region_read_table_m0,
    input   [2:0] region_read_table_m1,
    input   [2:0] region_read_table_m2,

// 虚拟从机的读rlast
    input         s0_vir_rlast,
    input   [2:0] s0_vir_rid,

    input         s1_vir_rlast,
    input   [2:0] s1_vir_rid,

    input         s2_vir_rlast,
    input   [2:0] s2_vir_rid,

//  invalid table 与 read_data_arbiter 交互
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


);


    wire  [13:0] m0_decoder_axi_ar_addr;
    wire  [7:0]  m0_decoder_axi_ar_arlen;
    wire  [2:0]  m0_decoder_axi_ar_arsize;
    wire  [1:0]  m0_decoder_axi_ar_arburst;
    wire  [5:0]  m0_decoder_axi_ar_arid;
    wire         m0_decoder_axi_ar_valid;
    wire         m0_decoder_axi_ar_ready;

read_address_decoder m0_decoder(
    .clk                 (clk),
    .rst_n               (rst_n),

    .s_axi_index         (2'b00),
    .s_axi_ar_addr       (s0_axi_ar_addr),               
    .s_axi_ar_arlen      (s0_axi_ar_arlen),               
    .s_axi_ar_arsize     (s0_axi_ar_arsize),                   
    .s_axi_ar_arburst    (s0_axi_ar_arburst),                   
    .s_axi_ar_arid       (s0_axi_ar_arid),               
    .s_axi_ar_valid      (s0_axi_ar_valid),               
    .s_axi_ar_ready      (s0_axi_ar_ready),               


    .m_axi_ar_addr       (m0_decoder_axi_ar_addr),  
    .m_axi_ar_arlen      (m0_decoder_axi_ar_arlen),  
    .m_axi_ar_arsize     (m0_decoder_axi_ar_arsize),      
    .m_axi_ar_arburst    (m0_decoder_axi_ar_arburst),      
    .m_axi_ar_arid       (m0_decoder_axi_ar_arid),  
    .m_axi_ar_valid      (m0_decoder_axi_ar_valid),  
    .m_axi_ar_ready      (m0_decoder_axi_ar_ready),  

    .s_axi_fifo_r_rid    (s0_axi_fifo_r_rid),                 
    .s_axi_fifo_r_rlast  (s0_axi_fifo_r_rlast),                 
    .s_axi_fifo_r_valid  (s0_axi_fifo_r_valid),                    
    .s_axi_fifo_r_ready  (s0_axi_fifo_r_ready),

    .s_axi_r_valid       (s0_axi_r_valid),
    .s_axi_r_ready       (s0_axi_r_ready),
    .s_axi_r_rlast       (s0_axi_r_rlast), 

    .r_transactionid0    (m0_r_transactionid0),           
    .r_transactionid1    (m0_r_transactionid1),           
    .r_transactionid2    (m0_r_transactionid2),           
    .itemvalid           (m0_itemvalid),   
    .fkflag              (m0_fkflag)   
);


    wire  [13:0] m1_decoder_axi_ar_addr;
    wire  [7:0]  m1_decoder_axi_ar_arlen;
    wire  [2:0]  m1_decoder_axi_ar_arsize;
    wire  [1:0]  m1_decoder_axi_ar_arburst;
    wire  [5:0]  m1_decoder_axi_ar_arid;
    wire         m1_decoder_axi_ar_valid;
    wire         m1_decoder_axi_ar_ready;

read_address_decoder m1_decoder(
    .clk                 (clk),
    .rst_n               (rst_n),

    .s_axi_index         (2'b01),
    .s_axi_ar_addr       (s1_axi_ar_addr),               
    .s_axi_ar_arlen      (s1_axi_ar_arlen),               
    .s_axi_ar_arsize     (s1_axi_ar_arsize),                   
    .s_axi_ar_arburst    (s1_axi_ar_arburst),                   
    .s_axi_ar_arid       (s1_axi_ar_arid),               
    .s_axi_ar_valid      (s1_axi_ar_valid),               
    .s_axi_ar_ready      (s1_axi_ar_ready),               


    .m_axi_ar_addr       (m1_decoder_axi_ar_addr),  
    .m_axi_ar_arlen      (m1_decoder_axi_ar_arlen),  
    .m_axi_ar_arsize     (m1_decoder_axi_ar_arsize),      
    .m_axi_ar_arburst    (m1_decoder_axi_ar_arburst),      
    .m_axi_ar_arid       (m1_decoder_axi_ar_arid),  
    .m_axi_ar_valid      (m1_decoder_axi_ar_valid),  
    .m_axi_ar_ready      (m1_decoder_axi_ar_ready),  

    .s_axi_fifo_r_rid    (s1_axi_fifo_r_rid),                 
    .s_axi_fifo_r_rlast  (s1_axi_fifo_r_rlast),                 
    .s_axi_fifo_r_valid  (s1_axi_fifo_r_valid),                    
    .s_axi_fifo_r_ready  (s1_axi_fifo_r_ready),

    .s_axi_r_valid       (s1_axi_r_valid),
    .s_axi_r_ready       (s1_axi_r_ready),
    .s_axi_r_rlast       (s1_axi_r_rlast), 

    .r_transactionid0    (m1_r_transactionid0),           
    .r_transactionid1    (m1_r_transactionid1),           
    .r_transactionid2    (m1_r_transactionid2),           
    .itemvalid           (m1_itemvalid),   
    .fkflag              (m1_fkflag)   
);



    wire  [13:0] m2_decoder_axi_ar_addr;
    wire  [7:0]  m2_decoder_axi_ar_arlen;
    wire  [2:0]  m2_decoder_axi_ar_arsize;
    wire  [1:0]  m2_decoder_axi_ar_arburst;
    wire  [5:0]  m2_decoder_axi_ar_arid;
    wire         m2_decoder_axi_ar_valid;
    wire         m2_decoder_axi_ar_ready;

read_address_decoder m2_decoder(
    .clk                 (clk),
    .rst_n               (rst_n),

    .s_axi_index         (2'b10),
    .s_axi_ar_addr       (s2_axi_ar_addr),               
    .s_axi_ar_arlen      (s2_axi_ar_arlen),               
    .s_axi_ar_arsize     (s2_axi_ar_arsize),                   
    .s_axi_ar_arburst    (s2_axi_ar_arburst),                   
    .s_axi_ar_arid       (s2_axi_ar_arid),               
    .s_axi_ar_valid      (s2_axi_ar_valid),               
    .s_axi_ar_ready      (s2_axi_ar_ready),               


    .m_axi_ar_addr       (m2_decoder_axi_ar_addr),  
    .m_axi_ar_arlen      (m2_decoder_axi_ar_arlen),  
    .m_axi_ar_arsize     (m2_decoder_axi_ar_arsize),      
    .m_axi_ar_arburst    (m2_decoder_axi_ar_arburst),      
    .m_axi_ar_arid       (m2_decoder_axi_ar_arid),  
    .m_axi_ar_valid      (m2_decoder_axi_ar_valid),  
    .m_axi_ar_ready      (m2_decoder_axi_ar_ready),  

    .s_axi_fifo_r_rid    (s2_axi_fifo_r_rid),                 
    .s_axi_fifo_r_rlast  (s2_axi_fifo_r_rlast),                 
    .s_axi_fifo_r_valid  (s2_axi_fifo_r_valid),                    
    .s_axi_fifo_r_ready  (s2_axi_fifo_r_ready),

    .s_axi_r_valid       (s2_axi_r_valid),
    .s_axi_r_ready       (s2_axi_r_ready),
    .s_axi_r_rlast       (s2_axi_r_rlast), 

    .r_transactionid0    (m2_r_transactionid0),           
    .r_transactionid1    (m2_r_transactionid1),           
    .r_transactionid2    (m2_r_transactionid2),           
    .itemvalid           (m2_itemvalid),   
    .fkflag              (m2_fkflag)   
);






read_address_arbiter3 read_arb(
    .clk                       (clk),
    .rst_n                     (rst_n),

    .ar_decoder_araddr_s0      (m0_decoder_axi_ar_addr),              
    .ar_decoder_arlen_s0       (m0_decoder_axi_ar_arlen),              
    .ar_decoder_arsize_s0      (m0_decoder_axi_ar_arsize),              
    .ar_decoder_arburst_s0     (m0_decoder_axi_ar_arburst),              
    .ar_decoder_arid_s0        (m0_decoder_axi_ar_arid),          
    .ar_decoder_valid_s0       (m0_decoder_axi_ar_valid),              
    .ar_decoder_ready_s0       (m0_decoder_axi_ar_ready),              

    .ar_decoder_araddr_s1      (m1_decoder_axi_ar_addr),                         
    .ar_decoder_arlen_s1       (m1_decoder_axi_ar_arlen),                         
    .ar_decoder_arsize_s1      (m1_decoder_axi_ar_arsize),                         
    .ar_decoder_arburst_s1     (m1_decoder_axi_ar_arburst),                         
    .ar_decoder_arid_s1        (m1_decoder_axi_ar_arid),                     
    .ar_decoder_valid_s1       (m1_decoder_axi_ar_valid),                         
    .ar_decoder_ready_s1       (m1_decoder_axi_ar_ready),                         

    .ar_decoder_araddr_s2      (m0_decoder_axi_ar_addr),                 
    .ar_decoder_arlen_s2       (m0_decoder_axi_ar_arlen),                 
    .ar_decoder_arsize_s2      (m0_decoder_axi_ar_arsize),                 
    .ar_decoder_arburst_s2     (m0_decoder_axi_ar_arburst),                 
    .ar_decoder_arid_s2        (m0_decoder_axi_ar_arid),             
    .ar_decoder_valid_s2       (m0_decoder_axi_ar_valid),                 
    .ar_decoder_ready_s2       (m0_decoder_axi_ar_ready),                 

    .m0_axi_arbiter_araddr     (m0_axi_ar_addr),                            
    .m0_axi_arbiter_arlen      (m0_axi_ar_arlen),                            
    .m0_axi_arbiter_arsize     (m0_axi_ar_arsize),                            
    .m0_axi_arbiter_arburst    (m0_axi_ar_arburst),                            
    .m0_axi_arbiter_arid       (m0_axi_ar_arid),                            
    .m0_axi_arbiter_valid      (m0_axi_ar_valid),                            
    .m0_axi_arbiter_ready      (m0_axi_ar_ready),                            

    .m1_axi_arbiter_araddr     (m1_axi_ar_addr),                 
    .m1_axi_arbiter_arlen      (m1_axi_ar_arlen),                 
    .m1_axi_arbiter_arsize     (m1_axi_ar_arsize),                 
    .m1_axi_arbiter_arburst    (m1_axi_ar_arburst),                 
    .m1_axi_arbiter_arid       (m1_axi_ar_arid),                 
    .m1_axi_arbiter_valid      (m1_axi_ar_valid),                 
    .m1_axi_arbiter_ready      (m1_axi_ar_ready),                 

    .m2_axi_arbiter_araddr     (m2_axi_ar_addr),                 
    .m2_axi_arbiter_arlen      (m2_axi_ar_arlen),                 
    .m2_axi_arbiter_arsize     (m2_axi_ar_arsize),                 
    .m2_axi_arbiter_arburst    (m2_axi_ar_arburst),                 
    .m2_axi_arbiter_arid       (m2_axi_ar_arid),                 
    .m2_axi_arbiter_valid      (m2_axi_ar_valid),                 
    .m2_axi_arbiter_ready      (m2_axi_ar_ready),   

    .region_read_table_m0      (region_read_table_m0),
    .region_read_table_m1      (region_read_table_m1),
    .region_read_table_m2      (region_read_table_m2),

    .s0_vir_rlast             (s0_vir_rlast),                     
    .s0_vir_rid               (s0_vir_rid),                 
    .s1_vir_rlast             (s1_vir_rlast),                     
    .s1_vir_rid               (s1_vir_rid),                 
    .s2_vir_rlast             (s2_vir_rlast),                     
    .s2_vir_rid               (s2_vir_rid),

    .m0_transaction_invalidid0(m0_transaction_invalidid0),                          
    .m0_transaction_invalidid1(m0_transaction_invalidid1),                          
    .m0_transaction_invalidid2(m0_transaction_invalidid2),                          
    .m0_invalid_len0          (m0_invalid_len0),                  
    .m0_invalid_len1          (m0_invalid_len1),                  
    .m0_invalid_len2          (m0_invalid_len2),                  
    .m0invalid                (m0invalid),          

    .m1_transaction_invalidid0(m1_transaction_invalidid0),                                                  
    .m1_transaction_invalidid1(m1_transaction_invalidid1),                                                  
    .m1_transaction_invalidid2(m1_transaction_invalidid2),                                                  
    .m1_invalid_len0          (m1_invalid_len0          ),                                          
    .m1_invalid_len1          (m1_invalid_len1          ),                                          
    .m1_invalid_len2          (m1_invalid_len2          ),                                          
    .m1invalid                (m1invalid                ),                                  

    .m2_transaction_invalidid0(m2_transaction_invalidid0),                              
    .m2_transaction_invalidid1(m2_transaction_invalidid1),                              
    .m2_transaction_invalidid2(m2_transaction_invalidid2),                              
    .m2_invalid_len0          (m2_invalid_len0),                      
    .m2_invalid_len1          (m2_invalid_len1),                      
    .m2_invalid_len2          (m2_invalid_len2),                      
    .m2invalid                (m2invalid   )                  


    );









endmodule