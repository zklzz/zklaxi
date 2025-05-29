// 每一个从机对应三个FIFO，每个FIFO对应一个主机，
// 从机侧
module read_data_fifo(
    input clk,
    input rst_n,

    input  [ 5:0] m_axi_r_rid,
    input  [31:0] m_axi_r_rdata,
    input  [ 1:0] m_axi_r_rresp,
    input         m_axi_r_rlast,
    input         m_axi_r_valid,
    output        m_axi_r_ready,

    
    output [ 3:0] s_to_m0_axi_r_rid,
    output [31:0] s_to_m0_axi_r_rdata,
    output [ 1:0] s_to_m0_axi_r_rresp,
    output        s_to_m0_axi_r_rlast,
    output        s_to_m0_axi_r_valid,
    input         s_to_m0_axi_r_ready,

    output [ 3:0] s_to_m1_axi_r_rid,
    output [31:0] s_to_m1_axi_r_rdata,
    output [ 1:0] s_to_m1_axi_r_rresp,
    output        s_to_m1_axi_r_rlast,
    output        s_to_m1_axi_r_valid,
    input         s_to_m1_axi_r_ready,

    output [ 3:0] s_to_m2_axi_r_rid,
    output [31:0] s_to_m2_axi_r_rdata,
    output [ 1:0] s_to_m2_axi_r_rresp,
    output        s_to_m2_axi_r_rlast,
    output        s_to_m2_axi_r_valid,
    input         s_to_m2_axi_r_ready




);

    


    wire [38:0]  fifo0_push_payload;
    wire [38:0]  fifo0_pop_payload;
    wire         fifo0_push_valid;
    wire         fifo0_push_ready;
    wire         fifo0_pop_valid;
    wire         fifo0_pop_ready;

    assign fifo0_push_valid =  (m_axi_r_rid[5:4] == 2'b00);
    assign fifo0_push_payload = {m_axi_r_rid[3:0],m_axi_r_rresp,m_axi_r_rlast,m_axi_r_rdata};

    streamfifo #(.WIDTH(39),
             .DEPTH(8))
     master0_datafifo(
        .clk         (clk),
        .rst_n       (rst_n),
        .push_payload(fifo0_push_payload),
        .push_ready  (fifo0_push_ready),
        .push_valid  (fifo0_push_valid),
        .pop_payload (fifo0_pop_payload),
        .pop_ready   (fifo0_pop_ready),
        .pop_valid   (fifo0_pop_valid),
        .flush()
     );


    assign s_to_m0_axi_r_rid    = fifo0_pop_payload[38:35]; 
    assign s_to_m0_axi_r_rdata  = fifo0_pop_payload[31:0];
    assign s_to_m0_axi_r_rresp  = fifo0_pop_payload[34:33];
    assign s_to_m0_axi_r_rlast  = fifo0_pop_payload[32];
    assign s_to_m0_axi_r_valid  = fifo0_pop_valid;
    assign s_to_m0_axi_r_ready  = fifo0_pop_ready;


    wire [38:0]  fifo1_push_payload;
    wire [38:0]  fifo1_pop_payload;
    wire         fifo1_push_valid;
    wire         fifo1_push_ready;
    wire         fifo1_pop_valid;
    wire         fifo1_pop_ready;

    assign fifo1_push_valid =  (m_axi_r_rid[5:4] == 2'b01);
    assign fifo1_push_payload = {m_axi_r_rid[3:0],m_axi_r_rresp,m_axi_r_rlast,m_axi_r_rdata};

    streamfifo #(.WIDTH(39),
             .DEPTH(8))
     master1_datafifo(
        .clk         (clk),
        .rst_n       (rst_n),
        .push_payload(fifo1_push_payload),
        .push_ready  (fifo1_push_ready),
        .push_valid  (fifo1_push_valid),
        .pop_payload (fifo1_pop_payload),
        .pop_ready   (fifo1_pop_ready),
        .pop_valid   (fifo1_pop_valid),
        .flush()
     );

    assign s_to_m1_axi_r_rid    = fifo1_pop_payload[38:35]; 
    assign s_to_m1_axi_r_rdata  = fifo1_pop_payload[31:0];
    assign s_to_m1_axi_r_rresp  = fifo1_pop_payload[34:33];
    assign s_to_m1_axi_r_rlast  = fifo1_pop_payload[32];
    assign s_to_m1_axi_r_valid  = fifo1_pop_valid;
    assign s_to_m1_axi_r_ready  = fifo1_pop_ready;


    wire [38:0]  fifo2_push_payload;
    wire [38:0]  fifo2_pop_payload;
    wire         fifo2_push_valid;
    wire         fifo2_push_ready;
    wire         fifo2_pop_valid;
    wire         fifo2_pop_ready;

    assign fifo2_push_valid =  (m_axi_r_rid[5:4] == 2'b10);
    assign fifo2_push_payload = {m_axi_r_rid[3:0],m_axi_r_rresp,m_axi_r_rlast,m_axi_r_rdata};

    streamfifo #(.WIDTH(39),
             .DEPTH(8))
     master2_datafifo(
        .clk         (clk),
        .rst_n       (rst_n),
        .push_payload(fifo2_push_payload),
        .push_ready  (fifo2_push_ready),
        .push_valid  (fifo2_push_valid),
        .pop_payload (fifo2_pop_payload),
        .pop_ready   (fifo2_pop_ready),
        .pop_valid   (fifo2_pop_valid),
        .flush()
     );

    assign s_to_m2_axi_r_rid    = fifo2_pop_payload[38:35]; 
    assign s_to_m2_axi_r_rdata  = fifo2_pop_payload[31:0];
    assign s_to_m2_axi_r_rresp  = fifo2_pop_payload[34:33];
    assign s_to_m2_axi_r_rlast  = fifo2_pop_payload[32];
    assign s_to_m2_axi_r_valid  = fifo2_pop_valid;
    assign s_to_m2_axi_r_ready  = fifo2_pop_ready;







endmodule