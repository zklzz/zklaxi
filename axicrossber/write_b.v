
module write_b(
    input clk,
    input rst_n,

    input  [5:0] m0_axi_b_bid,
    input  [1:0] m0_axi_b_bresp,
    input        m0_axi_b_valid,
    output       m0_axi_b_ready,

    input  [5:0] m1_axi_b_bid,
    input  [1:0] m1_axi_b_bresp,
    input        m1_axi_b_valid,
    output       m1_axi_b_ready,

    input  [5:0] m2_axi_b_bid,
    input  [1:0] m2_axi_b_bresp,
    input        m2_axi_b_valid,
    output       m2_axi_b_ready,


    output  [3:0] s0_axi_b_bid,
    output  [1:0] s0_axi_b_bresp,
    output        s0_axi_b_valid,
    input         s0_axi_b_ready,

    output  [3:0] s1_axi_b_bid,
    output  [1:0] s1_axi_b_bresp,
    output        s1_axi_b_valid,
    input         s1_axi_b_ready,

    output  [3:0] s2_axi_b_bid,
    output  [1:0] s2_axi_b_bresp,
    output        s2_axi_b_valid,
    input         s2_axi_b_ready,


// write_data_fifo_lut 提供  主机0
    input         s0_axi_w_fifo_flush,
    input   [3:0] s0_axi_w_fifo_wid,

// write_data_fifo_lut 提供  主机1
    input         s1_axi_w_fifo_flush,
    input   [3:0] s1_axi_w_fifo_wid,

// write_data_fifo_lut 提供  主机2
    input         s2_axi_w_fifo_flush,
    input   [3:0] s2_axi_w_fifo_wid,

//write_address_decoder提供itemtable 主机0
    input   [3:0] m0_w_transactionid0,
    input   [3:0] m0_w_transactionid1,
    input   [3:0] m0_w_transactionid2,
    input   [2:0] m0_item_valid,
    input   [2:0] m0_fkflag,

//write_address_decoder提供itemtable 主机1
    input   [3:0] m1_w_transactionid0,
    input   [3:0] m1_w_transactionid1,
    input   [3:0] m1_w_transactionid2,
    input   [2:0] m1_item_valid,
    input   [2:0] m1_fkflag,

//write_address_decoder提供itemtable 主机2
    input   [3:0] m2_w_transactionid0,
    input   [3:0] m2_w_transactionid1,
    input   [3:0] m2_w_transactionid2,
    input   [2:0] m2_item_valid,
    input   [2:0] m2_fkflag,

//  清空fifo后的写返回仲裁成功正确握手 提供给write_address_arbiter
    output            s0_axi_invalid_fire,
    output            s0_axi_invalid_wid,
    output            s1_axi_invalid_fire,
    output            s1_axi_invalid_wid,
    output            s2_axi_invalid_fire,
    output            s2_axi_invalid_wid,

// 未合并的写返回，write_response中的b通道fifo提供给write_address_decoder 主机0
    output   [3:0] s0_axi_fifo_b_bid,
    output         s0_axi_fifo_b_valid,
    output         s0_axi_fifo_b_bresp, 
    output         s0_axi_fifo_b_ready,


// 未合并的写返回，write_response中的b通道fifo提供给write_address_decoder 主机1
    output   [3:0] s1_axi_fifo_b_bid,
    output         s1_axi_fifo_b_valid,
    output         s1_axi_fifo_b_bresp, 
    output         s1_axi_fifo_b_ready,

// 未合并的写返回，write_response中的b通道fifo提供给write_address_decoder  主机2
    output   [3:0] s2_axi_fifo_b_bid,
    output         s2_axi_fifo_b_valid,
    output         s2_axi_fifo_b_bresp, 
    output         s2_axi_fifo_b_ready


);



