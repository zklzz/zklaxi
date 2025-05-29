module  APBconfig (
    input clk,
    input rst_n,
    input PSEL,
    input [3:0] PADDR,
    input PENABLE,
    input [7:0] PWDATA,
    input  PWRITE,
    output [7:0] PRDATA,
    output PREADY,
    output PSLVERR,
    output [2:0] region_write_table_m0,
    output [2:0] region_write_table_m1,
    output [2:0] region_write_table_m2,
    output [2:0] region_read_table_m0,
    output [2:0] region_read_table_m1,
    output [2:0] region_read_table_m2
    
    
    );
    wire read_enable;
    wire write_enable;
    wire write_en00,write_en01, write_en02,write_en03,write_en04,write_en05,write_en06,write_en07;

    assign read_enable = (PSEL) && (~PWRITE);
    assign write_enable = (PSEL) && PWRITE;
    assign write_en00 = write_enable && (PADDR == 4'd0);
    assign write_en01 = write_enable && (PADDR == 4'd1);
    assign write_en02 = write_enable && (PADDR == 4'd2);
    assign write_en03 = write_enable && (PADDR == 4'd3);
    assign write_en04 = write_enable && (PADDR == 4'd4);
    assign write_en05 = write_enable && (PADDR == 4'd5);
    assign write_en06 = write_enable && (PADDR == 4'd6);
    assign write_en07 = write_enable && (PADDR == 4'd7);


    reg [2:0] region_wtable_m0,region_wtable_m1,region_wtable_m2,region_rtable_m0,region_rtable_m1,region_rtable_m2;
    reg [2:0] write_error_interrupt,read_error_interrupt;
    reg [2:0] write_error_type;
    reg [2:0] read_error_type;

    assign region_write_table_m0 = region_wtable_m0;
    assign region_write_table_m1 = region_wtable_m1;
    assign region_write_table_m2 = region_wtable_m2;

    assign region_read_table_m0 = region_rtable_m0;
    assign region_read_table_m1 = region_rtable_m1;
    assign region_read_table_m2 = region_rtable_m2;
    



    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            region_wtable_m0 <= 3'd0;
        else if (write_en00)
            region_wtable_m0 <= PWDATA[2:0];
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            region_wtable_m1 <= 3'd0;
        else if (write_en01)
            region_wtable_m1 <= PWDATA[2:0];
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            region_wtable_m2 <= 3'd0;
        else if (write_en02)
            region_wtable_m2 <= PWDATA[2:0];
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            region_rtable_m0 <= 3'd0;
        else if (write_en03)
            region_rtable_m0 <= PWDATA[2:0];
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            region_rtable_m1 <= 3'd0;
        else if (write_en04)
            region_rtable_m1 <= PWDATA[2:0];
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            region_rtable_m2 <= 3'd0;
        else if (write_en05)
            region_rtable_m2 <= PWDATA[2:0];
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            write_error_interrupt <= 3'd0;
        else if (write_en06)
            write_error_interrupt <= PWDATA[2:0];
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            read_error_interrupt <= 3'd0;
        else if (write_en07)
            read_error_interrupt <= PWDATA[2:0];
    end

    reg [7:0] read_mux_byte;



    always@(*) begin
        case (PADDR)
                4'd0: read_mux_byte = {5'd0,region_wtable_m0};
                4'd1: read_mux_byte = {5'd0,region_wtable_m1};
                4'd2: read_mux_byte = {5'd0,region_wtable_m2};
                4'd3: read_mux_byte = {5'd0,region_rtable_m0};
                4'd4: read_mux_byte = {5'd0,region_rtable_m1};
                4'd5: read_mux_byte = {5'd0,region_rtable_m2};
                4'd6: read_mux_byte = {5'd0,write_error_interrupt};
                4'd7: read_mux_byte = {5'd0,read_error_interrupt};
                4'd8: read_mux_byte = {5'd0,write_error_type};
                4'd9: read_mux_byte = {5'd0,read_error_type};
                default: read_mux_byte = 8'd0;
        endcase
    end

    assign PRDATA = (read_enable) ? read_mux_byte : 8'd0;
    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0;









     
















    
endmodule