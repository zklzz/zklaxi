// flush 之后考虑直接刷新FIFO吗，还是等产生的写返回之后在刷新
// 给这个模块的写返回应该与输出给主机的写返回是一致的，如果是拆分事务，输入的是拆分事务写返回合并之后的b通道
module write_data_fifo_lut(
    input   clk,
    input   rst_n,


    input  [ 1:0] s_axi_index, // 主机的序号
    input  [ 3:0] s_axi_w_wid,
    input  [31:0] s_axi_w_wdata,
    input         s_axi_w_wlast,
    input  [ 3:0] s_axi_w_wstrb,
    input         s_axi_w_valid,
    output        s_axi_w_ready,

    output  [ 5:0] m_axi_fifo0_w_wid,
    output  [31:0] m_axi_fifo0_w_wdata,
    output         m_axi_fifo0_w_wlast,
    output  [ 3:0] m_axi_fifo0_w_wstrb,
    output         m_axi_fifo0_w_valid,
    input          m_axi_fifo0_w_ready,

    output  [ 5:0] m_axi_fifo1_w_wid,
    output  [31:0] m_axi_fifo1_w_wdata,
    output         m_axi_fifo1_w_wlast,
    output  [ 3:0] m_axi_fifo1_w_wstrb,
    output         m_axi_fifo1_w_valid,
    input          m_axi_fifo1_w_ready,

    output  [ 5:0] m_axi_fifo2_w_wid,
    output  [31:0] m_axi_fifo2_w_wdata,
    output         m_axi_fifo2_w_wlast,
    output  [ 3:0] m_axi_fifo2_w_wstrb,
    output         m_axi_fifo2_w_valid,
    input          m_axi_fifo2_w_ready,

// write_address_arbiter提供 invalidtabel
    input  [ 5:0]  m_transaction_invalidid0,
    input  [ 5:0]  m_transaction_invalidid1,
    input  [ 5:0]  m_transaction_invalidid2,
    input  [ 2:0]  m_invalid,

// 最终合并的写返回，与连接回主机的B通道相同
    input  [ 3:0]  s_axi_b_bid,
    input          s_axi_b_valid,
    input          s_axi_b_ready,

// 提供至write_response
    output         invalidfifo_flush,
    output [ 3:0]  invalidfifo_wid,

    output [ 1:0]  IDgrant0,
    output [ 1:0]  IDgrant1,
    output [ 1:0]  IDgrant2
         
);


// fifo 记录表，将乱序交织的主机输入写数据按id写入不同的fifo中
    reg [2:0]  valid;
    reg [3:0] wid[2:0];
    reg [2:0]  Done;
    reg [1:0] IDgrant[2:0];
    integer  i;

    assign IDgrant0 = IDgrant[0];
    assign IDgrant1 = IDgrant[1];
    assign IDgrant2 = IDgrant[2];


    wire fifo0_flush;
    wire fifo1_flush;
    wire fifo2_flush;
    
    assign fifo0_flush = (((wid[0] == m_transaction_invalidid0) && m_invalid[0]) || ((wid[0] == m_transaction_invalidid1) && m_invalid[1]) || ((wid[0] == m_transaction_invalidid2) && m_invalid[2])) && valid[0] && Done[0];
    assign fifo1_flush = (((wid[1] == m_transaction_invalidid0) && m_invalid[0]) || ((wid[1] == m_transaction_invalidid1) && m_invalid[1]) || ((wid[1] == m_transaction_invalidid2) && m_invalid[2])) && valid[1] && Done[1];
    assign fifo2_flush = (((wid[2] == m_transaction_invalidid0) && m_invalid[0]) || ((wid[2] == m_transaction_invalidid1) && m_invalid[1]) || ((wid[2] == m_transaction_invalidid2) && m_invalid[2])) && valid[2] && Done[2];

    assign invalidfifo_flush = fifo0_flush || fifo1_flush || fifo2_flush;

    
    assign invalidfifo_wid = fifo0_flush ? wid[0] : (fifo1_flush ? wid[1] : (fifo2_flush ? wid[2] : invalidfifo_wid));


    wire [36:0] fifo0_pop_payload;
    wire fifo0_pop_ready;
    wire fifo0_pop_valid;

    wire [36:0] fifo1_pop_payload;
    wire fifo1_pop_ready;
    wire fifo1_pop_valid;

    wire [36:0] fifo2_pop_payload;
    wire fifo2_pop_ready;
    wire fifo2_pop_valid;



    wire table0match = (valid[0] == 1) && (wid[0] == s_axi_w_wid) && (Done[0] == 0);
    wire table1match = (valid[1] == 1) && (wid[1] == s_axi_w_wid) && (Done[1] == 0);
    wire table2match = (valid[2] == 1) && (wid[2] == s_axi_w_wid) && (Done[2] == 0);
    
    wire table0bmatch = (valid[0] == 1) && (wid[0] == s_axi_b_bid) && (IDgrant[0] == 0) && (!fifo0_pop_valid);
    wire table1bmatch = (valid[1] == 1) && (wid[1] == s_axi_b_bid) && (IDgrant[1] == 0) && (!fifo0_pop_valid);
    wire table2bmatch = (valid[2] == 1) && (wid[2] == s_axi_b_bid) && (IDgrant[2] == 0) && (!fifo0_pop_valid);


    
    

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid <= 3'd0;
            for( i = 0 ; i < 3; i=i+1)  begin
                wid[i] <= 4'b0;
            end
        end
        else  begin
        if(s_axi_w_valid && s_axi_w_ready ) begin
            casez(valid) 
                3'b??0: begin
                        if((!table1match) && (!table2match)) begin
                            valid[0] <= 1'b1;
                            wid[0] <= s_axi_w_wid;
                        end
                end
                3'b?01: begin
                        if((!table0match) && (!table2match)) begin
                            valid[1] <= 1'b1;
                            wid[1] <= s_axi_w_wid;
                        end
                end
                3'b011: begin
                        if((!table0match) && (!table1match)) begin
                            valid[2] <= 1'b1;
                            wid[2] <= s_axi_w_wid;
                        end
                end
            endcase            
        end
        if(s_axi_b_valid && s_axi_b_ready) begin
            if(table0bmatch)
                valid[0] <= 1'b0;
            else if (table1bmatch)
                valid[1] <= 1'b0;
            else if (table2bmatch)
                valid[2] <= 1'b0;
        end

        // if(fifo0_flush) 
        //     valid[0] <= 1'b0;
        // if(fifo1_flush)
        //     valid[1] <= 1'b0;
        // if(fifo2_flush)
        //     valid[2] <= 1'b0;
        
        end
    end


