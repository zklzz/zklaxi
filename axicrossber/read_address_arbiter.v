


//从机接受三个主机的访问，需要进行仲裁，采用轮询仲裁


module read_address_arbiter (
    input clk,
    input rst_n,

    input [11:0] ar_decoder_araddr_s0,
    input [7:0]  ar_decoder_arlen_s0,
    input [2:0]  ar_decoder_arsize_s0,
    input [1:0]  ar_decoder_arburst_s0,
    input [5:0]  ar_decoder_arid_s0,
    input        ar_decoder_valid_s0,
    output       ar_decoder_ready_s0,

    input [11:0] ar_decoder_araddr_s1,
    input [7:0]  ar_decoder_arlen_s1,
    input [2:0]  ar_decoder_arsize_s1,
    input [1:0]  ar_decoder_arburst_s1,
    input [5:0]  ar_decoder_arid_s1,
    input        ar_decoder_valid_s1,
    output       ar_decoder_ready_s1,

    input [11:0]  ar_decoder_araddr_s2,
    input [7:0]   ar_decoder_arlen_s2,
    input [2:0]   ar_decoder_arsize_s2,
    input [1:0]   ar_decoder_arburst_s2,
    input [5:0]   ar_decoder_arid_s2,
    input         ar_decoder_valid_s2,
    output        ar_decoder_ready_s2,

    output [11:0] m_axi_arbiter_araddr,
    output [7:0]  m_axi_arbiter_arlen,
    output [2:0]  m_axi_arbiter_arsize,
    output [1:0]  m_axi_arbiter_arburst,
    output [5:0]  m_axi_arbiter_arid,
    output        m_axi_arbiter_valid,
    input         m_axi_arbiter_ready
       

);



    reg [11:0] ar_arbiter_araddr_m;
    reg [7:0]  ar_arbiter_arlen_m;
    reg [2:0]  ar_arbiter_arsize_m;
    reg [1:0]  ar_arbiter_arburst_m;
    reg [5:0]  ar_arbiter_arid_m;

    // reg [11:0] ar_arbiter_araddr_m1;
    // reg [7:0]  ar_arbiter_arlen_m1;
    // reg [2:0]  ar_arbiter_arsize_m1;
    // reg [1:0]  ar_arbiter_arburst_m1;
    // reg [5:0]  ar_arbiter_arid_m1;

    // reg [11:0] ar_arbiter_araddr_m2;
    // reg [7:0]  ar_arbiter_arlen_m2;
    // reg [2:0]  ar_arbiter_arsize_m2;
    // reg [1:0]  ar_arbiter_arburst_m2;
    // reg [5:0]  ar_arbiter_arid_m2;





    wire [2:0] req;
    wire [2:0] grant;

    assign req = {ar_decoder_valid_s2,ar_decoder_valid_s1,ar_decoder_valid_s0};

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
    //         ar_arbiter_araddr_m   <='d0;
    //         ar_arbiter_arlen_m    <='d0;
    //         ar_arbiter_arsize_m   <='d0;
    //         ar_arbiter_arburst_m  <='d0;
    //         ar_arbiter_arid_m     <='d0;
    //     end 
    //     else begin
    always @(*) begin
            case(grant)
                3'b001: begin
                        ar_arbiter_araddr_m   =    ar_decoder_araddr_s0; 
                        ar_arbiter_arlen_m    =    ar_decoder_arlen_s0; 
                        ar_arbiter_arsize_m   =    ar_decoder_arsize_s0; 
                        ar_arbiter_arburst_m  =    ar_decoder_arburst_s0;
                        ar_arbiter_arid_m     =    ar_decoder_arid_s0;
                end
                3'b010: begin
                        ar_arbiter_araddr_m   =    ar_decoder_araddr_s1; 
                        ar_arbiter_arlen_m    =    ar_decoder_arlen_s1; 
                        ar_arbiter_arsize_m   =    ar_decoder_arsize_s1; 
                        ar_arbiter_arburst_m  =    ar_decoder_arburst_s1;
                        ar_arbiter_arid_m     =    ar_decoder_arid_s1;  
                end
                3'b100: begin
                        ar_arbiter_araddr_m   =    ar_decoder_araddr_s2; 
                        ar_arbiter_arlen_m    =    ar_decoder_arlen_s2; 
                        ar_arbiter_arsize_m   =    ar_decoder_arsize_s2; 
                        ar_arbiter_arburst_m  =    ar_decoder_arburst_s2;
                        ar_arbiter_arid_m     =    ar_decoder_arid_s2;  
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



    assign ar_decoder_ready_s0 = (grant[0]&& m_axi_arbiter_ready);
    assign ar_decoder_ready_s1 = (grant[1]&& m_axi_arbiter_ready);
    assign ar_decoder_ready_s2 = (grant[2]&& m_axi_arbiter_ready);
    assign m_axi_arbiter_araddr = lock? m_axi_arbiter_araddr : ar_arbiter_araddr_m;
    assign m_axi_arbiter_arlen  = lock? m_axi_arbiter_arlen  : ar_arbiter_arlen_m;
    assign m_axi_arbiter_arsize = lock? m_axi_arbiter_arsize : ar_arbiter_arsize_m;
    assign m_axi_arbiter_arburst = lock? m_axi_arbiter_arburst: ar_arbiter_arburst_m;
    assign m_axi_arbiter_arid    = lock? m_axi_arbiter_arid : ar_arbiter_arid_m;




    






endmodule