write_response m0_b(
    .clk                 (clk),
    .rst_n               (rst_n),

    .m0_axi_b_bid        (m0_axi_b_bid),
    .m0_axi_b_bresp      (m0_axi_b_bresp),
    .m0_axi_b_valid      (m0_axi_b_valid),
    .m0_axi_b_ready      (m0_axi_b_ready),

    .m1_axi_b_bid        (m1_axi_b_bid),
    .m1_axi_b_bresp      (m1_axi_b_bresp),
    .m1_axi_b_valid      (m1_axi_b_valid),
    .m1_axi_b_ready      (m1_axi_b_ready),

    .m2_axi_b_bid        (m2_axi_b_bid),
    .m2_axi_b_bresp      (m2_axi_b_bresp),
    .m2_axi_b_valid      (m2_axi_b_valid),
    .m2_axi_b_ready      (m2_axi_b_ready),

    .s_axi_index         (2'b00),                         
    .s_axi_b_bid         (s0_axi_b_bid),                         
    .s_axi_b_bresp       (s0_axi_b_bresp),                         
    .s_axi_b_valid       (s0_axi_b_valid),                         
    .s_axi_b_ready       (s0_axi_b_ready),                         

    .s_axi_w_fifo_flush  (s0_axi_w_fifo_flush),
    .s_axi_w_fifo_wid    (s0_axi_w_fifo_wid),

    .w_transactionid0    (m0_w_transactionid0),                                   
    .w_transactionid1    (m0_w_transactionid1),                                   
    .w_transactionid2    (m0_w_transactionid2),                                   
    .item_valid          (m0_item_valid),                           
    .fkflag              (m0_fkflag),   

    .fifo_pop_valid      (s0_axi_fifo_b_valid),                               
    .fifo_pop_bresp      (s0_axi_fifo_b_bresp),                              
    .fifo_pop_bid        (s0_axi_fifo_b_bid),                               
    .fifo_pop_ready      (s0_axi_fifo_b_ready),

    .s_axi_invalid_fire  (s0_axi_invalid_fire),                        
    .s_axi_invalid_wid   (s0_axi_invalid_wid)                                            

);



write_response m1_b(
    .clk                 (clk),
    .rst_n               (rst_n),

    .m0_axi_b_bid        (m0_axi_b_bid),
    .m0_axi_b_bresp      (m0_axi_b_bresp),
    .m0_axi_b_valid      (m0_axi_b_valid),
    .m0_axi_b_ready      (m0_axi_b_ready),

    .m1_axi_b_bid        (m1_axi_b_bid),
    .m1_axi_b_bresp      (m1_axi_b_bresp),
    .m1_axi_b_valid      (m1_axi_b_valid),
    .m1_axi_b_ready      (m1_axi_b_ready),

    .m2_axi_b_bid        (m2_axi_b_bid),
    .m2_axi_b_bresp      (m2_axi_b_bresp),
    .m2_axi_b_valid      (m2_axi_b_valid),
    .m2_axi_b_ready      (m2_axi_b_ready),

    .s_axi_index         (2'b01),                         
    .s_axi_b_bid         (s1_axi_b_bid),                         
    .s_axi_b_bresp       (s1_axi_b_bresp),                         
    .s_axi_b_valid       (s1_axi_b_valid),                         
    .s_axi_b_ready       (s1_axi_b_ready),                         

    .s_axi_w_fifo_flush  (s1_axi_w_fifo_flush),
    .s_axi_w_fifo_wid    (s1_axi_w_fifo_wid),

    .w_transactionid0    (m1_w_transactionid0),                                   
    .w_transactionid1    (m1_w_transactionid1),                                   
    .w_transactionid2    (m1_w_transactionid2),                                   
    .item_valid          (m1_item_valid),                           
    .fkflag              (m1_fkflag),   

    .fifo_pop_valid      (s1_axi_fifo_b_valid),                               
    .fifo_pop_bresp      (s1_axi_fifo_b_bresp),                              
    .fifo_pop_bid        (s1_axi_fifo_b_bid),                               
    .fifo_pop_ready      (s1_axi_fifo_b_ready),

    .s_axi_invalid_fire  (s1_axi_invalid_fire),                        
    .s_axi_invalid_wid   (s1_axi_invalid_wid)                                            

);


write_response m2_b(
    .clk                 (clk),
    .rst_n               (rst_n),

    .m0_axi_b_bid        (m0_axi_b_bid),
    .m0_axi_b_bresp      (m0_axi_b_bresp),
    .m0_axi_b_valid      (m0_axi_b_valid),
    .m0_axi_b_ready      (m0_axi_b_ready),

    .m1_axi_b_bid        (m1_axi_b_bid),
    .m1_axi_b_bresp      (m1_axi_b_bresp),
    .m1_axi_b_valid      (m1_axi_b_valid),
    .m1_axi_b_ready      (m1_axi_b_ready),

    .m2_axi_b_bid        (m2_axi_b_bid),
    .m2_axi_b_bresp      (m2_axi_b_bresp),
    .m2_axi_b_valid      (m2_axi_b_valid),
    .m2_axi_b_ready      (m2_axi_b_ready),

    .s_axi_index         (2'b10),                         
    .s_axi_b_bid         (s2_axi_b_bid),                         
    .s_axi_b_bresp       (s2_axi_b_bresp),                         
    .s_axi_b_valid       (s2_axi_b_valid),                         
    .s_axi_b_ready       (s2_axi_b_ready),                         

    .s_axi_w_fifo_flush  (s2_axi_w_fifo_flush),
    .s_axi_w_fifo_wid    (s2_axi_w_fifo_wid),

    .w_transactionid0    (m2_w_transactionid0),                                   
    .w_transactionid1    (m2_w_transactionid1),                                   
    .w_transactionid2    (m2_w_transactionid2),                                   
    .item_valid          (m2_item_valid),                           
    .fkflag              (m2_fkflag),   

    .fifo_pop_valid      (s2_axi_fifo_b_valid),                               
    .fifo_pop_bresp      (s2_axi_fifo_b_bresp),                              
    .fifo_pop_bid        (s2_axi_fifo_b_bid),                               
    .fifo_pop_ready      (s2_axi_fifo_b_ready),

    .s_axi_invalid_fire  (s2_axi_invalid_fire),                        
    .s_axi_invalid_wid   (s2_axi_invalid_wid)                                            

);





endmodule