

// outstanding =3
module tableitem (
    input          clk,
    input          rst_n,
    input  [1:0]   slave_id,
    input  [3:0]   transaction_id,
    input          Fkflag,
    output reg [2:0]   item_valid,
    input          item_fire,
    input          bid_fire,
    input  [1:0]   bresp,
    input  [3:0]   bid,
    output         transaction_en,
    output         FK_match,
    output   [3:0] w_transactionid0,
    output   [3:0] w_transactionid1,
    output   [3:0] w_transactionid2,

    output   [2:0] fkflag

);



    reg [1:0] slaveid[2:0];
    reg [3:0] transactionid[2:0];
    reg [2:0] fkflag_reg;

    assign w_transactionid0 = transactionid[0];
    assign w_transactionid1 = transactionid[1];
    assign w_transactionid2 = transactionid[2];
    assign fkflag = fkflag_reg;
    



    integer  i;



    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            item_valid <= 3'b0;
            fkflag_reg     <= 3'b0;
            for( i = 0 ; i < 3; i=i+1)  begin
                slaveid[i] <= 2'b0;
                transactionid[i] <= 4'b0;
            end
        end
        else  begin
        if(item_fire) begin
            casez(item_valid) 
                3'b??0: begin
                        item_valid[0] <= 1'b1;
                        slaveid[0] <= slave_id;
                        transactionid[0] <= transaction_id;
                        fkflag_reg[0]     <= Fkflag;
                end
                3'b?01: begin
                        item_valid[1] <= 1'b1;
                        slaveid[1] <= slave_id;
                        transactionid[1] <= transaction_id;
                        fkflag_reg[1]     <= Fkflag;
                end
                3'b011: begin
                        item_valid[2] <= 1'b1;
                        slaveid[2] <= slave_id;
                        transactionid[2] <= transaction_id;
                        fkflag_reg[2]     <= Fkflag;
                end
            endcase            
    end
        if(bid_fire) begin
            if((item_valid[0] == 1'b1) && (bid == transactionid[0]))
                item_valid[0] <= 1'b0;
            else if ((item_valid[1] == 1'b1) && (bid == transactionid[1]))
                item_valid[1] <= 1'b0;
            else if ((item_valid[2] == 1'b1) && (bid ==  transactionid[2]))
                item_valid[2] <= 1'b0;
        end

    end
    end

    // wire  FK_decerr_match;
    assign FK_match = (bid_fire) && (((item_valid[0] == 1'b1) && (bid == transactionid[0]) && fkflag_reg[0]) || ((item_valid[1] == 1'b1) && (bid == transactionid[1]) && fkflag_reg[1])  || ((item_valid[2] == 1'b1) && (bid ==  transactionid[2]) && fkflag_reg[2]));

    wire item_empty;
    assign item_empty = !(&item_valid);

    wire  item_en;
    assign item_en = !((item_valid[0] &&  (transaction_id == transactionid[0]) && slave_id != slaveid[0]) ||
                     (item_valid[1] &&  (transaction_id == transactionid[1]) && slave_id != slaveid[1]) ||
                     (item_valid[2] &&  (transaction_id == transactionid[2]) && slave_id != slaveid[2]));

    assign transaction_en = item_empty && item_en;





endmodule