// 输入的写返回是从机给的写返回，以及由于invalid生成的写返回，并非合并完的写返回

module write_address_decoder(
    input   clk,
    input   rst_n,


    input  [1:0] s_axi_index, // 主机的序号
    input  [13:0] s_axi_aw_addr,
    input  [7:0]  s_axi_aw_awlen,
    input  [2:0]  s_axi_aw_awsize,
    input  [1:0]  s_axi_aw_awburst,
    input  [3:0]  s_axi_aw_awid,
    input   s_axi_aw_valid,
    output  s_axi_aw_ready,


    output  [13:0] m_axi_aw_addr,
    output  [7:0] m_axi_aw_awlen,
    output  [2:0] m_axi_aw_awsize,
    output  [1:0] m_axi_aw_awburst,
    output  [5:0] m_axi_aw_awid,
    output  m_axi_aw_valid,
    input   m_axi_aw_ready,

// 未合并的写返回，write_response中的b通道fifo提供
    input   [3:0] s_axi_fifo_b_bid,
    input         s_axi_fifo_b_valid,
    input         s_axi_fifo_b_bresp, 
    input         s_axi_fifo_b_ready,

// 合并的写返回
    input    s_axi_b_valid,
    input    s_axi_b_ready,

//连接至 write_response
    output   [3:0] w_transactionid0,
    output   [3:0] w_transactionid1,
    output   [3:0] w_transactionid2,
    output   [2:0] item_valid,

    output   [2:0] fkflag



);

    localparam  IDLE = 3'b001 ;
    localparam  Cross4K = 3'b010;
    localparam  Secondsend = 3'b100;


    reg [2:0] state,next_state;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    wire Fkflag;
    reg [7:0] len_remain;
    

// 计算边界条件剩余地址
    reg [11:0] addr_remain;
    always @(*) begin
        case(s_axi_aw_awsize)
            2'b000: addr_remain = 13'h1000 - s_axi_aw_addr[11:0];
            2'b001: addr_remain = s_axi_aw_addr[0] ? (((13'h1000 - s_axi_aw_addr[11:0]) >> 1) + 1) : ((13'h1000 - s_axi_aw_addr[11:0]) >> 1);
            2'b010: addr_remain = (s_axi_aw_addr[1:0] == 2'b00) ? ((13'h1000 - s_axi_aw_addr[11:0]) >> 2) : ( ((13'h1000 - s_axi_aw_addr[11:0]) >> 2) + 1);
            default : addr_remain = addr_remain;
        endcase
    end

    assign Fkflag = (s_axi_aw_awlen > addr_remain);
    //assign len_remain = s_axi_aw_awlen - addr_remain;
    
    