//  wlast 之后Done
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            Done <= 3'd0;
        end
        else  begin
        if(s_axi_w_valid && s_axi_w_ready && s_axi_w_wlast) begin
            if(table0match)
                Done[0] <= 1'b1;
            else if(table1match)
                Done[1] <= 1'b1;
            else if(table2match)
                Done[2] <= 1'b1;
        end
        if(s_axi_b_valid && s_axi_b_ready) begin
            if(table0bmatch)
                Done[0] <= 1'b0;
            else if (table1bmatch)
                Done[1] <= 1'b0;
            else if (table2bmatch)
                Done[2] <= 1'b0;
        end 
        // if(fifo0_flush) 
        //     Done[0] <= 1'b0;
        // if(fifo1_flush)
        //     Done[1] <= 1'b0;
        // if(fifo2_flush)
        //     Done[2] <= 1'b0;

        end
    end


    wire IDrepeat0 = (valid[0] == 1) && (wid[0] == s_axi_w_wid) && (Done[0] == 1);
    wire IDrepeat1 = (valid[1] == 1) && (wid[1] == s_axi_w_wid) && (Done[1] == 1);
    wire IDrepeat2 = (valid[2] == 1) && (wid[2] == s_axi_w_wid) && (Done[2] == 1);



// 同一ID 的优先性
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for( i = 0 ; i < 3; i=i+1)  begin
                IDgrant[i] <= 2'd0;
            end 
        end
        else begin
             casez(valid) 
                3'b??0: begin
                        if(IDrepeat1 && IDrepeat2) 
                            IDgrant[0] <= 2'd2;
                        else if (IDrepeat1 || IDrepeat2)
                            IDgrant[0] <= 2'd1;
                end
                3'b?01: begin
                        if(IDrepeat0 && IDrepeat2) 
                            IDgrant[1] <= 2'd2;
                        else if (IDrepeat0 || IDrepeat2)
                            IDgrant[1] <= 2'd1;
                end
                3'b011: begin
                        if(IDrepeat0 && IDrepeat1) 
                            IDgrant[2] <= 2'd2;
                        else if (IDrepeat0 || IDrepeat1)
                            IDgrant[2] <= 2'd1;
                end
            endcase            
            if(s_axi_b_valid && s_axi_b_ready) begin
                if((valid[0] == 1) && (wid[0] == s_axi_b_bid))
                    IDgrant[0] <= (IDgrant[0] > 0) ? IDgrant[0] - 1 : IDgrant[0];
                else if ((valid[1] == 1) && (wid[1] == s_axi_b_bid))
                    IDgrant[1] <= (IDgrant[1] > 0) ? IDgrant[1] - 1 : IDgrant[1];
                else if ((valid[2] == 1) && (wid[2] == s_axi_b_bid))
                    IDgrant[2] <= (IDgrant[2] > 0) ? IDgrant[2] - 1 : IDgrant[2];
        end 
        end
    end

    reg data_fire_reg;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            data_fire_reg <= 1'b0;
        else if (s_axi_w_valid && s_axi_w_ready) 
            data_fire_reg <= 1'b1;
    end



    reg [31:0] fifo_push_payload_wdata;
    reg        fifo_push_payload_last ;
    reg [3:0]  fifo_push_payload_wstrb;


    
    wire [36:0] fifo_push_payload;
    assign fifo_push_payload = {fifo_push_payload_wstrb,fifo_push_payload_last,fifo_push_payload_wdata};
    

    reg fifo0_push_valid;
    wire fifo0_push_ready;
    reg fifo1_push_valid;
    wire fifo1_push_ready;
    reg fifo2_push_valid;
    wire fifo2_push_ready;   

    wire tableen = !(&valid);

    assign s_axi_w_ready = table0match || table1match || table2match || tableen;



    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fifo0_push_valid <= 1'b0;
        else if((s_axi_w_valid && s_axi_w_ready) && ((valid[0] == 1'b0 &&((!table1match) && (!table2match))) || table0match))
            fifo0_push_valid <= 1'b1;
        else
            fifo0_push_valid <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fifo1_push_valid <= 1'b0;
        else if((s_axi_w_valid && s_axi_w_ready) && ((valid[1] == 1'b0 &&((!table0match) && (!table2match))) || table1match))
            fifo1_push_valid <= 1'b1;
        else
            fifo1_push_valid <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            fifo2_push_valid <= 1'b0;
        else if((s_axi_w_valid && s_axi_w_ready) && ((valid[2] == 1'b0 &&((!table0match) && (!table1match))) || table2match))
            fifo2_push_valid <= 1'b1;
        else
            fifo2_push_valid <= 1'b0;
    end





    

    


    always@(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin
            fifo_push_payload_wdata <= 32'd0;
            fifo_push_payload_last  <= 1'b0;
            fifo_push_payload_wstrb <= 4'd0;
        end
        else if (s_axi_w_valid && s_axi_w_ready) begin
            fifo_push_payload_wdata <= s_axi_w_wdata;
            fifo_push_payload_last  <= s_axi_w_wlast;
            fifo_push_payload_wstrb <= s_axi_w_wstrb;  
        end
    end

    
    


    

    streamfifo #(.WIDTH(37),
                 .DEPTH(8))
         addrfifo0(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo0_push_ready),
            .push_valid(fifo0_push_valid),
            .pop_payload(fifo0_pop_payload),
            .pop_ready(fifo0_pop_ready),
            .pop_valid(fifo0_pop_valid),
            .flush(fifo0_flush)
         );



    streamfifo #(.WIDTH(37),
                 .DEPTH(8))
         addrfifo1(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo1_push_ready),
            .push_valid(fifo1_push_valid),
            .pop_payload(fifo1_pop_payload),
            .pop_ready(fifo1_pop_ready),
            .pop_valid(fifo1_pop_valid),
            .flush(fifo1_flush)
         );



    streamfifo #(.WIDTH(37),
                 .DEPTH(8))
         addrfifo2(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo2_push_ready),
            .push_valid(fifo2_push_valid),
            .pop_payload(fifo2_pop_payload),
            .pop_ready(fifo2_pop_ready),
            .pop_valid(fifo2_pop_valid),
            .flush(fifo2_flush)
         );


    assign m_axi_fifo0_w_wid    =  {s_axi_index, wid[0]};
    assign m_axi_fifo0_w_wdata  =  fifo0_pop_payload[31:0];
    assign m_axi_fifo0_w_wlast  =  fifo0_pop_payload[32];
    assign m_axi_fifo0_w_wstrb  =  fifo0_pop_payload[36:33];
    assign m_axi_fifo0_w_valid  =  fifo0_pop_valid;


    assign m_axi_fifo1_w_wid    =  {s_axi_index, wid[1]};
    assign m_axi_fifo1_w_wdata  =  fifo1_pop_payload[31:0];
    assign m_axi_fifo1_w_wlast  =  fifo1_pop_payload[32];
    assign m_axi_fifo1_w_wstrb  =  fifo1_pop_payload[36:33];
    assign m_axi_fifo1_w_valid  =  fifo1_pop_valid;


    assign m_axi_fifo2_w_wid    =  {s_axi_index, wid[2]};
    assign m_axi_fifo2_w_wdata  =  fifo2_pop_payload[31:0];
    assign m_axi_fifo2_w_wlast  =  fifo2_pop_payload[32];
    assign m_axi_fifo2_w_wstrb  =  fifo2_pop_payload[36:33];
    assign m_axi_fifo2_w_valid  =  fifo2_pop_valid;


    













endmodule