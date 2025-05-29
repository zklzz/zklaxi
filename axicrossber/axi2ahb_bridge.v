

module axi2ahb_bridge(
    input clk,
    input rst_n,

// axi write address
    input [13:0] m_axi_aw_addr,
    input [7:0]  m_axi_aw_awlen,
    input [2:0]  m_axi_aw_awsize,
    input [1:0]  m_axi_aw_awburst,
    input [5:0]  m_axi_aw_awid,
    input        m_axi_aw_valid,
    output       m_axi_aw_ready,

// axi write data
    input  [ 5:0] m_axi_w_wid,
    input  [31:0] m_axi_w_wdata,
    input         m_axi_w_wlast,
    input  [ 3:0] m_axi_w_wstrb,
    input         m_axi_w_valid,
    output        m_axi_w_ready,


// axi write b
    output  [5:0] m_axi_b_bid,
    output  [1:0] m_axi_b_bresp,
    output        m_axi_b_valid,
    input         m_axi_b_ready,


// axi read address
    input  [13:0] m_axi_ar_addr,
    input  [7:0]  m_axi_ar_arlen,
    input  [2:0]  m_axi_ar_arsize,
    input  [1:0]  m_axi_ar_arburst,
    input  [5:0]  m_axi_ar_arid,
    input         m_axi_ar_valid,
    output        m_axi_ar_ready,

// axi read data

    output  [ 5:0] m_axi_r_rid,
    output  [31:0] m_axi_r_rdata,
    output  [ 1:0] m_axi_r_rresp,
    output         m_axi_r_rlast,
    output         m_axi_r_valid,
    input          m_axi_r_ready,

// ahb signal

    output [13:0] HADDR,
    output [2:0]  HBURST,
    output [2:0]  HSIZE,
    output [1:0]  HTRANS,
    output [31:0] HWDATA,
    output        HWRITE,
    input  [31:0] HRDATA,
    input         HREADY,
    input         HRESP  

);



    reg [2:0]  aw_valid;
    reg [5:0]  aw_wid[0:2];
    reg [13:0] aw_addr[0:2];
    reg [7:0]  aw_awlen[0:2];
    reg [1:0]  aw_awburst[0:2];
    reg [5:0]  aw_awid[0:2];
   // reg [1:0]  aw_IDgrant[0:2];
    reg [13:0] aw_wrapbegin[0:2];
    reg [13:0] aw_wrapend[0:2];
    reg [2:0]  aw_size[0:2];
    reg [2:0]  w_Done;
    reg [1:0]  w_IDgrant[0:2];

    reg fifo0_bid_valid;
    reg fifo1_bid_valid;
    reg fifo2_bid_valid;

    assign m_axi_aw_ready = &aw_valid;
    wire aw_bmatch0 = (fifo0_bid_valid && m_axi_b_ready) && (aw_valid[0] == 1'b1) && (m_axi_b_bid == aw_wid[0]) && w_Done[0];
    wire aw_bmatch1 = (fifo1_bid_valid && m_axi_b_ready) && (aw_valid[1] == 1'b1) && (m_axi_b_bid == aw_wid[1]) && w_Done[1];
    wire aw_bmatch2 = (fifo2_bid_valid && m_axi_b_ready) && (aw_valid[2] == 1'b1) && (m_axi_b_bid == aw_wid[2]) && w_Done[2];


    integer i;

// AXI端写地址数据缓冲，将outstanding的地址信息缓存下来

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            aw_valid <= 3'd0;
            for( i = 0 ; i < 3; i=i+1)  begin
                aw_wid[i]       <= 6'd0;
                aw_addr[i]      <= 14'd0;
                aw_awlen[i]     <= 8'd0;
                aw_awburst[i]   <= 2'd0;
                aw_awid[i]      <= 6'd0;
           //     aw_IDgrant[i]   <= 2'd0;
                aw_size[i]      <= 2'd0;
            end
        end
        else  begin
        if(m_axi_aw_valid && m_axi_aw_ready) begin
            casez(aw_valid) 
                3'b??0: begin
                        aw_valid[0]         <= 1'b1;
                        aw_wid[0]           <= m_axi_aw_awid;
                        aw_addr[0]          <= m_axi_aw_addr;
                        aw_awlen[0]         <= m_axi_aw_awlen;
                        aw_awburst[0]       <= m_axi_aw_awburst;
                        aw_awid[0]          <= m_axi_aw_awid;
                        aw_size[0]          <= m_axi_aw_awsize;
                end
                3'b?01: begin
                        aw_valid[1]         <= 1'b1;
                        aw_wid[1]           <= m_axi_aw_awid;
                        aw_addr[1]          <= m_axi_aw_addr;
                        aw_awlen[1]         <= m_axi_aw_awlen;
                        aw_awburst[1]       <= m_axi_aw_awburst;
                        aw_awid[1]          <= m_axi_aw_awid;
                        aw_size[1]          <= m_axi_aw_awsize;
                end
                3'b011: begin
                        aw_valid[2]         <= 1'b1;
                        aw_wid[2]           <= m_axi_aw_awid;
                        aw_addr[2]          <= m_axi_aw_addr;
                        aw_awlen[2]         <= m_axi_aw_awlen;
                        aw_awburst[2]       <= m_axi_aw_awburst;
                        aw_awid[2]          <= m_axi_aw_awid;
                        aw_size[2]          <= m_axi_aw_awsize;
                end
            endcase
        end
        if(aw_bmatch0) 
            aw_valid[0] <= 1'b0;
        else if(aw_bmatch1)
            aw_valid[1] <= 1'b0;
        else if(aw_bmatch2)
            aw_valid[2] <= 1'b0;
        end      
    end

// AXI 回环突发传输只能是2,4,8,16,但AHB回环突发传输只能是4，8,16
    always @(*) begin
        for(i = 0; i< 3 ; i= i + 1) begin
            aw_wrapbegin[i] = (aw_awburst[i] == 2'b10)? ((aw_addr[i] >> (aw_size[i]+aw_awlen[i][0]+aw_awlen[i][1]+aw_awlen[i][2]+aw_awlen[i][3])) << (aw_size[i]+aw_awlen[i][0]+aw_awlen[i][1]+aw_awlen[i][2]+aw_awlen[i][3]))  : aw_wrapbegin[i];
            aw_wrapend[i] = aw_wrapbegin[i] + ((aw_awlen[i] + 1) << aw_size[i]);
        end
    end










//w 和 aw通道合并，这里默认地址先握手再数据握手，crossbar就是先给地址再给数据，从机断端
//由于crossbar的处理，同一ID一定是地址握手后，数据传输完,有写返回后再进行第二次同一id的地址握手
// fifo对应的是写地址握手的项的id，根据这id将写数据通道对应的数据写入

   // reg [2:0]  w_valid;
   // reg [5:0]  w_wid[0:2];



    wire table0match = (aw_valid[0] == 1) && (aw_wid[0] == m_axi_w_wid) && (w_Done[0] == 0);
    wire table1match = (aw_valid[1] == 1) && (aw_wid[1] == m_axi_w_wid) && (w_Done[1] == 0);
    wire table2match = (aw_valid[2] == 1) && (aw_wid[2] == m_axi_w_wid) && (w_Done[2] == 0);



    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            w_Done <= 3'd0;
        end
        else  begin
        if(m_axi_w_valid && m_axi_w_ready && m_axi_w_wlast) begin
            if(table0match)
                w_Done[0] <= 1'b1;
            else if(table1match)
                w_Done[1] <= 1'b1;
            else if(table2match)
                w_Done[2] <= 1'b1;
        end
        if(aw_bmatch0) 
            w_Done[0] <= 1'b0;
        else if(aw_bmatch1)
            w_Done[1] <= 1'b0;
        else if(aw_bmatch2)
            w_Done[2] <= 1'b0;


        end
    end


  



 
    reg [31:0] fifo_push_payload_wdata;

    wire [31:0] fifo_push_payload;
    assign fifo_push_payload = fifo_push_payload_wdata;
    

    wire fifo0_push_valid;
    wire fifo0_push_ready;
    wire fifo1_push_valid;
    wire fifo1_push_ready;
    wire fifo2_push_valid;
    wire fifo2_push_ready;   


    assign m_axi_w_ready = table0match || table1match || table2match;

    assign fifo0_push_valid = (m_axi_w_valid && m_axi_w_ready) && table0match;
    assign fifo1_push_valid = (m_axi_w_valid && m_axi_w_ready) && table1match;
    assign fifo2_push_valid = (m_axi_w_valid && m_axi_w_ready) && table2match;
    






    always@(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
            fifo_push_payload_wdata <= 32'd0;
        end
        else if (m_axi_w_valid && m_axi_w_ready) begin
            fifo_push_payload_wdata <= m_axi_w_wdata;
        end
    end

    
    
    wire [7:0]  fifo0_num;
    wire [7:0]  fifo1_num;
    wire [7:0]  fifo2_num;

    

    streamfifo #(.WIDTH(32),
                 .DEPTH(256))
         wdatafifo0(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo0_push_ready),
            .push_valid(fifo0_push_valid),
            .pop_payload(fifo0_pop_payload),
            .pop_ready(fifo0_pop_ready),
            .pop_valid(fifo0_pop_valid),
            .flush(),
            .wr_num(fifo0_num)
         );



    streamfifo #(.WIDTH(32),
                 .DEPTH(256))
         wdatafifo1(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo1_push_ready),
            .push_valid(fifo1_push_valid),
            .pop_payload(fifo1_pop_payload),
            .pop_ready(fifo1_pop_ready),
            .pop_valid(fifo1_pop_valid),
            .flush(),
            .wr_num(fifo1_num)
         );



    streamfifo #(.WIDTH(32),
                 .DEPTH(256))
         wdatafifo2(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo2_push_ready),
            .push_valid(fifo2_push_valid),
            .pop_payload(fifo2_pop_payload),
            .pop_ready(fifo2_pop_ready),
            .pop_valid(fifo2_pop_valid),
            .flush(),
            .wr_num(fifo2_num)
         );



