

//这里支持的从机写交织最高深度为3，如果要增加写交织深度，应该把id表的深度增加为需要的数量
//即使这里的从机不支持写交织，也是可以的，可以事先进行预设的
//如果从机不支持写交织，或者写交织深度低于3，此时即使设置写交织的深度为3也是可以执行功能的，因为从机自己会根据所支持的写
//交织深度来反馈ready信号进行地址信号的握手

module write_address_log_table  # (
   // parameter s_outstanding_cout = 3,
    parameter interve_mode = 1
)
    (

    input [11:0]  s_axi_arbiter_awaddr,
    input [7:0]   s_axi_arbiter_awlen,
    input [2:0]   s_axi_arbiter_awsize,
    input [1:0]   s_axi_arbiter_awburst,
    input [5:0]   s_axi_arbiter_awid,
    input         s_axi_arbiter_valid,
    output        s_axi_arbiter_ready,



    output [11:0] m_axi_arbiter_awaddr,
    output [7:0]  m_axi_arbiter_awlen,
    output [2:0]  m_axi_arbiter_awsize,
    output [1:0]  m_axi_arbiter_awburst,
    output [5:0]  m_axi_arbiter_awid,
    output        m_axi_arbiter_valid,
    input         m_axi_arbiter_ready,
// 由write_data_arbiter提供，与连接至从机的写数据通道相同
    input         m_axi_w_wlast,
    input  [5:0]  m_axi_w_wid,
    input         m_axi_w_ready,
    input         m_axi_w_valid,

// 提供给write_data_arbiter
    output  [5:0] s_validid0,
    output  [5:0] s_validid1,
    output  [5:0] s_validid2,
    output  [2:0] s_valid,
    output  [7:0] s_wlen0,
    output  [7:0] s_wlen1,
    output  [7:0] s_wlen2


);
    


    assign m_axi_arbiter_awaddr = s_axi_arbiter_awaddr;
    assign m_axi_arbiter_awlen  = s_axi_arbiter_awlen;
    assign m_axi_arbiter_awsize = s_axi_arbiter_awsize;
    assign m_axi_arbiter_awburst = s_axi_arbiter_awburst;
    assign m_axi_arbiter_awid = s_axi_arbiter_awid;
    assign m_axi_arbiter_valid = s_axi_arbiter_valid;
    assign s_axi_arbiter_ready = m_axi_arbiter_ready;


    wire [13:0] fifo_push_payload;
    assign fifo_push_payload = {m_axi_arbiter_awlen,m_axi_arbiter_awid};
    wire fifo_push_valid;
    assign fifo_push_valid = s_axi_arbiter_valid && m_axi_arbiter_ready;
    wire fifo_push_ready;

    wire [13:0] fifo_pop_payload;
    wire fifo_pop_ready;    
    wire fifo_pop_valid;

    streamfifo #(.WIDTH(6),
                 .DEPTH(8))
         idfifo(
            .clk(clk),
            .rst_n(rst_n),
            .push_payload(fifo_push_payload),
            .push_ready(fifo_push_ready),
            .push_valid(fifo_push_valid),
            .pop_payload(fifo_pop_payload),
            .pop_ready(fifo_pop_ready),
            .pop_valid(fifo_pop_valid)
         );

    
    reg [5:0] wid [2:0];
    reg  [2:0] active;
    reg  [2:0] valid;
    reg  [7:0] wlen[2:0];
    integer i;


    always @(posedge clk or negedge rst_n ) begin
        if(!rst_n) begin
            valid  <= 3'd0;
            for(i = 0; i<3;i=i+1) begin
                wid[i] <= 6'd0;
            end
        end
        else begin
            if(fifo_pop_valid && fifo_pop_ready) begin
            casez(valid) 
                3'b??0: begin
                        valid[0] <= 1'b1;
                        wid[0]   <= fifo_pop_payload[5:0];
                        wlen[0]  <= fifo_pop_payload[13:6];
                end
                3'b?01: begin
                        valid[1] <= 1'b1;
                        wid[1]   <= fifo_pop_payload[5:0];
                        wlen[1]  <= fifo_pop_payload[13:6];
                end
                3'b011: begin
                        valid[2] <= 1'b1;
                        wid[2]   <= fifo_pop_payload[5:0];
                        wlen[2]  <= fifo_pop_payload[13:6];
                end
            endcase  
        
            end
            if(m_axi_w_wlast) begin
                if((valid[0] == 1'b1) && (m_axi_w_wid == wid[0]))
                    valid[0] <= 1'b0;
                else if ((valid[1] == 1'b1) && (m_axi_w_wid == wid[1]))
                    valid[1] <= 1'b0;
                else if ((valid[2] == 1'b1) && (m_axi_w_wid ==  wid[2]))
                    valid[2] <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            active <= 3'd0;
        end
        else if(interve_mode == 1) begin
                if(m_axi_w_valid && m_axi_w_ready) begin
                    if((valid[0] == 1'b1) && (m_axi_w_wid == wid[0]))
                        active[0] <= 1'b1;
                    else if ((valid[1] == 1'b1) && (m_axi_w_wid == wid[1]))
                        active[1] <= 1'b1;
                    else if ((valid[2] == 1'b1) && (m_axi_w_wid ==  wid[2]))
                        active[2] <= 1'b1;
                end
                if(m_axi_w_wlast) begin
                    if((valid[0] == 1'b1) && (m_axi_w_wid == wid[0]))
                        active[0] <= 1'b0;
                    else if ((valid[1] == 1'b1) && (m_axi_w_wid == wid[1]))
                        active[1] <= 1'b0;
                    else if ((valid[2] == 1'b1) && (m_axi_w_wid ==  wid[2]))
                        active[2] <= 1'b0;
                end
        end     
        else
            active <= 3'd0;
    end


    wire log_empty = !(&valid);
    wire log_sameid_en =!((valid[0] && (fifo_pop_payload == wid[0])) || (valid[1] && (fifo_pop_payload == wid[1])) || (valid[2] && (fifo_pop_payload == wid[2])));
    wire log_difid_en = !((valid[0] && (fifo_pop_payload != wid[0]) && (active[0] == 1'b0)) || 
                        (valid[1] && (fifo_pop_payload != wid[1]) && (active[1] == 1'b0)) || 
                        (valid[2] && (fifo_pop_payload != wid[2] )&& (active[2] == 1'b0)));
    
    assign fifo_pop_ready = log_empty && log_sameid_en && log_difid_en;

    assign s_validid0 = wid[0];
    assign s_validid1 = wid[1];
    assign s_validid2 = wid[2];

    assign s_valid    = valid;
    assign s_wlen0    = wlen[0];
    assign s_wlen1    = wlen[1];
    assign s_wlen2    = wlen[2];


    
    


















endmodule