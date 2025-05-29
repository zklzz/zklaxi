
// 主机侧，三个从机的写返回连接至arbiter，仲裁结果输入到fifo中进行缓冲
// 对拆分事务的写返回进行合并
module write_response(
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


    input   [1:0] s_axi_index,
    output  [3:0] s_axi_b_bid,
    output  [1:0] s_axi_b_bresp,
    output        s_axi_b_valid,
    input         s_axi_b_ready,

// write_data_fifo_lut 提供 
    input         s_axi_w_fifo_flush,
    input   [3:0] s_axi_w_fifo_wid,


//write_address_decoder提供
    input   [3:0] w_transactionid0,
    input   [3:0] w_transactionid1,
    input   [3:0] w_transactionid2,
    input   [2:0] item_valid,

    input   [2:0] fkflag,

    
// 连接write_address_decoder,未合并的写返回
    output         fifo_pop_valid,
    output  [1:0]  fifo_pop_bresp,
    output  [3:0]  fifo_pop_bid,
    output         fifo_pop_ready,
// write_address_arbiter
    output         s_axi_invalid_fire,
    output         s_axi_invalid_wid
      




);


 // arbiter   
    wire [ 3:0]  req;
    wire [ 3:0]  grant;
    



    


    assign req = {s_axi_w_fifo_flush,(m2_axi_b_valid && (m2_axi_b_bid[5:4] == s_axi_index)),(m1_axi_b_valid && (m1_axi_b_bid[5:4] == s_axi_index)) ,(m0_axi_b_valid && (m0_axi_b_bid[5:4] == s_axi_index))};

    reg [3:0] priority;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            priority <= 3'd1;
        else if((|req) && s_axi_b_ready)
            priority <= {grant[1:0],grant[2]};
        else
            priority <= priority;
    end

    reg  [ 3:0] s_axi_arbitr_b_bid;
    reg  [ 1:0] s_axi_arbitr_b_bresp;



    always @(*) begin
        case(grant) 
            4'b0001: begin
                s_axi_arbitr_b_bid   = m0_axi_b_bid;
                s_axi_arbitr_b_bresp = m0_axi_b_bresp;
            end
            4'b0010: begin
                s_axi_arbitr_b_bid   = m1_axi_b_bid;
                s_axi_arbitr_b_bresp = m1_axi_b_bresp;
            end
            4'b0100: begin
                s_axi_arbitr_b_bid   = m2_axi_b_bid;
                s_axi_arbitr_b_bresp = m2_axi_b_bresp;
            end
            4'b1000: begin
                s_axi_arbitr_b_bid   = s_axi_w_fifo_wid;
                s_axi_arbitr_b_bresp = 2'b11;
            end
        endcase
    end

    wire [7:0] double_req = {req,req};

    wire [7:0] double_grant = double_req & ~(double_req - priority);

    wire fifo_push_ready;
    reg lock;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            lock <= 1'b0;
        else if((|req) && !fifo_push_ready)
            lock <= 1'b1;
        else if(fifo_push_ready)
            lock <= 1'b0;
    end
    assign grant = lock ? grant :double_grant[7:4] | double_grant[3:0];

    wire [3:0]  fifo_push_payload_bid;
    wire [1:0]  fifo_push_payload_bresp;

    assign fifo_push_payload_bid = lock? fifo_push_payload_bid : s_axi_arbitr_b_bid;
    assign fifo_push_payload_bresp = lock? fifo_push_payload_bresp : s_axi_arbitr_b_bresp;