// 发起突发写条件
/*nonseq_req: (1) AXI传输模式为FIXED（axburst == 2‘b00）

（2）AXI传输模式为INCR（ axburst == 2‘b01），但此时已经wlast了，但是写数据fifo中数据量小于8,或者此时进行突发传输，会跨过1k边界

（3）AXI传输模式为WRAP( axburst == 2‘b10) ,但突发长度为2，AHB只支持4,8，16的回环传输

burst_req: AXI传输模式为INCR（ axburst == 2‘b01），且写数据fifo中数据量大于8，并且不会跨越1k边界

wrap_req：AXI传输模式为WRAP( axburst == 2‘b10) ,但突发长度为4,8,16
*/



    reg [13:0] wr0_addr_d,wr1_addr_d,wr2_addr_d, wr0_addr_q,wr1_addr_q,wr2_addr_q;

    wire fifo0_wr_req_burst = (aw_valid[0] && (fifo0_num>=8)) && (aw_awburst[0] == 2'b01) && (11'd1024 - wr0_addr_d[9:0] >= 8);
    wire fifo0_wr_req_nonseq = (aw_valid[0] && (fifo0_num<8) && w_Done[0] && (aw_awburst[0] == 2'b01)) || (aw_valid[0] && (aw_awburst[0] == 2'b00) && (fifo0_pop_valid)) || (aw_valid[0] && (aw_awburst[0] == 2'b10) && (fifo0_pop_valid) && (aw_awlen[0] == 'd1)) || ((aw_valid[0] && (fifo0_num>=8)) && (aw_awburst[0] == 2'b01) && (11'd1024 - wr0_addr_d[9:0] < 8));
    wire fifo0_wr_req_wrap  = (aw_valid[0] && (aw_awburst[0] == 2'b10) && w_Done[0] && (aw_awlen[0] != 'd1));

    wire fifo1_wr_req_burst = (aw_valid[1] && (fifo1_num>=8)) && (aw_awburst[1] == 2'b01) && (11'd1024 - wr1_addr_d[9:0] >= 8);
    wire fifo1_wr_req_nonseq = (aw_valid[1] && (fifo1_num<8) && w_Done[1] && (aw_awburst[1] == 2'b01)) || (aw_valid[1] && (aw_awburst[1] == 2'b00) && (fifo1_pop_valid)) || (aw_valid[1] && (aw_awburst[1] == 2'b10) && (fifo1_pop_valid) && (aw_awlen[1] == 'd1)) || ((aw_valid[1] && (fifo1_num>=8)) && (aw_awburst[1] == 2'b01) && (11'd1024 - wr1_addr_d[9:0] < 8));
    wire fifo1_wr_req_wrap  = (aw_valid[1] && (aw_awburst[1] == 2'b10) && w_Done[1] && (aw_awlen[1] != 'd1));



    wire fifo2_wr_req_burst = (aw_valid[2] && (fifo2_num>=8)) && (aw_awburst[2] == 2'b01) && (11'd1024 - wr2_addr_d[9:0] >= 8);
    wire fifo2_wr_req_nonseq = (aw_valid[2] && (fifo2_num<8) && w_Done[2] && (aw_awburst[2] == 2'b01)) || (aw_valid[2] && (aw_awburst[2] == 2'b00) && (fifo2_pop_valid)) || (aw_valid[2] && (aw_awburst[2] == 2'b10) && (fifo2_pop_valid) && (aw_awlen[2] == 'd1)) || ((aw_valid[2] && (fifo2_num>=8)) && (aw_awburst[2] == 2'b01) && (11'd1024 - wr2_addr_d[9:0] < 8));
    wire fifo2_wr_req_wrap  = (aw_valid[2] && (aw_awburst[2] == 2'b10) && w_Done[2] && (aw_awlen[2] != 'd1));


    wire wr_req_burst = fifo0_wr_req_burst || fifo1_wr_req_burst || fifo2_wr_req_burst;
    wire wr_req_nonseq = fifo0_wr_req_nonseq || fifo1_wr_req_nonseq || fifo2_wr_req_nonseq;
    wire wr_req_wrap = fifo0_wr_req_wrap || fifo1_wr_req_wrap || fifo2_wr_req_wrap;

    wire wr_req = wr_req_burst || wr_req_nonseq || wr_req_wrap;


