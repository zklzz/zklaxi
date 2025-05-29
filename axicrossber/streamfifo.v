`timescale 1ns/1ns
/**********************************RAM************************************/
module dual_port_RAM #(parameter DEPTH = 16,
					   parameter WIDTH = 8)(
	 input wclk
	,input wenc
	,input [$clog2(DEPTH)-1:0] waddr  
	,input [WIDTH-1:0] wdata      	
	,input rclk
	,input [$clog2(DEPTH)-1:0] raddr  
	,output reg [WIDTH-1:0] rdata 		
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
	if(wenc)
		RAM_MEM[waddr] <= wdata;
end 

always @(posedge rclk) begin
		rdata <= RAM_MEM[raddr];
end 

endmodule  

/**********************************SFIFO************************************/
module streamfifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					clk		, 
	input 					rst_n	,
    input                   push_valid,
    output                  push_ready,
    input 		[WIDTH-1:0]	push_payload,
    input                   flush,

    output                  pop_valid,
    input                   pop_ready,
    output      [WIDTH-1:0]	pop_payload,

    output      [$clog2(DEPTH) : 0]  wr_num


);
    wire                    wenc;
    reg [$clog2(DEPTH) : 0] waddr;
    reg [$clog2(DEPTH) : 0] raddr;
    reg [$clog2(DEPTH) : 0] waddr_q;
    reg [$clog2(DEPTH) : 0] raddr_q;
    wire    wfull;
    wire    rempty;

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         wfull <= 'd0;
    //         rempty <= 'd0;
    //     end
    //     else begin
    //         wfull <= (waddr[$clog2(DEPTH)] != raddr[$clog2(DEPTH)]) && (waddr[$clog2(DEPTH)-1 : 0] != raddr[$clog2(DEPTH)-1 : 0]);
    //         rempty <= waddr == raddr;
    //     end
    // end
    assign wfull = (waddr_q[$clog2(DEPTH)] != raddr_q[$clog2(DEPTH)]) && (waddr_q[$clog2(DEPTH)-1 : 0] == raddr_q[$clog2(DEPTH)-1 : 0]);
    assign rempty = (waddr_q == raddr_q);


    always @(*) begin
        if(flush)
            waddr = 'd0;
        else if (push_valid && push_ready)
            waddr = waddr_q + 'd1;
        else
            waddr = waddr_q;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            waddr_q <= 'b0;
        else
            waddr_q <= waddr;
    end

    



    assign push_ready = !wfull;


    
    always @(*) begin
       if(flush)
            raddr = 'd0;
        else if (pop_valid && pop_ready)
            raddr = raddr_q + 'd1;
        else 
            raddr = raddr_q;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            raddr_q <= 'b0;
        else
            raddr_q <= raddr;
    end

    assign wr_num = (waddr_q[$clog2(DEPTH)] != raddr_q[$clog2(DEPTH)]) ? ({1'b1,waddr_q[$clog2(DEPTH)-1 :0]} - {1'b0,raddr_q[$clog2(DEPTH)-1 :0]}) : (waddr_q - raddr_q);


    // reg last_data;
    // always @(posedge clk or negedge rst_n) begin
    // if (!rst_n)
    //     last_data <= 1'b0;
    // else
    //     last_data <= (raddr + 1 == waddr); // next read will match write
    // end

    reg  valid_reg;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            valid_reg <= 1'b0;
        else
            valid_reg <= (waddr_q == raddr);
    end

    assign pop_valid = (!rempty) && (!valid_reg);

    //assign pop_valid = !rempty && !(last_data && !push_valid);

    
    
    
    dual_port_RAM #(.DEPTH (DEPTH),
                    .WIDTH (WIDTH))
    dual_port (
        .wclk  (clk  ),
        .wenc  (push_valid && push_ready),
        .waddr (waddr_q[$clog2(DEPTH)-1:0]),
        .wdata (push_payload),
        .rclk  (clk  ),
        .raddr (raddr[$clog2(DEPTH)-1:0]),
        .rdata (pop_payload)
    );

endmodule
