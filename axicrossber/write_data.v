

module write_data(
    input   clk,
    input   rst_n,

    input  [ 3:0] s0_axi_w_wid,
    input  [31:0] s0_axi_w_wdata,
    input         s0_axi_w_wlast,
    input  [ 3:0] s0_axi_w_wstrb,
    input         s0_axi_w_valid,
    output        s0_axi_w_ready,

    input  [ 3:0] s1_axi_w_wid,
    input  [31:0] s1_axi_w_wdata,
    input         s1_axi_w_wlast,
    input  [ 3:0] s1_axi_w_wstrb,
    input         s1_axi_w_valid,
    output        s1_axi_w_ready,

    input  [ 3:0] s2_axi_w_wid,
    input  [31:0] s2_axi_w_wdata,
    input         s2_axi_w_wlast,
    input  [ 3:0] s2_axi_w_wstrb,
    input         s2_axi_w_valid,
    output        s2_axi_w_ready,

    output  [ 5:0] m0_axi_w_wid,
    output  [31:0] m0_axi_w_wdata,
    output         m0_axi_w_wlast,
    output  [ 3:0] m0_axi_w_wstrb,
    output         m0_axi_w_valid,
    input          m0_axi_w_ready,

    output  [ 5:0] m1_axi_w_wid,
    output  [31:0] m1_axi_w_wdata,
    output         m1_axi_w_wlast,
    output  [ 3:0] m1_axi_w_wstrb,
    output         m1_axi_w_valid,
    input          m1_axi_w_ready,


    output  [ 5:0] m2_axi_w_wid,
    output  [31:0] m2_axi_w_wdata,
    output         m2_axi_w_wlast,
    output  [ 3:0] m2_axi_w_wstrb,
    output         m2_axi_w_valid,
    input          m2_axi_w_ready,


// write_address_arbiter提供
    input  [ 5:0]  m0_transaction_invalidid0,
    input  [ 5:0]  m0_transaction_invalidid1,
    input  [ 5:0]  m0_transaction_invalidid2,
    input  [ 2:0]  m0_invalid,

    input  [ 5:0]  m1_transaction_invalidid0,
    input  [ 5:0]  m1_transaction_invalidid1,
    input  [ 5:0]  m1_transaction_invalidid2,
    input  [ 2:0]  m1_invalid,


    input  [ 5:0]  m2_transaction_invalidid0,
    input  [ 5:0]  m2_transaction_invalidid1,
    input  [ 5:0]  m2_transaction_invalidid2,
    input  [ 2:0]  m2_invalid,


// 最终合并的写返回，与连接回主机的B通道相同
    input  [ 3:0]  s0_axi_b_bid,
    input          s0_axi_b_valid,
    input          s0_axi_b_ready,    

    input  [ 3:0]  s1_axi_b_bid,
    input          s1_axi_b_valid,
    input          s1_axi_b_ready,

    input  [ 3:0]  s2_axi_b_bid,
    input          s2_axi_b_valid,
    input          s2_axi_b_ready,

// 提供至write_response 主机0
    output         m0_invalidfifo_flush,
    output [ 3:0]  m0_invalidfifo_wid,

    output [ 1:0]  m0_IDgrant0,
    output [ 1:0]  m0_IDgrant1,
    output [ 1:0]  m0_IDgrant2,

// 提供至write_response 主机1
    output         m1_invalidfifo_flush,
    output [ 3:0]  m1_invalidfifo_wid,

    output [ 1:0]  m1_IDgrant0,
    output [ 1:0]  m1_IDgrant1,
    output [ 1:0]  m1_IDgrant2,

// 提供至write_response 主机2
    output         m2_invalidfifo_flush,
    output [ 3:0]  m2_invalidfifo_wid,

    output [ 1:0]  m2_IDgrant0,
    output [ 1:0]  m2_IDgrant1,
    output [ 1:0]  m2_IDgrant2,


// validtable 提供给write_data_arbiter 从机0
    output  [5:0] s0_validid0,
    output  [5:0] s0_validid1,
    output  [5:0] s0_validid2,
    output  [2:0] s0_valid,
    output  [7:0] s0_wlen0,
    output  [7:0] s0_wlen1,
    output  [7:0] s0_wlen2,

// validtable 提供给write_data_arbiter 从机1
    output  [5:0] s1_validid0,
    output  [5:0] s1_validid1,
    output  [5:0] s1_validid2,
    output  [2:0] s1_valid,
    output  [7:0] s1_wlen0,
    output  [7:0] s1_wlen1,
    output  [7:0] s1_wlen2,

// validtable 提供给write_data_arbiter 从机2
    output  [5:0] s2_validid0,
    output  [5:0] s2_validid1,
    output  [5:0] s2_validid2,
    output  [2:0] s2_valid,
    output  [7:0] s2_wlen0,
    output  [7:0] s2_wlen1,
    output  [7:0] s2_wlen2


);


    wire  [ 5:0] m0_axi_fifo0_w_wid;
    wire  [31:0] m0_axi_fifo0_w_wdata;
    wire         m0_axi_fifo0_w_wlast;
    wire  [ 3:0] m0_axi_fifo0_w_wstrb;
    wire         m0_axi_fifo0_w_valid;
    wire         m0_axi_fifo0_w_ready;

    wire  [ 5:0] m0_axi_fifo1_w_wid;
    wire  [31:0] m0_axi_fifo1_w_wdata;
    wire         m0_axi_fifo1_w_wlast;
    wire  [ 3:0] m0_axi_fifo1_w_wstrb;
    wire         m0_axi_fifo1_w_valid;
    wire         m0_axi_fifo1_w_ready;

    wire  [ 5:0] m0_axi_fifo2_w_wid;
    wire  [31:0] m0_axi_fifo2_w_wdata;
    wire         m0_axi_fifo2_w_wlast;
    wire  [ 3:0] m0_axi_fifo2_w_wstrb;
    wire         m0_axi_fifo2_w_valid;
    wire         m0_axi_fifo2_w_ready;


