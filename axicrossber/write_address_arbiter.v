


//从机接受三个主机的访问，需要进行仲裁，采用轮询仲裁


module write_address_arbiter (
    input clk,
    input rst_n,

    input [11:0] aw_decoder_awaddr_s0,
    input [7:0]  aw_decoder_awlen_s0,
    input [2:0]  aw_decoder_awsize_s0,
    input [1:0]  aw_decoder_awburst_s0,
    input [5:0]  aw_decoder_awid_s0,
    input        aw_decoder_valid_s0,
    output       aw_decoder_ready_s0,

    input [11:0] aw_decoder_awaddr_s1,
    input [7:0]  aw_decoder_awlen_s1,
    input [2:0]  aw_decoder_awsize_s1,
    input [1:0]  aw_decoder_awburst_s1,
    input [5:0]  aw_decoder_awid_s1,
    input        aw_decoder_valid_s1,
    output       aw_decoder_ready_s1,

    input [11:0]  aw_decoder_awaddr_s2,
    input [7:0]   aw_decoder_awlen_s2,
    input [2:0]   aw_decoder_awsize_s2,
    input [1:0]   aw_decoder_awburst_s2,
    input [5:0]   aw_decoder_awid_s2,
    input         aw_decoder_valid_s2,
    output        aw_decoder_ready_s2,

    output [11:0] m_axi_arbiter_awaddr,
    output [7:0]  m_axi_arbiter_awlen,
    output [2:0]  m_axi_arbiter_awsize,
    output [1:0]  m_axi_arbiter_awburst,
    output [5:0]  m_axi_arbiter_awid,
    output        m_axi_arbiter_valid,
    input         m_axi_arbiter_ready
       

);



    reg [11:0] aw_arbiter_awaddr_m;
    reg [7:0]  aw_arbiter_awlen_m;
    reg [2:0]  aw_arbiter_awsize_m;
    reg [1:0]  aw_arbiter_awburst_m;
    reg [5:0]  aw_arbiter_awid_m;

    // reg [11:0] aw_arbiter_awaddr_m1;
    // reg [7:0]  aw_arbiter_awlen_m1;
    // reg [2:0]  aw_arbiter_awsize_m1;
    // reg [1:0]  aw_arbiter_awburst_m1;
    // reg [5:0]  aw_arbiter_awid_m1;

    // reg [11:0] aw_arbiter_awaddr_m2;
    // reg [7:0]  aw_arbiter_awlen_m2;
    // reg [2:0]  aw_arbiter_awsize_m2;
    // reg [1:0]  aw_arbiter_awburst_m2;
    // reg [5:0]  aw_arbiter_awid_m2;





    wire [2:0] req;
    wire [2:0] grant;

    assign req = {aw_decoder_valid_s2,aw_decoder_valid_s1,aw_decoder_valid_s0};

    reg [2:0] priority;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            priority <= 3'd1;
        else if((|req) && m_axi_arbiter_ready)
            priority <= {grant[1:0],grant[2]};
        else
            priority <= priority;
    end

    // always@(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         aw_arbiter_awaddr_m   <='d0;
    //         aw_arbiter_awlen_m    <='d0;
    //         aw_arbiter_awsize_m   <='d0;
    //         aw_arbiter_awburst_m  <='d0;
    //         aw_arbiter_awid_m     <='d0;
    //     end 
    //     else begin
    always @(*) begin
            case(grant)
                3'b001: begin
                        aw_arbiter_awaddr_m   =    aw_decoder_awaddr_s0; 
                        aw_arbiter_awlen_m    =    aw_decoder_awlen_s0; 
                        aw_arbiter_awsize_m   =    aw_decoder_awsize_s0; 
                        aw_arbiter_awburst_m  =    aw_decoder_awburst_s0;
                        aw_arbiter_awid_m     =    aw_decoder_awid_s0;
                end
                3'b010: begin
                        aw_arbiter_awaddr_m   =    aw_decoder_awaddr_s1; 
                        aw_arbiter_awlen_m    =    aw_decoder_awlen_s1; 
                        aw_arbiter_awsize_m   =    aw_decoder_awsize_s1; 
                        aw_arbiter_awburst_m  =    aw_decoder_awburst_s1;
                        aw_arbiter_awid_m     =    aw_decoder_awid_s1;  
                end
                3'b100: begin
                        aw_arbiter_awaddr_m   =    aw_decoder_awaddr_s2; 
                        aw_arbiter_awlen_m    =    aw_decoder_awlen_s2; 
                        aw_arbiter_awsize_m   =    aw_decoder_awsize_s2; 
                        aw_arbiter_awburst_m  =    aw_decoder_awburst_s2;
                        aw_arbiter_awid_m     =    aw_decoder_awid_s2;  
                end
            endcase
        end



    wire [5:0] double_req = {req,req};

    wire [5:0] double_grant = double_req & ~(double_req - priority);

    reg lock;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            lock <= 1'b0;
        else if((|req) && !m_axi_arbiter_ready)
            lock <= 1'b1;
        else if(m_axi_arbiter_ready)
            lock <= 1'b0;
    end

    assign grant = lock ? grant :double_grant[5:3] | double_grant[2:0];

    assign m_axi_arbiter_valid = |grant;



    assign aw_decoder_ready_s0 = (grant[0]&& m_axi_arbiter_ready);
    assign aw_decoder_ready_s1 = (grant[1]&& m_axi_arbiter_ready);
    assign aw_decoder_ready_s2 = (grant[2]&& m_axi_arbiter_ready);
    assign m_axi_arbiter_awaddr = lock? m_axi_arbiter_awaddr : aw_arbiter_awaddr_m;
    assign m_axi_arbiter_awlen  = lock? m_axi_arbiter_awlen  : aw_arbiter_awlen_m;
    assign m_axi_arbiter_awsize = lock? m_axi_arbiter_awsize : aw_arbiter_awsize_m;
    assign m_axi_arbiter_awburst = lock? m_axi_arbiter_awburst: aw_arbiter_awburst_m;
    assign m_axi_arbiter_awid    = lock? m_axi_arbiter_awid : aw_arbiter_awid_m;




    






endmodule