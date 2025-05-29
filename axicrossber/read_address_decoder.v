

module read_address_decoder(
    input   clk,
    input   rst_n,


    input  [1:0] s_axi_index, // 主机的序号
    input  [13:0] s_axi_ar_addr,
    input  [7:0]  s_axi_ar_arlen,
    input  [2:0]  s_axi_ar_arsize,
    input  [1:0]  s_axi_ar_arburst,
    input  [3:0]  s_axi_ar_arid,
    input         s_axi_ar_valid,
    output        s_axi_ar_ready,


    output  [13:0] m_axi_ar_addr,
    output  [7:0]  m_axi_ar_arlen,
    output  [2:0]  m_axi_ar_arsize,
    output  [1:0]  m_axi_ar_arburst,
    output  [5:0]  m_axi_ar_arid,
    output         m_axi_ar_valid,
    input          m_axi_ar_ready,

//  需要两个rlast
//  拆分事务的rlast
    input   [3:0] s_axi_fifo_r_rid,
    input         s_axi_fifo_r_rlast,
    input         s_axi_fifo_r_valid, 
    input         s_axi_fifo_r_ready,

// 合并之后的rlast

    input   s_axi_r_valid,
    input   s_axi_r_ready,
    input   s_axi_r_rlast,

//连接至 read_data_arbiter
    output   [3:0] r_transactionid0,
    output   [3:0] r_transactionid1,
    output   [3:0] r_transactionid2,
    output   [2:0] itemvalid,

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
    

// 计算 到达边界之前剩下的地址
    reg [11:0] addr_remain;
    always @(*) begin
        case(s_axi_ar_arsize)
            2'b000: addr_remain = 13'h1000 - s_axi_ar_addr[11:0];
            2'b001: addr_remain = s_axi_ar_addr[0] ? (((13'h1000 - s_axi_ar_addr[11:0]) >> 1) + 1) : ((13'h1000 - s_axi_ar_addr[11:0]) >> 1);
            2'b010: addr_remain = (s_axi_ar_addr[1:0] == 2'b00) ? ((13'h1000 - s_axi_ar_addr[11:0]) >> 2) : ( ((13'h1000 - s_axi_ar_addr[11:0]) >> 2) + 1);
            default : addr_remain = addr_remain;
        endcase
    end

    assign Fkflag = (s_axi_ar_arlen > addr_remain);
    //assign len_remain = s_axi_ar_arlen - addr_remain;
    
    