// AXI读通道数据， 这里考虑用fifo来存取读事务，只执行fifo首的事务，执行完再给下一个事务

    wire [32:0]ar_fifo_push_payload = {m_axi_ar_addr, m_axi_ar_arlen,m_axi_ar_arsize,m_axi_ar_arburst,m_axi_ar_arid};
    wire ar_fifo_push_valid;
    wire ar_fifo_push_ready;

    wire [32:0] ar_fifo_pop_payload;
    wire ar_fifo_pop_valid;
    wire ar_fifo_pop_ready;

    wire [5:0] fifo_pop_arid = ar_fifo_pop_payload[5:0];
    wire [1:0] fifo_pop_arburst = ar_fifo_pop_payload[7:6];
    wire [2:0] fifo_pop_arsize  = ar_fifo_pop_payload[10:8];
    wire [7:0] fifo_pop_arlen  = ar_fifo_pop_payload[18:11];
    wire [13:0] fifo_pop_araddr = ar_fifo_pop_payload[32:19];


    reg [13:0] rd_wrapbegin,rd_wrapend;
    always @(*) begin
        rd_wrapbegin = fifo_pop_arburst ? ((fifo_pop_araddr >> (fifo_pop_arsize + fifo_pop_arlen[0] + fifo_pop_arlen[1] +fifo_pop_arlen[2] +fifo_pop_arlen[3])) << (fifo_pop_arsize + fifo_pop_arlen[0] + fifo_pop_arlen[1] +fifo_pop_arlen[2] +fifo_pop_arlen[3])) : rd_wrapbegin;
        rd_wrapend   = rd_wrapbegin + ((fifo_pop_arlen + 1) << fifo_pop_arsize);
    end

        streamfifo #(.WIDTH(33),
                 .DEPTH(8))
         addrfifo2(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(ar_fifo_push_payload),
            .push_ready(ar_fifo_push_ready),
            .push_valid(ar_fifo_push_valid),
            .pop_payload(ar_fifo_pop_payload),
            .pop_ready(ar_fifo_pop_ready),
            .pop_valid(ar_fifo_pop_valid)
         );

    reg [1:0] ar_tran_count;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            ar_tran_count <= 2'd0;
        else if(m_axi_ar_valid && m_axi_ar_ready)
            ar_tran_count <= ar_tran_count + 1;
        else if(m_axi_r_valid && m_axi_r_ready && m_axi_r_rlast) 
            ar_tran_count <= ar_tran_count - 1;
    end

    assign m_axi_ar_ready = (ar_tran_count < 3);

// 发起读请求
    wire ar_req = ar_fifo_pop_valid; 



//状态机
    localparam IDLE = 4'b0000;

    localparam WRITE0_BURST = 4'b0010;
    localparam WRITE0_NONSEQ = 4'b0011;
    localparam WRITE0_WRAP = 4'b0100;

    localparam WRITE1_BURST = 4'b0101;
    localparam WRITE1_NONSEQ = 4'b0110;
    localparam WRITE1_WRAP = 4'b0111;

    localparam WRITE2_BURST = 4'b1000;
    localparam WRITE2_NONSEQ = 4'b1001;
    localparam WRITE2_WRAP = 4'b1010;

    localparam READ  = 4'b1011;
    localparam READ_BURST =  4'b1100;
    localparam READ_NONSEQ = 4'b1101;
    localparam READ_WRAP  = 4'b1110;



    reg [3:0] state,next_state;


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state <= IDLE;
        else 
            state <= next_state;
    end

    wire wr_bur_end,wr_wrap_end,rd_end;