// streamfifo 合并拆分事务的写返回
    wire [5:0] fifo_push_payload;

    assign fifo_push_payload = {fifo_push_payload_bid,fifo_push_payload_bresp};


    wire fifo_push_valid;

    assign fifo_push_valid = |grant;


    wire [5:0] fifo_pop_payload;
    // wire fifo_pop_ready;
    // wire fifo_pop_valid;

    assign m0_axi_b_ready = grant[0] && fifo_push_ready;
    assign m1_axi_b_ready = grant[1] && fifo_push_ready;
    assign m2_axi_b_ready = grant[2] && fifo_push_ready;

    assign s_axi_invalid_fire = grant[3] && fifo_push_ready && s_axi_w_fifo_flush;
    assign s_axi_invalid_wid = s_axi_w_fifo_wid;
 

    streamfifo #(.WIDTH(6),
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
    
    assign fifo_pop_bid = fifo_pop_payload[5:2];
    assign fifo_pop_bresp = fifo_pop_payload[1:0];
    reg [3:0] first_transcation_bid;
    reg [1:0] first_transcation_bresp;
    reg       first_valid;
    reg [3:0] s_axi_bid_reg;
    reg [1:0] s_axi_bresp_reg;
    reg       s_axi_valid_reg;

    wire bid_match0,bid_match1,bid_match2;

    assign bid_match0 = (fifo_pop_payload[5:2] == w_transactionid0) && item_valid[0] && fifo_pop_valid;
    assign bid_match1 = (fifo_pop_payload[5:2] == w_transactionid1) && item_valid[1] && fifo_pop_valid;
    assign bid_match2 = (fifo_pop_payload[5:2] == w_transactionid2) && item_valid[2] && fifo_pop_valid;

    //由于SSPID,拆分事务只能有一个,但是存在三个事务都是同一ID
    wire [2:0] bid_fk= {bid_match0,bid_match1,bid_match2};

    wire bid_fkmatchleast = (bid_match0 && fkflag[0]) || (bid_match1 && fkflag[1]) || (bid_match2 && fkflag[2]);

    wire bid_fk_match = ((bid_fk == 3'b100) || (bid_fk == 3'b010) || (bid_fk == 3'b001)) && bid_fkmatchleast;
    wire bid_match    = (bid_match0 && (!fkflag[0])) || (bid_match1 && (!fkflag[1])) || (bid_match2 && !(fkflag[2]));
    wire bid_invalid  = (fifo_pop_payload[1:0] == 2'b11);
    wire bid_next_match = bid_match && (fifo_pop_payload[5:2] == first_transcation_bid);

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            first_transcation_bid <= 4'd0;
            first_transcation_bresp <= 2'd0;
        end
        else if(bid_fk_match && (!bid_invalid)) begin
            first_transcation_bid <= fifo_pop_payload[5:2];
            first_transcation_bresp <= fifo_pop_payload[1:0];
        end
        else if(bid_next_match) begin
            first_transcation_bid <= 4'd0;
            first_transcation_bresp <= 2'd0;

        end
    end

    // always@(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         first_valid <= 1'b0;
    //     end
    //     else if(bid_fk_match) begin
    //         if(bid_invalid)
    //             first_valid <= 1'b0;
    //         else 
    //             first_valid <= ~first_valid;
    //     end
    // end




// 这里注意对valid和payload进行打拍，用到了register slice 的单valid打拍




    // always@(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         s_axi_bid_reg <= 4'd0;
    //         s_axi_bresp_reg <= 2'd0;
    //     end
    //     else if(((bid_match) || (bid_fk_match && bid_invalid)) && (s_axi_b_ready || (!s_axi_valid_reg))) begin
    //         s_axi_bid_reg <= fifo_pop_payload[5:2];
    //         s_axi_bresp_reg <= fifo_pop_payload[1:0];
    //     end
    //     else if((bid_fk_match && first_valid) && (s_axi_b_ready || (!s_axi_valid_reg))) begin
    //         s_axi_bid_reg <= fifo_pop_payload[5:2];
    //         s_axi_bresp_reg <= fifo_pop_payload[1:0] || first_transcation_bresp;
    //     end
    // end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s_axi_bid_reg <= 4'd0;
            s_axi_bresp_reg <= 2'd0;
        end
        else if(s_axi_b_ready || (!s_axi_valid_reg)) begin
            if(bid_next_match) begin
                s_axi_bid_reg <= fifo_pop_payload[5:2];
                s_axi_bresp_reg <= fifo_pop_payload[1:0] || first_transcation_bresp;
            end
            else if((bid_match) || (bid_fk_match && bid_invalid)) begin
                s_axi_bid_reg <= fifo_pop_payload[5:2];
                s_axi_bresp_reg <= fifo_pop_payload[1:0];
            end
        end
    end


    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s_axi_valid_reg <= 1'b0;
        end
        else if((s_axi_b_ready || (!s_axi_valid_reg))) begin
            s_axi_valid_reg <= ((bid_match) || (bid_fk_match && bid_invalid));
        end
    end




             
    assign fifo_pop_ready =  s_axi_b_ready || (!s_axi_valid_reg) || (bid_fk_match && (!bid_invalid));//增加一项4k边界不返回响应的匹配
    
    assign s_axi_b_bid = s_axi_bid_reg;
    assign s_axi_b_bresp = s_axi_bresp_reg;
    assign s_axi_b_valid = s_axi_valid_reg;
    










endmodule