write_data_fifo_lut m0_fifo_lut(
     .clk                 (clk),
     .rst_n               (rst_n),

     .s_axi_index        (2'b00)  ,                
     .s_axi_w_wid        (s0_axi_w_wid)  ,                        
     .s_axi_w_wdata      (s0_axi_w_wdata),                     
     .s_axi_w_wlast      (s0_axi_w_wlast),                               
     .s_axi_w_wstrb      (s0_axi_w_wstrb),                     
     .s_axi_w_valid      (s0_axi_w_valid),    
     .s_axi_w_ready      (s0_axi_w_ready),    

     .m_axi_fifo0_w_wid    (m0_axi_fifo0_w_wid),                                 
     .m_axi_fifo0_w_wdata  (m0_axi_fifo0_w_wdata),                                     
     .m_axi_fifo0_w_wlast  (m0_axi_fifo0_w_wlast),                                     
     .m_axi_fifo0_w_wstrb  (m0_axi_fifo0_w_wstrb),                                     
     .m_axi_fifo0_w_valid  (m0_axi_fifo0_w_valid),                                     
     .m_axi_fifo0_w_ready  (m0_axi_fifo0_w_ready),

     .m_axi_fifo1_w_wid    (m0_axi_fifo1_w_wid),                                 
     .m_axi_fifo1_w_wdata  (m0_axi_fifo1_w_wdata),                                     
     .m_axi_fifo1_w_wlast  (m0_axi_fifo1_w_wlast),                                     
     .m_axi_fifo1_w_wstrb  (m0_axi_fifo1_w_wstrb),                                     
     .m_axi_fifo1_w_valid  (m0_axi_fifo1_w_valid),                                     
     .m_axi_fifo1_w_ready  (m0_axi_fifo1_w_ready), 

     .m_axi_fifo2_w_wid    (m0_axi_fifo2_w_wid),                                 
     .m_axi_fifo2_w_wdata  (m0_axi_fifo2_w_wdata),                                     
     .m_axi_fifo2_w_wlast  (m0_axi_fifo2_w_wlast),                                     
     .m_axi_fifo2_w_wstrb  (m0_axi_fifo2_w_wstrb),                                     
     .m_axi_fifo2_w_valid  (m0_axi_fifo2_w_valid),                                     
     .m_axi_fifo2_w_ready  (m0_axi_fifo2_w_ready),                                                 

     .m_transaction_invalidid0(m0_transaction_invalidid0),
     .m_transaction_invalidid1(m0_transaction_invalidid1),
     .m_transaction_invalidid2(m0_transaction_invalidid2),
     .m_invalid               (m0_invalid),


     .s_axi_b_bid         (s0_axi_b_bid),                                     
     .s_axi_b_valid       (s0_axi_b_valid),                             
     .s_axi_b_ready       (s0_axi_b_ready),                         

     .invalidfifo_flush   (m0_invalidfifo_flush),                                              
     .invalidfifo_wid     (m0_invalidfifo_wid),                                              
     .IDgrant0            (m0_IDgrant0),                                      
     .IDgrant1            (m0_IDgrant1),                                      
     .IDgrant2            (m0_IDgrant2)                                      
);

    wire  [ 5:0] m1_axi_fifo0_w_wid;
    wire  [31:0] m1_axi_fifo0_w_wdata;
    wire         m1_axi_fifo0_w_wlast;
    wire  [ 3:0] m1_axi_fifo0_w_wstrb;
    wire         m1_axi_fifo0_w_valid;
    wire         m1_axi_fifo0_w_ready;

    wire  [ 5:0] m1_axi_fifo1_w_wid;
    wire  [31:0] m1_axi_fifo1_w_wdata;
    wire         m1_axi_fifo1_w_wlast;
    wire  [ 3:0] m1_axi_fifo1_w_wstrb;
    wire         m1_axi_fifo1_w_valid;
    wire         m1_axi_fifo1_w_ready;

    wire  [ 5:0] m1_axi_fifo2_w_wid;
    wire  [31:0] m1_axi_fifo2_w_wdata;
    wire         m1_axi_fifo2_w_wlast;
    wire  [ 3:0] m1_axi_fifo2_w_wstrb;
    wire         m1_axi_fifo2_w_valid;
    wire         m1_axi_fifo2_w_ready;



write_data_fifo_lut m1_fifo_lut(
     .clk                 (clk),
     .rst_n               (rst_n),

     .s_axi_index        (2'b01)  ,                
     .s_axi_w_wid        (s1_axi_w_wid)  ,                        
     .s_axi_w_wdata      (s1_axi_w_wdata),                     
     .s_axi_w_wlast      (s1_axi_w_wlast),                               
     .s_axi_w_wstrb      (s1_axi_w_wstrb),                     
     .s_axi_w_valid      (s1_axi_w_valid),    
     .s_axi_w_ready      (s1_axi_w_ready),    

     .m_axi_fifo0_w_wid    (m1_axi_fifo0_w_wid),                                 
     .m_axi_fifo0_w_wdata  (m1_axi_fifo0_w_wdata),                                     
     .m_axi_fifo0_w_wlast  (m1_axi_fifo0_w_wlast),                                     
     .m_axi_fifo0_w_wstrb  (m1_axi_fifo0_w_wstrb),                                     
     .m_axi_fifo0_w_valid  (m1_axi_fifo0_w_valid),                                     
     .m_axi_fifo0_w_ready  (m1_axi_fifo0_w_ready),

     .m_axi_fifo1_w_wid    (m1_axi_fifo1_w_wid),                                 
     .m_axi_fifo1_w_wdata  (m1_axi_fifo1_w_wdata),                                     
     .m_axi_fifo1_w_wlast  (m1_axi_fifo1_w_wlast),                                     
     .m_axi_fifo1_w_wstrb  (m1_axi_fifo1_w_wstrb),                                     
     .m_axi_fifo1_w_valid  (m1_axi_fifo1_w_valid),                                     
     .m_axi_fifo1_w_ready  (m1_axi_fifo1_w_ready), 

     .m_axi_fifo2_w_wid    (m1_axi_fifo2_w_wid),                                 
     .m_axi_fifo2_w_wdata  (m1_axi_fifo2_w_wdata),                                     
     .m_axi_fifo2_w_wlast  (m1_axi_fifo2_w_wlast),                                     
     .m_axi_fifo2_w_wstrb  (m1_axi_fifo2_w_wstrb),                                     
     .m_axi_fifo2_w_valid  (m1_axi_fifo2_w_valid),                                     
     .m_axi_fifo2_w_ready  (m1_axi_fifo2_w_ready),                                                 

     .m_transaction_invalidid0(m1_transaction_invalidid0),
     .m_transaction_invalidid1(m1_transaction_invalidid1),
     .m_transaction_invalidid2(m1_transaction_invalidid2),
     .m_invalid               (m1_invalid),


     .s_axi_b_bid         (s1_axi_b_bid),                                     
     .s_axi_b_valid       (s1_axi_b_valid),                             
     .s_axi_b_ready       (s1_axi_b_ready),                         

     .invalidfifo_flush   (m1_invalidfifo_flush),                                              
     .invalidfifo_wid     (m1_invalidfifo_wid),                                              
     .IDgrant0            (m1_IDgrant0),                                      
     .IDgrant1            (m1_IDgrant1),                                      
     .IDgrant2            (m1_IDgrant2)                                      
);














    wire  [ 5:0] m2_axi_fifo0_w_wid;
    wire  [31:0] m2_axi_fifo0_w_wdata;
    wire         m2_axi_fifo0_w_wlast;
    wire  [ 3:0] m2_axi_fifo0_w_wstrb;
    wire         m2_axi_fifo0_w_valid;
    wire         m2_axi_fifo0_w_ready;

    wire  [ 5:0] m2_axi_fifo1_w_wid;
    wire  [31:0] m2_axi_fifo1_w_wdata;
    wire         m2_axi_fifo1_w_wlast;
    wire  [ 3:0] m2_axi_fifo1_w_wstrb;
    wire         m2_axi_fifo1_w_valid;
    wire         m2_axi_fifo1_w_ready;

    wire  [ 5:0] m2_axi_fifo2_w_wid;
    wire  [31:0] m2_axi_fifo2_w_wdata;
    wire         m2_axi_fifo2_w_wlast;
    wire  [ 3:0] m2_axi_fifo2_w_wstrb;
    wire         m2_axi_fifo2_w_valid;
    wire         m2_axi_fifo2_w_ready;


write_data_fifo_lut m2_fifo_lut(
     .clk                 (clk),
     .rst_n               (rst_n),

     .s_axi_index        (2'b10)  ,                
     .s_axi_w_wid        (s2_axi_w_wid)  ,                        
     .s_axi_w_wdata      (s2_axi_w_wdata),                     
     .s_axi_w_wlast      (s2_axi_w_wlast),                               
     .s_axi_w_wstrb      (s2_axi_w_wstrb),                     
     .s_axi_w_valid      (s2_axi_w_valid),    
     .s_axi_w_ready      (s2_axi_w_ready),    

     .m_axi_fifo0_w_wid    (m2_axi_fifo0_w_wid),                                 
     .m_axi_fifo0_w_wdata  (m2_axi_fifo0_w_wdata),                                     
     .m_axi_fifo0_w_wlast  (m2_axi_fifo0_w_wlast),                                     
     .m_axi_fifo0_w_wstrb  (m2_axi_fifo0_w_wstrb),                                     
     .m_axi_fifo0_w_valid  (m2_axi_fifo0_w_valid),                                     
     .m_axi_fifo0_w_ready  (m2_axi_fifo0_w_ready),

     .m_axi_fifo1_w_wid    (m2_axi_fifo1_w_wid),                                 
     .m_axi_fifo1_w_wdata  (m2_axi_fifo1_w_wdata),                                     
     .m_axi_fifo1_w_wlast  (m2_axi_fifo1_w_wlast),                                     
     .m_axi_fifo1_w_wstrb  (m2_axi_fifo1_w_wstrb),                                     
     .m_axi_fifo1_w_valid  (m2_axi_fifo1_w_valid),                                     
     .m_axi_fifo1_w_ready  (m2_axi_fifo1_w_ready), 

     .m_axi_fifo2_w_wid    (m2_axi_fifo2_w_wid),                                 
     .m_axi_fifo2_w_wdata  (m2_axi_fifo2_w_wdata),                                     
     .m_axi_fifo2_w_wlast  (m2_axi_fifo2_w_wlast),                                     
     .m_axi_fifo2_w_wstrb  (m2_axi_fifo2_w_wstrb),                                     
     .m_axi_fifo2_w_valid  (m2_axi_fifo2_w_valid),                                     
     .m_axi_fifo2_w_ready  (m2_axi_fifo2_w_ready),                                                 

     .m_transaction_invalidid0(m2_transaction_invalidid0),
     .m_transaction_invalidid1(m2_transaction_invalidid1),
     .m_transaction_invalidid2(m2_transaction_invalidid2),
     .m_invalid               (m2_invalid),


     .s_axi_b_bid         (s2_axi_b_bid),                                     
     .s_axi_b_valid       (s2_axi_b_valid),                             
     .s_axi_b_ready       (s2_axi_b_ready),                         

     .invalidfifo_flush   (m2_invalidfifo_flush),                                              
     .invalidfifo_wid     (m2_invalidfifo_wid),                                              
     .IDgrant0            (m2_IDgrant0),                                      
     .IDgrant1            (m2_IDgrant1),                                      
     .IDgrant2            (m2_IDgrant2)                                      
);



// 从机0
write_data_arbiter s0_arbiter(
     .clk                   (clk),
     .rst_n                 (rst_n),        

     .s0_axi_w_fifo0_wid    (m0_axi_w_fifo0_wid  ),                
     .s0_axi_w_fifo0_wdata  (m0_axi_w_fifo0_wdata),                
     .s0_axi_w_fifo0_wlast  (m0_axi_w_fifo0_wlast),                
     .s0_axi_w_fifo0_wstrb  (m0_axi_w_fifo0_wstrb),                
     .s0_axi_w_fifo0_valid  (m0_axi_w_fifo0_valid),                
     .s0_axi_w_fifo0_ready  (m0_axi_w_fifo0_ready),                
     .s0_fifo0_IDgrant      (m0_IDgrant0),

     .s0_axi_w_fifo1_wid    (m0_axi_w_fifo1_wid  ),           
     .s0_axi_w_fifo1_wdata  (m0_axi_w_fifo1_wdata),           
     .s0_axi_w_fifo1_wlast  (m0_axi_w_fifo1_wlast),           
     .s0_axi_w_fifo1_wstrb  (m0_axi_w_fifo1_wstrb),           
     .s0_axi_w_fifo1_valid  (m0_axi_w_fifo1_valid),           
     .s0_axi_w_fifo1_ready  (m0_axi_w_fifo1_ready),           
     .s0_fifo1_IDgrant      (m0_IDgrant1),

     .s0_axi_w_fifo2_wid    (s0_axi_w_fifo2_wid  ),            
     .s0_axi_w_fifo2_wdata  (s0_axi_w_fifo2_wdata),            
     .s0_axi_w_fifo2_wlast  (s0_axi_w_fifo2_wlast),            
     .s0_axi_w_fifo2_wstrb  (s0_axi_w_fifo2_wstrb),            
     .s0_axi_w_fifo2_valid  (s0_axi_w_fifo2_valid),            
     .s0_axi_w_fifo2_ready  (s0_axi_w_fifo2_ready),            
     .s0_fifo2_IDgrant      (m0_IDgrant2),

     .s1_axi_w_fifo0_wid    (m1_axi_w_fifo0_wid  ),                
     .s1_axi_w_fifo0_wdata  (m1_axi_w_fifo0_wdata),                
     .s1_axi_w_fifo0_wlast  (m1_axi_w_fifo0_wlast),                
     .s1_axi_w_fifo0_wstrb  (m1_axi_w_fifo0_wstrb),                
     .s1_axi_w_fifo0_valid  (m1_axi_w_fifo0_valid),                
     .s1_axi_w_fifo0_ready  (m1_axi_w_fifo0_ready),                
     .s1_fifo0_IDgrant      (m1_IDgrant0),

     .s1_axi_w_fifo1_wid    (m1_axi_w_fifo1_wid  ),           
     .s1_axi_w_fifo1_wdata  (m1_axi_w_fifo1_wdata),           
     .s1_axi_w_fifo1_wlast  (m1_axi_w_fifo1_wlast),           
     .s1_axi_w_fifo1_wstrb  (m1_axi_w_fifo1_wstrb),           
     .s1_axi_w_fifo1_valid  (m1_axi_w_fifo1_valid),           
     .s1_axi_w_fifo1_ready  (m1_axi_w_fifo1_ready),           
     .s1_fifo1_IDgrant      (m1_IDgrant1),

     .s1_axi_w_fifo2_wid    (s1_axi_w_fifo2_wid  ),            
     .s1_axi_w_fifo2_wdata  (s1_axi_w_fifo2_wdata),            
     .s1_axi_w_fifo2_wlast  (s1_axi_w_fifo2_wlast),            
     .s1_axi_w_fifo2_wstrb  (s1_axi_w_fifo2_wstrb),            
     .s1_axi_w_fifo2_valid  (s1_axi_w_fifo2_valid),            
     .s1_axi_w_fifo2_ready  (s1_axi_w_fifo2_ready),            
     .s1_fifo2_IDgrant      (m1_IDgrant2),  

     .s2_axi_w_fifo0_wid    (m2_axi_w_fifo0_wid  ),                
     .s2_axi_w_fifo0_wdata  (m2_axi_w_fifo0_wdata),                
     .s2_axi_w_fifo0_wlast  (m2_axi_w_fifo0_wlast),                
     .s2_axi_w_fifo0_wstrb  (m2_axi_w_fifo0_wstrb),                
     .s2_axi_w_fifo0_valid  (m2_axi_w_fifo0_valid),                
     .s2_axi_w_fifo0_ready  (m2_axi_w_fifo0_ready),                
     .s2_fifo0_IDgrant      (m2_IDgrant0),

     .s2_axi_w_fifo1_wid    (m2_axi_w_fifo1_wid  ),           
     .s2_axi_w_fifo1_wdata  (m2_axi_w_fifo1_wdata),           
     .s2_axi_w_fifo1_wlast  (m2_axi_w_fifo1_wlast),           
     .s2_axi_w_fifo1_wstrb  (m2_axi_w_fifo1_wstrb),           
     .s2_axi_w_fifo1_valid  (m2_axi_w_fifo1_valid),           
     .s2_axi_w_fifo1_ready  (m2_axi_w_fifo1_ready),           
     .s2_fifo1_IDgrant      (m2_IDgrant1),

     .s2_axi_w_fifo2_wid    (s2_axi_w_fifo2_wid  ),            
     .s2_axi_w_fifo2_wdata  (s2_axi_w_fifo2_wdata),            
     .s2_axi_w_fifo2_wlast  (s2_axi_w_fifo2_wlast),            
     .s2_axi_w_fifo2_wstrb  (s2_axi_w_fifo2_wstrb),            
     .s2_axi_w_fifo2_valid  (s2_axi_w_fifo2_valid),            
     .s2_axi_w_fifo2_ready  (s2_axi_w_fifo2_ready),            
     .s2_fifo2_IDgrant      (m2_IDgrant2),     

     .s_validid0            (s0_validid0),                                
     .s_validid1            (s0_validid1),                                
     .s_validid2            (s0_validid2),                                
     .s_valid               (s0_valid),                            
     .s_wlen0               (s0_wlen0),                            
     .s_wlen1               (s0_wlen1),                            
     .s_wlen2               (s0_wlen2), 

     .m_axi_w_wid           (m0_axi_w_wid),        
     .m_axi_w_wdata         (m0_axi_w_wdata),        
     .m_axi_w_wlast         (m0_axi_w_wlast),        
     .m_axi_w_wstrb         (m0_axi_w_wstrb),        
     .m_axi_w_valid         (m0_axi_w_valid),        
     .m_axi_w_ready         (m0_axi_w_ready)        

    );


//从机1

write_data_arbiter s1_arbiter(
     .clk                   (clk),
     .rst_n                 (rst_n),        

     .s0_axi_w_fifo0_wid    (m0_axi_w_fifo0_wid  ),                
     .s0_axi_w_fifo0_wdata  (m0_axi_w_fifo0_wdata),                
     .s0_axi_w_fifo0_wlast  (m0_axi_w_fifo0_wlast),                
     .s0_axi_w_fifo0_wstrb  (m0_axi_w_fifo0_wstrb),                
     .s0_axi_w_fifo0_valid  (m0_axi_w_fifo0_valid),                
     .s0_axi_w_fifo0_ready  (m0_axi_w_fifo0_ready),                
     .s0_fifo0_IDgrant      (m0_IDgrant0),

     .s0_axi_w_fifo1_wid    (m0_axi_w_fifo1_wid  ),           
     .s0_axi_w_fifo1_wdata  (m0_axi_w_fifo1_wdata),           
     .s0_axi_w_fifo1_wlast  (m0_axi_w_fifo1_wlast),           
     .s0_axi_w_fifo1_wstrb  (m0_axi_w_fifo1_wstrb),           
     .s0_axi_w_fifo1_valid  (m0_axi_w_fifo1_valid),           
     .s0_axi_w_fifo1_ready  (m0_axi_w_fifo1_ready),           
     .s0_fifo1_IDgrant      (m0_IDgrant1),

     .s0_axi_w_fifo2_wid    (s0_axi_w_fifo2_wid  ),            
     .s0_axi_w_fifo2_wdata  (s0_axi_w_fifo2_wdata),            
     .s0_axi_w_fifo2_wlast  (s0_axi_w_fifo2_wlast),            
     .s0_axi_w_fifo2_wstrb  (s0_axi_w_fifo2_wstrb),            
     .s0_axi_w_fifo2_valid  (s0_axi_w_fifo2_valid),            
     .s0_axi_w_fifo2_ready  (s0_axi_w_fifo2_ready),            
     .s0_fifo2_IDgrant      (m0_IDgrant2),

     .s1_axi_w_fifo0_wid    (m1_axi_w_fifo0_wid  ),                
     .s1_axi_w_fifo0_wdata  (m1_axi_w_fifo0_wdata),                
     .s1_axi_w_fifo0_wlast  (m1_axi_w_fifo0_wlast),                
     .s1_axi_w_fifo0_wstrb  (m1_axi_w_fifo0_wstrb),                
     .s1_axi_w_fifo0_valid  (m1_axi_w_fifo0_valid),                
     .s1_axi_w_fifo0_ready  (m1_axi_w_fifo0_ready),                
     .s1_fifo0_IDgrant      (m1_IDgrant0),

     .s1_axi_w_fifo1_wid    (m1_axi_w_fifo1_wid  ),           
     .s1_axi_w_fifo1_wdata  (m1_axi_w_fifo1_wdata),           
     .s1_axi_w_fifo1_wlast  (m1_axi_w_fifo1_wlast),           
     .s1_axi_w_fifo1_wstrb  (m1_axi_w_fifo1_wstrb),           
     .s1_axi_w_fifo1_valid  (m1_axi_w_fifo1_valid),           
     .s1_axi_w_fifo1_ready  (m1_axi_w_fifo1_ready),           
     .s1_fifo1_IDgrant      (m1_IDgrant1),

     .s1_axi_w_fifo2_wid    (s1_axi_w_fifo2_wid  ),            
     .s1_axi_w_fifo2_wdata  (s1_axi_w_fifo2_wdata),            
     .s1_axi_w_fifo2_wlast  (s1_axi_w_fifo2_wlast),            
     .s1_axi_w_fifo2_wstrb  (s1_axi_w_fifo2_wstrb),            
     .s1_axi_w_fifo2_valid  (s1_axi_w_fifo2_valid),            
     .s1_axi_w_fifo2_ready  (s1_axi_w_fifo2_ready),            
     .s1_fifo2_IDgrant      (m1_IDgrant2),  

     .s2_axi_w_fifo0_wid    (m2_axi_w_fifo0_wid  ),                
     .s2_axi_w_fifo0_wdata  (m2_axi_w_fifo0_wdata),                
     .s2_axi_w_fifo0_wlast  (m2_axi_w_fifo0_wlast),                
     .s2_axi_w_fifo0_wstrb  (m2_axi_w_fifo0_wstrb),                
     .s2_axi_w_fifo0_valid  (m2_axi_w_fifo0_valid),                
     .s2_axi_w_fifo0_ready  (m2_axi_w_fifo0_ready),                
     .s2_fifo0_IDgrant      (m2_IDgrant0),

     .s2_axi_w_fifo1_wid    (m2_axi_w_fifo1_wid  ),           
     .s2_axi_w_fifo1_wdata  (m2_axi_w_fifo1_wdata),           
     .s2_axi_w_fifo1_wlast  (m2_axi_w_fifo1_wlast),           
     .s2_axi_w_fifo1_wstrb  (m2_axi_w_fifo1_wstrb),           
     .s2_axi_w_fifo1_valid  (m2_axi_w_fifo1_valid),           
     .s2_axi_w_fifo1_ready  (m2_axi_w_fifo1_ready),           
     .s2_fifo1_IDgrant      (m2_IDgrant1),

     .s2_axi_w_fifo2_wid    (s2_axi_w_fifo2_wid  ),            
     .s2_axi_w_fifo2_wdata  (s2_axi_w_fifo2_wdata),            
     .s2_axi_w_fifo2_wlast  (s2_axi_w_fifo2_wlast),            
     .s2_axi_w_fifo2_wstrb  (s2_axi_w_fifo2_wstrb),            
     .s2_axi_w_fifo2_valid  (s2_axi_w_fifo2_valid),            
     .s2_axi_w_fifo2_ready  (s2_axi_w_fifo2_ready),            
     .s2_fifo2_IDgrant      (m2_IDgrant2),     

     .s_validid0            (s1_validid0),                                
     .s_validid1            (s1_validid1),                                
     .s_validid2            (s1_validid2),                                
     .s_valid               (s1_valid),                            
     .s_wlen0               (s1_wlen0),                            
     .s_wlen1               (s1_wlen1),                            
     .s_wlen2               (s1_wlen2), 

     .m_axi_w_wid           (m1_axi_w_wid),        
     .m_axi_w_wdata         (m1_axi_w_wdata),        
     .m_axi_w_wlast         (m1_axi_w_wlast),        
     .m_axi_w_wstrb         (m1_axi_w_wstrb),        
     .m_axi_w_valid         (m1_axi_w_valid),        
     .m_axi_w_ready         (m1_axi_w_ready)        

    );


// 从机2

write_data_arbiter s2_arbiter(
     .clk                   (clk),
     .rst_n                 (rst_n),        

     .s0_axi_w_fifo0_wid    (m0_axi_w_fifo0_wid  ),                
     .s0_axi_w_fifo0_wdata  (m0_axi_w_fifo0_wdata),                
     .s0_axi_w_fifo0_wlast  (m0_axi_w_fifo0_wlast),                
     .s0_axi_w_fifo0_wstrb  (m0_axi_w_fifo0_wstrb),                
     .s0_axi_w_fifo0_valid  (m0_axi_w_fifo0_valid),                
     .s0_axi_w_fifo0_ready  (m0_axi_w_fifo0_ready),                
     .s0_fifo0_IDgrant      (m0_IDgrant0),

     .s0_axi_w_fifo1_wid    (m0_axi_w_fifo1_wid  ),           
     .s0_axi_w_fifo1_wdata  (m0_axi_w_fifo1_wdata),           
     .s0_axi_w_fifo1_wlast  (m0_axi_w_fifo1_wlast),           
     .s0_axi_w_fifo1_wstrb  (m0_axi_w_fifo1_wstrb),           
     .s0_axi_w_fifo1_valid  (m0_axi_w_fifo1_valid),           
     .s0_axi_w_fifo1_ready  (m0_axi_w_fifo1_ready),           
     .s0_fifo1_IDgrant      (m0_IDgrant1),

     .s0_axi_w_fifo2_wid    (s0_axi_w_fifo2_wid  ),            
     .s0_axi_w_fifo2_wdata  (s0_axi_w_fifo2_wdata),            
     .s0_axi_w_fifo2_wlast  (s0_axi_w_fifo2_wlast),            
     .s0_axi_w_fifo2_wstrb  (s0_axi_w_fifo2_wstrb),            
     .s0_axi_w_fifo2_valid  (s0_axi_w_fifo2_valid),            
     .s0_axi_w_fifo2_ready  (s0_axi_w_fifo2_ready),            
     .s0_fifo2_IDgrant      (m0_IDgrant2),

     .s1_axi_w_fifo0_wid    (m1_axi_w_fifo0_wid  ),                
     .s1_axi_w_fifo0_wdata  (m1_axi_w_fifo0_wdata),                
     .s1_axi_w_fifo0_wlast  (m1_axi_w_fifo0_wlast),                
     .s1_axi_w_fifo0_wstrb  (m1_axi_w_fifo0_wstrb),                
     .s1_axi_w_fifo0_valid  (m1_axi_w_fifo0_valid),                
     .s1_axi_w_fifo0_ready  (m1_axi_w_fifo0_ready),                
     .s1_fifo0_IDgrant      (m1_IDgrant0),

     .s1_axi_w_fifo1_wid    (m1_axi_w_fifo1_wid  ),           
     .s1_axi_w_fifo1_wdata  (m1_axi_w_fifo1_wdata),           
     .s1_axi_w_fifo1_wlast  (m1_axi_w_fifo1_wlast),           
     .s1_axi_w_fifo1_wstrb  (m1_axi_w_fifo1_wstrb),           
     .s1_axi_w_fifo1_valid  (m1_axi_w_fifo1_valid),           
     .s1_axi_w_fifo1_ready  (m1_axi_w_fifo1_ready),           
     .s1_fifo1_IDgrant      (m1_IDgrant1),

     .s1_axi_w_fifo2_wid    (s1_axi_w_fifo2_wid  ),            
     .s1_axi_w_fifo2_wdata  (s1_axi_w_fifo2_wdata),            
     .s1_axi_w_fifo2_wlast  (s1_axi_w_fifo2_wlast),            
     .s1_axi_w_fifo2_wstrb  (s1_axi_w_fifo2_wstrb),            
     .s1_axi_w_fifo2_valid  (s1_axi_w_fifo2_valid),            
     .s1_axi_w_fifo2_ready  (s1_axi_w_fifo2_ready),            
     .s1_fifo2_IDgrant      (m1_IDgrant2),  

     .s2_axi_w_fifo0_wid    (m2_axi_w_fifo0_wid  ),                
     .s2_axi_w_fifo0_wdata  (m2_axi_w_fifo0_wdata),                
     .s2_axi_w_fifo0_wlast  (m2_axi_w_fifo0_wlast),                
     .s2_axi_w_fifo0_wstrb  (m2_axi_w_fifo0_wstrb),                
     .s2_axi_w_fifo0_valid  (m2_axi_w_fifo0_valid),                
     .s2_axi_w_fifo0_ready  (m2_axi_w_fifo0_ready),                
     .s2_fifo0_IDgrant      (m2_IDgrant0),

     .s2_axi_w_fifo1_wid    (m2_axi_w_fifo1_wid  ),           
     .s2_axi_w_fifo1_wdata  (m2_axi_w_fifo1_wdata),           
     .s2_axi_w_fifo1_wlast  (m2_axi_w_fifo1_wlast),           
     .s2_axi_w_fifo1_wstrb  (m2_axi_w_fifo1_wstrb),           
     .s2_axi_w_fifo1_valid  (m2_axi_w_fifo1_valid),           
     .s2_axi_w_fifo1_ready  (m2_axi_w_fifo1_ready),           
     .s2_fifo1_IDgrant      (m2_IDgrant1),

     .s2_axi_w_fifo2_wid    (s2_axi_w_fifo2_wid  ),            
     .s2_axi_w_fifo2_wdata  (s2_axi_w_fifo2_wdata),            
     .s2_axi_w_fifo2_wlast  (s2_axi_w_fifo2_wlast),            
     .s2_axi_w_fifo2_wstrb  (s2_axi_w_fifo2_wstrb),            
     .s2_axi_w_fifo2_valid  (s2_axi_w_fifo2_valid),            
     .s2_axi_w_fifo2_ready  (s2_axi_w_fifo2_ready),            
     .s2_fifo2_IDgrant      (m2_IDgrant2),     

     .s_validid0            (s2_validid0),                                
     .s_validid1            (s2_validid1),                                
     .s_validid2            (s2_validid2),                                
     .s_valid               (s2_valid),                            
     .s_wlen0               (s2_wlen0),                            
     .s_wlen1               (s2_wlen1),                            
     .s_wlen2               (s2_wlen2), 

     .m_axi_w_wid           (m2_axi_w_wid),        
     .m_axi_w_wdata         (m2_axi_w_wdata),        
     .m_axi_w_wlast         (m2_axi_w_wlast),        
     .m_axi_w_wstrb         (m2_axi_w_wstrb),        
     .m_axi_w_valid         (m2_axi_w_valid),        
     .m_axi_w_ready         (m2_axi_w_ready)        

    );






endmodule