//由于ahb流水，这里让addr是组合信号，并且由case next_state来判断
//而data为时序逻辑，也由case next_state来判断 ，这样可以延迟一拍
// 不同状态的切换必须有HREADY条件, nonseq必须有判断条件axlen！=0




    always@(*) begin
        wr0_addr_d = wr0_addr_q;
        case(state)
            WRITE0_BURST :  begin
                if( HREADY)
                    wr0_addr_d = wr0_addr_q + (1 <<aw_size[0]) ;
            end
            WRITE0_NONSEQ: begin
                if(HREADY) begin
                    if((aw_awburst[0] == 2'b10) && ((wr0_addr_q + (1 <<aw_size[0])) == aw_wrapend[0]))
                        wr0_addr_d  = aw_wrapbegin[0];
                    else
                        wr0_addr_d = wr0_addr_q + (1 <<aw_size[0]);
                end
            end
            WRITE0_WRAP: begin
                if(HREADY) begin
                    if((wr0_addr_q + (1 <<aw_size[0])) == aw_wrapend[0])
                        wr0_addr_d  = aw_wrapbegin[0];
                    else
                        wr0_addr_d = wr0_addr_q + (1 <<aw_size[0]);
                end
            end
        endcase

    end
    always@(posedge clk or negedge rst_n ) begin
        if(!rst_n) 
            wr0_addr_q <= 14'd0;
        else if((m_axi_aw_valid && m_axi_aw_ready) && (!aw_valid[0]))
            wr0_addr_q <= m_axi_aw_addr;
        else 
            wr0_addr_q <= wr0_addr_d;
    end





    always@(*) begin
        wr1_addr_d = wr1_addr_q;
        case(state)
            WRITE1_BURST :  begin
                if( HREADY)
                    wr1_addr_d = wr1_addr_q + (1 <<aw_size[1]) ;
            end
            WRITE1_NONSEQ: begin
                if(HREADY) begin
                    if((aw_awburst[1] == 2'b10) && ((wr1_addr_q + (1 <<aw_size[1])) == aw_wrapend[1]))
                        wr1_addr_d  = aw_wrapbegin[1];
                    else
                        wr1_addr_d = wr1_addr_q + (1 <<aw_size[1]);
                end
            end
            WRITE1_WRAP: begin
                if(HREADY) begin
                    if((wr1_addr_q + (1 <<aw_size[1])) == aw_wrapend[1])
                        wr1_addr_d  = aw_wrapbegin[1];
                    else
                        wr1_addr_d = wr1_addr_q + (1 <<aw_size[1]);
                end
            end
        endcase

    end

    always@(posedge clk or negedge rst_n ) begin
        if(!rst_n) 
            wr1_addr_q <= 14'd0;
        else if((m_axi_aw_valid && m_axi_aw_ready) && (!aw_valid[1]))
            wr1_addr_q <= m_axi_aw_addr;
        else 
            wr1_addr_q <= wr1_addr_d;
    end





    
    always@(*) begin
        wr2_addr_d = wr2_addr_q;
        case(state)
            WRITE2_BURST :  begin
                if( HREADY)
                    wr2_addr_d = wr2_addr_q + (1 <<aw_size[2]) ;
            end
            WRITE2_NONSEQ: begin
                if(HREADY) begin
                    if((aw_awburst[2] == 2'b10) && ((wr2_addr_q + (1 <<aw_size[2])) == aw_wrapend[2]))
                        wr2_addr_d  = aw_wrapbegin[2];
                    else
                        wr2_addr_d = wr2_addr_q + (1 <<aw_size[2]);
                end
            end
            WRITE2_WRAP: begin
                if(HREADY) begin
                    if((wr2_addr_q + (1 <<aw_size[2])) == aw_wrapend[2])
                        wr2_addr_d  = aw_wrapbegin[2];
                    else
                        wr2_addr_d = wr2_addr_q + (1 <<aw_size[2]);
                end
            end
        endcase

    end


    always@(posedge clk or negedge rst_n ) begin
        if(!rst_n) 
            wr2_addr_q <= 14'd0;
        else if((m_axi_aw_valid && m_axi_aw_ready) && (!aw_valid[2]))
            wr2_addr_q <= m_axi_aw_addr;
        else 
            wr2_addr_q <= wr2_addr_d;
    end


    reg wr0_resp,wr1_resp,wr2_resp;

    reg [31:0] hwdata;
    assign fifo0_pop_ready = ((state == WRITE0_BURST) || (state == WRITE0_NONSEQ) || (state == WRITE0_WRAP)) && HREADY;
    assign fifo1_pop_ready = ((state == WRITE1_BURST) || (state == WRITE1_NONSEQ) || (state == WRITE1_WRAP)) && HREADY;
    assign fifo2_pop_ready = ((state == WRITE2_BURST) || (state == WRITE2_NONSEQ) || (state == WRITE2_WRAP)) && HREADY;

//hwdata
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            hwdata <= 32'd0;
        else begin
            case(next_state) 
                WRITE0_BURST : hwdata <= fifo0_pop_payload;
                WRITE0_NONSEQ: hwdata <= fifo0_pop_payload;
                WRITE0_WRAP:   hwdata <= fifo0_pop_payload;

                WRITE1_BURST : hwdata <= fifo1_pop_payload;
                WRITE1_NONSEQ: hwdata <= fifo1_pop_payload;
                WRITE1_WRAP:   hwdata <= fifo1_pop_payload;

                WRITE2_BURST : hwdata <= fifo2_pop_payload;
                WRITE2_NONSEQ: hwdata <= fifo2_pop_payload;
                WRITE2_WRAP:   hwdata <= fifo2_pop_payload;
                default:       hwdata <= 32'd0;
        endcase
        end
    end

// 写响应需要记录每次返回的HRESP，如果有一次传输错误，整个写事务都是错误的，完成传输再发送AXI B(SLAVE error)
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            wr0_resp <= 1'b0;
        else if((m_axi_aw_valid && m_axi_aw_ready) && (!aw_valid[0]))
            wr0_resp <= 1'b0;
        else begin
            case(state) 
                WRITE0_BURST : if(HREADY)
                                 wr0_resp <= wr0_resp && HRESP;
                WRITE0_NONSEQ: if(HREADY)
                                 wr0_resp <= wr0_resp && HRESP;
                WRITE0_WRAP:   if(HREADY)
                                 wr0_resp <= wr0_resp && HRESP;
                default:       wr0_resp <= wr0_resp;
        endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            wr1_resp <= 1'b0;
        else if((m_axi_aw_valid && m_axi_aw_ready) && (!aw_valid[0]))
            wr1_resp <= 1'b0;
        else begin
            case(state) 
                WRITE0_BURST : if(HREADY)
                                 wr1_resp <= wr1_resp && HRESP;
                WRITE0_NONSEQ: if(HREADY)
                                 wr1_resp <= wr1_resp && HRESP;
                WRITE0_WRAP:   if(HREADY)
                                 wr1_resp <= wr1_resp && HRESP;
                default:       wr1_resp <= wr1_resp;
        endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            wr2_resp <= 1'b0;
        else if((m_axi_aw_valid && m_axi_aw_ready) && (!aw_valid[0]))
            wr2_resp <= 1'b0;
        else begin
            case(state) 
                WRITE0_BURST : if(HREADY)
                                 wr2_resp <= wr2_resp && HRESP;
                WRITE0_NONSEQ: if(HREADY)
                                 wr2_resp <= wr2_resp && HRESP;
                WRITE0_WRAP:   if(HREADY)
                                 wr2_resp <= wr2_resp && HRESP;
                default:       wr2_resp <= wr2_resp;
        endcase
        end
    end


    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fifo0_bid_valid <= 1'b0;
        else if(aw_valid[0] && (aw_awlen[0]== 'd0) && w_Done[0] && fifo0_pop_valid)
            fifo0_bid_valid <= 1'b1;
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fifo1_bid_valid <= 1'b0;
        else if(aw_valid[1] && (aw_awlen[1]== 'd0) && w_Done[1] && fifo1_pop_valid)
            fifo1_bid_valid <= 1'b1;
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fifo2_bid_valid <= 1'b0;
        else if(aw_valid[2] && (aw_awlen[2]== 'd0) && w_Done[2] && fifo2_pop_valid)
            fifo2_bid_valid <= 1'b1;
    end


// axi  b 通道
    reg [1:0] b_bresp;
    reg [5:0] b_bid;
    reg lock;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            lock <= 1'b0;
        else if((m_axi_b_valid) && !m_axi_b_ready)
            lock <= 1'b1;
        else if(m_axi_b_ready)
            lock <= 1'b0;
    end

    always @(*) begin
        if(fifo0_bid_valid)
            b_bresp = {wr0_resp,1'b0};
        else if(fifo1_bid_valid)
            b_bresp = {wr1_resp,1'b0};
        else if(fifo2_bid_valid)
            b_bresp = {wr2_resp,1'b0};
    end

    always @(*) begin
        if(fifo0_bid_valid)
            b_bid = aw_wid[0];
        else if(fifo1_bid_valid)
            b_bid = aw_wid[1];
        else if(fifo2_bid_valid)
            b_bid = aw_wid[2];
    end
    
    assign m_axi_b_valid = fifo0_bid_valid || fifo1_bid_valid || fifo2_bid_valid;


    assign m_axi_b_bresp = lock? m_axi_b_bresp : b_bresp;
    assign m_axi_b_bid = lock? m_axi_b_bid : b_bid;

// 写事务的剩余len记录
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for( i = 0 ; i < 3; i=i+1)  begin
                aw_awlen[i]     <= 8'd0;
            end
        end
        else  begin
        if(m_axi_aw_valid && m_axi_aw_ready) begin
            casez(aw_valid) 
                3'b??0: begin
                        aw_awlen[0]         <= m_axi_aw_awlen;
                end
                3'b?01: begin
                        aw_awlen[1]         <= m_axi_aw_awlen;
                end
                3'b011: begin
                        aw_awlen[2]         <= m_axi_aw_awlen;
                end
            endcase
        end
        case(state)
                WRITE0_BURST : if(HREADY)
                                 aw_awlen[0] <= aw_awlen[0] - 1'd1;
                WRITE0_NONSEQ: if(HREADY)
                                 aw_awlen[0] <= aw_awlen[0] - 1'd1;
                WRITE0_WRAP:   if(HREADY)
                                 aw_awlen[0] <= aw_awlen[0] - 1'd1;

                WRITE1_BURST : if(HREADY)
                                 aw_awlen[1] <= aw_awlen[1] - 1'd1;
                WRITE1_NONSEQ: if(HREADY)
                                 aw_awlen[1] <= aw_awlen[1] - 1'd1;
                WRITE1_WRAP:   if(HREADY)
                                 aw_awlen[1] <= aw_awlen[1] - 1'd1;

                WRITE2_BURST : if(HREADY)
                                 aw_awlen[2] <= aw_awlen[2] - 1'd1;
                WRITE2_NONSEQ: if(HREADY)
                                 aw_awlen[2] <= aw_awlen[2] - 1'd1;
                WRITE2_WRAP:   if(HREADY)
                                 aw_awlen[2] <= aw_awlen[2] - 1'd1;

                default: begin 
                            aw_awlen[0] <= aw_awlen[0];
                            aw_awlen[1] <= aw_awlen[1];
                            aw_awlen[2] <= aw_awlen[2];
                end
        endcase 
    end
    end



// 读事务读len记录
    reg [7:0] rd_len;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rd_len <= 8'd0;
        else if(next_state == READ)
            rd_len <= fifo_pop_arlen;
        else begin
            case(state)  
                READ_BURST: if(HREADY)
                               rd_len <=  rd_len - 'd1;
                READ_NONSEQ: if(HREADY)
                               rd_len <=  rd_len - 'd1;
                READ_WRAP: if(HREADY)
                               rd_len <=  rd_len - 'd1;
                default : rd_len <= rd_len;
            endcase
        end
    end

    reg [13:0] rd_addr_d,rd_addr_q;


// ahb 读地址计算
    always@(*) begin
        rd_addr_d = rd_addr_q;
        case(state) 
            READ: rd_addr_d = fifo_pop_araddr;
            READ_BURST: begin
                        if(HREADY)
                            rd_addr_d = rd_addr_q + (1<<fifo_pop_arsize);
            end
            READ_NONSEQ: begin
                        if(HREADY)
                            if((fifo_pop_arburst == 2'b10) && ((rd_addr_d + ( 1<< fifo_pop_arsize)) == rd_wrapend))
                                rd_addr_d = rd_wrapbegin;
                            else
                                rd_addr_d = rd_addr_q + (1<<fifo_pop_arsize);
            end
            READ_WRAP: begin
                        if(HREADY) begin 
                            if((rd_addr_d + ( 1<< fifo_pop_arsize)) == rd_wrapend )
                                rd_addr_d = rd_wrapbegin;
                            else 
                                rd_addr_d = rd_addr_q + (1<<fifo_pop_arsize);
                        end
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rd_addr_q <= 14'd0;
        else 
            rd_addr_q <= rd_addr_d;
    end

 // read data axi out   

    wire [40:0] r_fifo_push_payload;
    wire [40:0] r_fifo_pop_payload;



    wire r_fifo_push_valid;
    wire r_fifo_push_ready;

    wire hdata_last;
    wire r_fifo_pop_valid;
    wire r_fifo_pop_ready;



    assign r_fifo_push_valid = ((state == READ_BURST) || (state == READ_NONSEQ) || (state == READ_WRAP)) && HREADY;

    assign r_fifo_push_payload = {hdata_last,{HRESP,1'b0},HRDATA,fifo_pop_arid};


    assign hdata_last = ((state == READ_BURST) || (state == READ_NONSEQ) || (state == READ_WRAP)) && HREADY && (rd_len == 'd0); 
    
    streamfifo #(.WIDTH(41),
                 .DEPTH(8))
         rdataout(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(r_fifo_push_payloadd),
            .push_ready(r_fifo_push_ready),
            .push_valid(r_fifo_push_valid),
            .pop_payload(r_fifo_pop_payload),
            .pop_ready(r_fifo_pop_ready),
            .pop_valid(r_fifo_pop_valid)
         );

     assign m_axi_r_rid = r_fifo_pop_payload[5:0];
     assign m_axi_r_rdata = r_fifo_pop_payload[37:6];
     assign m_axi_r_rresp = r_fifo_pop_payload[39:38];
     assign m_axi_r_rlast = r_fifo_pop_payload[40];
     assign m_axi_r_valid = r_fifo_pop_valid;
     assign m_axi_r_ready = r_fifo_pop_ready;


// 突发传输，回环传输  状态切换

    reg [2:0] wr_burst_count;
    reg [2:0] rd_burst_count;
    reg [3:0] wr_wrap_count;
    reg [3:0] rd_wrap_count;


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            wr_burst_count <= 3'd0;
        else if(((state == WRITE0_BURST) || (state == WRITE1_BURST) || (state == WRITE2_BURST)) && HREADY)
            wr_burst_count <= wr_burst_count + 1'd1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rd_burst_count <= 3'd0;
        else if((state == READ_BURST) && HREADY)
            rd_burst_count <= rd_burst_count + 1'd1;
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            wr_wrap_count <= 4'd0;
        else begin
            if((state != WRITE0_WRAP) && (next_state == WRITE0_WRAP))
                wr_wrap_count <= aw_awlen[0];
            else if((state == WRITE0_WRAP) && HREADY)
                wr_wrap_count <= wr_wrap_count - 1'd1;
            if((state != WRITE1_WRAP) && (next_state == WRITE1_WRAP))
                wr_wrap_count <= aw_awlen[1];
            else if((state == WRITE1_WRAP) && HREADY )
                wr_wrap_count <= wr_wrap_count - 1'd1;
            if((state != WRITE1_WRAP) && (next_state == WRITE1_WRAP))
                wr_wrap_count <= aw_awlen[2];
            else if((state == WRITE1_WRAP) && HREADY)
                wr_wrap_count <= wr_wrap_count - 1'd1;
        end
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            rd_wrap_count <= 4'd0;
        else if((state != READ_WRAP) && (next_state == READ_WRAP))
            rd_wrap_count <= fifo_pop_arlen;
        else if((state == READ_WRAP) && HREADY)
            rd_wrap_count <= rd_wrap_count - 1'd1;
    end


  // 状态机状态切换  
  /*整体优先级如下：

IDLE状态下： WRITE0>WRITE1>WRITE2>READ

WRITE0包含3个状态机，WRITE0_BURST、WRITE0_WRAP、WRITE0_NONSEQ，其余两个类比

会根据发起写事务进入对应的状态，且在当前fifo发起状态下，会优先继续执行当前fifo下发起的其他请求，具体如下：如果进入WRITE0_BURST，执行完突发传输后，fifo0还是满足发起读请求，那么将继续执行，一直执行到fifo0不满足发起读请求了。

当结束当前写fifo状态时，会先判断是否有读请求，有的话，进入READ状态，不然进入IDLE状态，也就是说WRITE0，WRITE1，WRITE2之间不会直接切换*/
    always @(*) begin

        case(state) 
            IDLE:  begin
                    if(fifo0_wr_req_burst)
                        next_state = WRITE0_BURST;
                    else if(fifo0_wr_req_wrap)
                        next_state = WRITE0_WRAP;
                    else if(fifo0_wr_req_nonseq)
                        next_state = WRITE0_NONSEQ;

                    else if(fifo1_wr_req_burst)
                        next_state = WRITE1_BURST;
                    else if(fifo1_wr_req_wrap)
                        next_state = WRITE1_WRAP;
                    else if(fifo1_wr_req_nonseq)
                        next_state = WRITE1_NONSEQ;
                        
                    else if(fifo2_wr_req_burst)
                        next_state = WRITE2_BURST;
                    else if(fifo2_wr_req_wrap)
                        next_state = WRITE2_WRAP;
                    else if(fifo2_wr_req_nonseq)
                        next_state = WRITE2_NONSEQ;
                    
                    else if(ar_req)
                        next_state = READ;
            end
                    
            WRITE0_BURST: begin 
                        if((wr_burst_count == 3'b111) && HREADY) begin
                            if(fifo0_wr_req_burst)
                                next_state = WRITE0_BURST;
                            else if(fifo0_wr_req_nonseq)
                                next_state = WRITE0_NONSEQ;
                            else if(ar_req)
                                next_state = READ;
                            else
                                next_state = IDLE;
                            end
                          else 
                                next_state = WRITE0_BURST;
            end
            WRITE0_WRAP: begin
                        if((wr_wrap_count == 'd0) && HREADY) begin
                            if(ar_req)
                                next_state = READ;
                            else 
                                next_state = IDLE;
                            end
                          else 
                            next_state = WRITE0_WRAP;
            end
            WRITE0_NONSEQ: begin
                        if(HREADY) begin
                            if(fifo0_wr_req_nonseq)
                                next_state = WRITE0_NONSEQ;
                            else if(ar_req)
                                next_state = READ;
                            else
                                next_state = IDLE;
                            end
                           else
                            next_state = WRITE0_NONSEQ;
            end

            WRITE1_BURST: begin
                        if((wr_burst_count == 3'b111) && HREADY) begin
                            if(fifo1_wr_req_burst)
                                next_state = WRITE1_BURST;
                            else if(fifo1_wr_req_nonseq)
                                next_state = WRITE1_NONSEQ;
                            else if(ar_req)
                                next_state = READ;
                            else
                                next_state = IDLE;
                            end
                          else 
                                next_state = WRITE1_BURST;
            end
            WRITE1_WRAP: begin
                        if((wr_wrap_count == 'd0) && HREADY) begin
                            if(ar_req)
                                next_state = READ;
                            else 
                                next_state = IDLE;
                            end
                          else 
                            next_state = WRITE1_WRAP;
            end
            WRITE1_NONSEQ: begin
                        if(HREADY) begin
                            if(fifo1_wr_req_burst)
                                next_state = WRITE1_BURST;
                            else if(fifo1_wr_req_nonseq)
                                next_state = WRITE1_NONSEQ;
                            else if(ar_req)
                                next_state = READ;
                            else
                                next_state = IDLE;
                            end
                           else
                            next_state = WRITE1_NONSEQ;
            end

            WRITE2_BURST: begin
                        if((wr_burst_count == 3'b111) && HREADY) begin
                            if(fifo2_wr_req_burst)
                                next_state = WRITE2_BURST;
                            else if(fifo2_wr_req_nonseq)
                                next_state = WRITE2_NONSEQ;
                            else if(ar_req)
                                next_state = READ;
                            else
                                next_state = IDLE;
                            end
                          else 
                                next_state = WRITE2_BURST;
            end
            WRITE2_WRAP: begin
                         if((wr_wrap_count == 'd0) && HREADY) begin
                            if(ar_req)
                                next_state = READ;
                            else 
                                next_state = IDLE;
                            end
                          else 
                            next_state = WRITE2_WRAP;
            end
            WRITE2_NONSEQ: begin
                         if(HREADY) begin
                            if(fifo2_wr_req_burst)
                                next_state = WRITE2_BURST;
                            else if(fifo2_wr_req_nonseq)
                                next_state = WRITE2_NONSEQ;
                            else if(ar_req)
                                next_state = READ;
                            else
                                next_state = IDLE;
                            end
                        else
                            next_state = WRITE2_NONSEQ;
            end

            READ: begin
                 if((rd_len >= 8'd8) && (fifo_pop_arburst == 2'b01) && (11'd1024 - rd_addr_d[9:0] >= 8))
                    next_state = READ_BURST;
                  else if((rd_len > 8'd1) && (fifo_pop_arburst == 2'b10))
                    next_state = READ_WRAP;
                  else 
                    next_state = READ_NONSEQ;
            end

            READ_BURST: begin
                 if((rd_burst_count == 3'b111) && HREADY) begin 
                    if((rd_len >= 8'd8) && (11'd1024 - rd_addr_d[9:0] >= 8))
                       next_state = READ_BURST;
                    else if(rd_len!= 'd0)
                       next_state = READ_NONSEQ;
                    else 
                       next_state = IDLE;
                end
                else 
                    next_state = READ_BURST;
                    
            end

            READ_BURST: begin
                 if(HREADY) begin
                    if((rd_len >= 8'd8) && (11'd1024 - rd_addr_d[9:0] >= 8))
                       next_state = READ_BURST;
                    else if(rd_len!= 'd0)
                       next_state = READ_NONSEQ;
                    else 
                       next_state = IDLE;
                 end
                 else 
                    next_state = READ_NONSEQ;
            end

            READ_WRAP:begin
                 if((rd_wrap_count == 'd0) && HREADY) 
                        next_state = IDLE;
                  else 
                    next_state = READ_WRAP;
            end

            default: next_state = IDLE;
                
        endcase

    end


// haddr
    reg [13:0] h_addr;

    always@(*) begin
        case(next_state)
            WRITE0_BURST:   h_addr = wr0_addr_d;
            WRITE0_NONSEQ: h_addr = wr0_addr_d;
            WRITE0_WRAP:    h_addr = wr0_addr_d;

            WRITE1_BURST:   h_addr = wr1_addr_d;
            WRITE1_NONSEQ:  h_addr = wr1_addr_d;
            WRITE1_WRAP:    h_addr = wr1_addr_d;

            WRITE2_BURST:   h_addr = wr2_addr_d;
            WRITE2_NONSEQ:  h_addr = wr2_addr_d;
            WRITE2_WRAP:    h_addr = wr2_addr_d;

            READ_BURST:     h_addr = rd_addr_d;
            READ_NONSEQ:    h_addr = rd_addr_d;
            READ_WRAP:      h_addr = rd_addr_d;
            default:        h_addr = 'd0;

        endcase
    end

// htrans
    reg [1:0] h_trans;

    always@(*) begin
        if(HREADY && HRESP)
            h_trans = 2'b00;
        else begin
        case(next_state)
            WRITE0_BURST: begin
                            if((state == IDLE) || ((wr_burst_count == 3'b111) && HREADY))
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            WRITE0_NONSEQ: h_trans = 2'b10;
            WRITE0_WRAP: begin
                            if(state == IDLE)
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            WRITE1_BURST: begin
                            if((state == IDLE) || ((wr_burst_count == 3'b111) && HREADY))
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            WRITE1_NONSEQ: h_trans = 2'b10;
            WRITE1_WRAP: begin
                            if(state == IDLE)
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            WRITE2_BURST: begin
                            if((state == IDLE) || ((wr_burst_count == 3'b111) && HREADY))
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            WRITE2_NONSEQ: h_trans = 2'b10;
            WRITE2_WRAP: begin
                            if(state == IDLE)
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            READ: h_trans = 2'b00;
            READ_BURST: begin
                            if((state == READ) || ((rd_burst_count == 3'b111) && HREADY))
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            READ_NONSEQ: h_trans = 2'b10;
            READ_WRAP:  begin
                            if(state == READ)
                                h_trans = 2'b10;
                            else
                                h_trans = 2'b11;
            end

            default: h_trans = 2'b00;
        endcase
    end
    end


// hburst
    reg [2:0] h_burst;

    always@(*) begin
        case(next_state) 
            WRITE0_BURST:  h_burst = 3'b101;
            WRITE0_NONSEQ: h_burst = 3'b000;
            WRITE0_WRAP:  begin
                            if(aw_awlen[0] == 'd3)
                                h_burst = 3'b010;
                            else if(aw_awlen[0] == 'd7)
                                h_burst = 3'b100;
                            else if(aw_awlen[0] == 'd15)
                                h_burst = 3'b110;
            end
            WRITE1_BURST:   h_burst = 3'b101;
            WRITE1_NONSEQ:  h_burst = 3'b000;
            WRITE1_WRAP:    begin
                              if(aw_awlen[0] == 'd3)
                                  h_burst = 3'b010;
                              else if(aw_awlen[0] == 'd7)
                                  h_burst = 3'b100;
                              else if(aw_awlen[0] == 'd15)
                                  h_burst = 3'b110;
            end
            WRITE2_BURST:    h_burst = 3'b101;
            WRITE2_NONSEQ:   h_burst = 3'b000;
            WRITE2_WRAP:     begin
                              if(aw_awlen[0] == 'd3)
                                  h_burst = 3'b010;
                              else if(aw_awlen[0] == 'd7)
                                  h_burst = 3'b100;
                              else if(aw_awlen[0] == 'd15)
                                  h_burst = 3'b110;
            end
            READ_BURST:     h_burst = 3'b101;
            READ_NONSEQ:    h_burst = 3'b000;
            READ_WRAP:      begin
                              if(rd_len == 'd3)
                                  h_burst = 3'b010;
                              else if(rd_len == 'd7)
                                  h_burst = 3'b100;
                              else if(rd_len == 'd15)
                                  h_burst = 3'b110;
            end
            default:      h_burst = 3'b000;
        endcase
    end


// hsize
    reg [2:0] h_size;

    always @(*) begin
        case(next_state) 
            WRITE0_BURST:  h_size = aw_size[0];
            WRITE0_NONSEQ: h_size = aw_size[0];
            WRITE0_WRAP:   h_size = aw_size[0];

            WRITE1_BURST:   h_size = aw_size[1];
            WRITE1_NONSEQ:  h_size = aw_size[1];
            WRITE1_WRAP:    h_size = aw_size[1];

            WRITE2_BURST:   h_size = aw_size[2];
            WRITE2_NONSEQ:  h_size = aw_size[2];
            WRITE2_WRAP:    h_size = aw_size[2];

            READ_BURST:     h_size = fifo_pop_arsize;
            READ_NONSEQ:    h_size = fifo_pop_arsize;
            READ_WRAP:      h_size = fifo_pop_arsize;
            default:        h_size = 3'b000;
        endcase
    end

    reg h_write;
    always @(*) begin
        case(next_state) 
            WRITE0_BURST:  h_write = 1'b1;
            WRITE0_NONSEQ: h_write = 1'b1;
            WRITE0_WRAP:   h_write = 1'b1;

            WRITE1_BURST:   h_write = 1'b1;
            WRITE1_NONSEQ:  h_write = 1'b1;
            WRITE1_WRAP:    h_write = 1'b1;

            WRITE2_BURST:   h_write = 1'b1;
            WRITE2_NONSEQ:  h_write = 1'b1;
            WRITE2_WRAP:    h_write = 1'b1;

            READ_BURST:     h_write = 1'b0;
            READ_NONSEQ:    h_write = 1'b0;
            READ_WRAP:      h_write = 1'b0;
            default:        h_write = 1'b0;
        endcase
    end

    assign HADDR = h_addr;
    assign HBURST = h_burst;
    assign HSIZE = h_size;
    assign HTRANS =h_trans;
    assign HWRITE = h_write;

    assign ar_fifo_pop_ready = ((state == READ_BURST) && (rd_burst_count == 3'b111) && HREADY &&  (rd_len == 'd0)) ||
                               ((state == READ_NONSEQ) && (rd_len == 'd0) && HREADY) ||
                               ((state == READ_WRAP) && (rd_wrap_count == 'd0) && HREADY);
   

    





 

    



    

        

            







    

                            


    







                

















        









    











endmodule