// 状态机4K边界判断且写入fifo中
    reg [13:0] fifo_push_payload_addr;
    reg [7:0]  fifo_push_payload_awlen;
    reg [2:0]  fifo_push_payload_awsize;
    reg [1:0]  fifo_push_payload_awburst;
    reg [5:0]  fifo_push_payload_awid;
    reg        fifo_push_payload_flag; //指示是否为拆分业务

    
    wire [33:0] fifo_push_payload;
    assign fifo_push_payload = {fifo_push_payload_flag,fifo_push_payload_addr,fifo_push_payload_awlen,fifo_push_payload_awsize,fifo_push_payload_awburst,fifo_push_payload_awid};
    

    wire fifo_push_valid;
    wire fifo_push_ready;

    assign fifo_push_valid = (state == Cross4K) || (state == Secondsend);
   


    always @(*) begin
        case(state) 
            IDLE : next_state = s_axi_aw_valid && s_axi_aw_ready ? Cross4K : IDLE;
            Cross4K: next_state = Fkflag ? Secondsend : IDLE ;
            Secondsend: next_state =  IDLE ;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
            fifo_push_payload_addr <= 13'd0;
            fifo_push_payload_awlen <= 8'd0;
            fifo_push_payload_awsize <= 3'd0;
            fifo_push_payload_awburst <= 2'd0;
            fifo_push_payload_awid <= 4'd0;
            len_remain <= 8'b0;
            fifo_push_payload_flag <= 1'b0;
        end
        else
            case(next_state)
                Cross4K: begin
                         len_remain <= s_axi_aw_awlen - addr_remain;   
                         fifo_push_payload_addr <= s_axi_aw_addr;
                         fifo_push_payload_awlen <= Fkflag? addr_remain - 1: s_axi_aw_awlen;
                         fifo_push_payload_awsize <= s_axi_aw_awsize;
                         fifo_push_payload_awburst <= s_axi_aw_awburst;
                         fifo_push_payload_awid <= {s_axi_index,s_axi_aw_awid};
                         fifo_push_payload_flag <= Fkflag;
                end
                Secondsend: begin
                         fifo_push_payload_addr <= {s_axi_aw_addr[13:12]+1'b1, 12'd0};
                         fifo_push_payload_awlen <= len_remain;
                         len_remain <= len_remain;
                         fifo_push_payload_awsize <= fifo_push_payload_awsize;
                         fifo_push_payload_awburst <= fifo_push_payload_awburst;
                         fifo_push_payload_awid <= fifo_push_payload_awid;
                         fifo_push_payload_flag <= 1'b0;
                end
                default: begin
                        fifo_push_payload_addr <= fifo_push_payload_addr;
                        fifo_push_payload_awlen <= fifo_push_payload_awlen;
                        fifo_push_payload_awsize <= fifo_push_payload_awsize;
                        fifo_push_payload_awburst <= fifo_push_payload_awburst;
                        fifo_push_payload_awid <= fifo_push_payload_awid;
                        len_remain <= len_remain;
                        fifo_push_payload_flag <= fifo_push_payload_flag;
                end
            endcase
    end
    
    reg [2:0] outstandingCount;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            outstandingCount <= 3'd0;
        else begin
            if((state == Cross4K))
                outstandingCount <=  outstandingCount + 1;
            if(s_axi_b_valid && s_axi_b_ready)
                outstandingCount <=  outstandingCount - 1;
        end
    end

     assign s_axi_aw_ready = (outstandingCount < 3);



    wire [33:0] fifo_pop_payload;
    wire fifo_pop_ready;
    wire fifo_pop_valid;

    streamfifo #(.WIDTH(34),
                 .DEPTH(8))
         addrfifo(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo_push_ready),
            .push_valid(fifo_push_valid),
            .pop_payload(fifo_pop_payload),
            .pop_ready(fifo_pop_ready),
            .pop_valid(fifo_pop_valid)
         );


    // 这部分是实现，拆分事务中第一个无访问权限返回DECERR，那么我直接把拆分事务的的第二个抹除掉
    reg fifo_next_tra_match;
    wire fk_match;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_next_tra_match <= 1'b0;
        end
        else
            fifo_next_tra_match <= (fifo_pop_payload[3:0] == s_axi_fifo_b_bid) &&(s_axi_fifo_b_bresp == 2'b11) && fk_match;
    end






    wire transaction_en;

    assign fifo_pop_ready = fifo_pop_valid && m_axi_aw_ready&&transaction_en;
    assign m_axi_aw_valid = fifo_pop_valid && transaction_en && (!fifo_next_tra_match);

    assign m_axi_aw_addr = fifo_pop_payload[32:19];
    assign m_axi_aw_awlen = fifo_pop_payload[18:11];
    assign m_axi_aw_awsize = fifo_pop_payload[10:8];
    assign m_axi_aw_awburst = fifo_pop_payload[7:6];
    assign m_axi_aw_awid = fifo_pop_payload[5:0];



    
// itemtbale ，记录凑fifo中已经发送的事务
    tableitem  titem(
    .clk                (clk),
    .rst_n              (rst_n),
    .slave_id           (fifo_pop_payload[32:31]),
    .transaction_id     (fifo_pop_payload[3:0]),
    .Fkflag             (fifo_pop_payload[33]),
    .item_valid         (),
    .item_fire          (m_axi_aw_valid && m_axi_aw_ready),
    .bid_fire           (s_axi_fifo_b_valid && s_axi_fifo_b_ready),
    .bid                (s_axi_fifo_b_bid),
    .transaction_en     (transaction_en),
    .FK_match           (fk_match),
    .w_transactionid0   (w_transactionid0),
    .w_transactionid1   (w_transactionid1),
    .w_transactionid2   (w_transactionid2),
    .fkflag             (fkflag)
    
);




    











endmodule