// 状态机进行4k边界判断，并且写入fifo中
    reg [13:0] fifo_push_payload_addr;
    reg [7:0]  fifo_push_payload_arlen;
    reg [2:0]  fifo_push_payload_arsize;
    reg [1:0]  fifo_push_payload_arburst;
    reg [5:0]  fifo_push_payload_arid;
    reg        fifo_push_payload_flag; //指示是否为拆分业务

    
    wire [33:0] fifo_push_payload;
    assign fifo_push_payload = {fifo_push_payload_flag,fifo_push_payload_addr,fifo_push_payload_arlen,fifo_push_payload_arsize,fifo_push_payload_arburst,fifo_push_payload_arid};
    

    wire fifo_push_valid;
    wire fifo_push_ready;

    assign fifo_push_valid = (state == Cross4K) || (state == Secondsend);
   


    always @(*) begin
        case(state) 
            IDLE : next_state = s_axi_ar_valid && s_axi_ar_ready ? Cross4K : IDLE;
            Cross4K: next_state = Fkflag ? Secondsend : IDLE ;
            Secondsend: next_state =  IDLE ;
        endcase
    end

    always@(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
            fifo_push_payload_addr <= 13'd0;
            fifo_push_payload_arlen <= 8'd0;
            fifo_push_payload_arsize <= 3'd0;
            fifo_push_payload_arburst <= 2'd0;
            fifo_push_payload_arid <= 4'd0;
            len_remain <= 8'b0;
            fifo_push_payload_flag <= 1'b0;
        end
        else
            case(next_state)
                Cross4K: begin
                         len_remain <= s_axi_ar_arlen - addr_remain;   
                         fifo_push_payload_addr <= s_axi_ar_addr;
                         fifo_push_payload_arlen <= Fkflag? addr_remain - 1: s_axi_ar_arlen;
                         fifo_push_payload_arsize <= s_axi_ar_arsize;
                         fifo_push_payload_arburst <= s_axi_ar_arburst;
                         fifo_push_payload_arid <= {s_axi_index,s_axi_ar_arid};
                         fifo_push_payload_flag <= Fkflag;
                end
                Secondsend: begin
                         fifo_push_payload_addr <= {s_axi_ar_addr[13:12]+1'b1, 12'd0};
                         fifo_push_payload_arlen <= len_remain;
                         len_remain <= len_remain;
                         fifo_push_payload_arsize <= fifo_push_payload_arsize;
                         fifo_push_payload_arburst <= fifo_push_payload_arburst;
                         fifo_push_payload_arid <= fifo_push_payload_arid;
                         fifo_push_payload_flag <= 1'b0;
                end
                default: begin
                        fifo_push_payload_addr <= fifo_push_payload_addr;
                        fifo_push_payload_arlen <= fifo_push_payload_arlen;
                        fifo_push_payload_arsize <= fifo_push_payload_arsize;
                        fifo_push_payload_arburst <= fifo_push_payload_arburst;
                        fifo_push_payload_arid <= fifo_push_payload_arid;
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
            if(s_axi_r_valid && s_axi_r_ready && s_axi_r_rlast)
                outstandingCount <=  outstandingCount - 1;
        end
    end

     assign s_axi_ar_ready = (outstandingCount < 3);



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








    wire transaction_en;

    assign fifo_pop_ready = fifo_pop_valid && m_axi_ar_ready && transaction_en;
    assign m_axi_ar_valid = fifo_pop_valid && transaction_en;

    assign m_axi_ar_addr = fifo_pop_payload[32:19];
    assign m_axi_ar_arlen = fifo_pop_payload[18:11];
    assign m_axi_ar_arsize = fifo_pop_payload[10:8];
    assign m_axi_ar_arburst = fifo_pop_payload[7:6];
    assign m_axi_ar_arid = fifo_pop_payload[5:0];

    reg [2:0] item_valid;
    reg [1:0] slaveid[2:0];
    reg [3:0] transactionid[2:0];
    reg [2:0] fkflag_reg;

    assign r_transactionid0 = transactionid[0];
    assign r_transactionid1 = transactionid[1];
    assign r_transactionid2 = transactionid[2];
    assign fkflag = fkflag_reg;
    



    integer  i;

// item table 记录主机送出去的项，这里是拆分事务

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            item_valid <= 3'd0;
            fkflag_reg <= 3'd0;
            for( i = 0 ; i < 3; i=i+1)  begin
                slaveid[i] <= 2'd0;
                transactionid[i] <= 4'd0;
            end
        end
        else  begin
        if(m_axi_ar_valid && m_axi_ar_ready) begin
            casez(item_valid) 
                3'b??0: begin
                        item_valid[0] <= 1'b1;
                        slaveid[0] <= fifo_pop_payload[32:31];
                        transactionid[0] <= fifo_pop_payload[3:0];
                        fkflag_reg[0]     <= fifo_pop_payload[33];
                end
                3'b?01: begin
                        item_valid[1] <= 1'b1;
                        slaveid[1] <= fifo_pop_payload[32:31];
                        transactionid[1] <= fifo_pop_payload[3:0];
                        fkflag_reg[1]     <= fifo_pop_payload[33];
                end
                3'b011: begin
                        item_valid[2] <= 1'b1;
                        slaveid[2] <= fifo_pop_payload[32:31];
                        transactionid[2] <= fifo_pop_payload[3:0];
                        fkflag_reg[2]     <= fifo_pop_payload[33];
                end
            endcase            
    end
        if(s_axi_fifo_r_valid && s_axi_fifo_r_ready && s_axi_fifo_r_rlast) begin
            if((item_valid[0] == 1'b1) && (s_axi_fifo_r_rid == transactionid[0]))
                item_valid[0] <= 1'b0;
            else if ((item_valid[1] == 1'b1) && (s_axi_fifo_r_rid == transactionid[1]))
                item_valid[1] <= 1'b0;
            else if ((item_valid[2] == 1'b1) && (s_axi_fifo_r_rid ==  transactionid[2]))
                item_valid[2] <= 1'b0;
        end

    end
    end

    

    wire item_empty;
    assign item_empty = !(&item_valid);

    wire  item_en;
    assign item_en = !((item_valid[0] &&  (fifo_pop_payload[5:0] == transactionid[0]) && (fifo_pop_payload[32:31] != slaveid[0])) ||
                     (item_valid[1] &&  (fifo_pop_payload[5:0] == transactionid[1]) && (fifo_pop_payload[32:31] != slaveid[1])) ||
                     (item_valid[2] &&  (fifo_pop_payload[5:0] == transactionid[2]) && (fifo_pop_payload[32:31] != slaveid[2])));

    assign transaction_en = item_empty && item_en;


    



endmodule