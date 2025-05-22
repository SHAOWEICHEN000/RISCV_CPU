module cache_control(
    input clk,
    input rst,
    input mem_ready,
    input [31:0]address,
    input wEn,
    input rEn,
    output reg [31:0]write_memory,
    output reg [31:0]read_memry,
    output reg [31:0]update,
    input [31:0]refill
);
parameter S_IDLE       = 4'b0000,
          S_CHECK      = 4'b0001,
          S_HIT_READ   = 4'b0010,
          S_HIT_WRITE  = 4'b0011,
          S_FIND_VIC   = 4'b0100,
          S_WB         = 4'b0101,
          S_ALLOC      = 4'b0110,
          S_DONE       = 4'b0111,
          S_PRE_ALLOC  = 4'b1000; 
         

reg [3:0] state, next_state;
reg write_en ;

wire hit0,hit1,hit_all;
wire [27:0]tag_memory;
wire [1:0] set_memory;
wire [1:0]offset_memory;
wire v_way0;
wire v_way1;
wire dirty_way0;
wire dirty_way1;
wire [27:0]tag_way0;
wire [27:0]tag_way1;
wire [31:0]data_way0;
wire [31:0]data_way1;
wire [31:0]data;
hit hit(
    .clk(clk),
    .v_way0(v_way0),
    .v_way1(v_way1),
    .tag_way0(tag_way0),
    .tag_way1(tag_way1),
    .tag_memory(tag_memory),
    .hit0(hit0),
    .hit1(hit1),
    .hit_all(hit_all)
);

address_splitter address_splitter(
    .clk(clk),
    .address(address),
    .tag_memory(tag_memory),
    .set_memory(set_memory),
    .offset_memory(offset_memory)
);

lru lru(
    .clk(clk),
    .rst(rst),
    .index(index),
    .update_en(update_en),
    .hit0(hit0),
    .hit1(hit1),
    .victim_way(victim_way)
);

Data_multiplexer Data_multiplexer(
    .clk(clk),
    .data_way0(data_way0),
    .data_way1(data_way1),
    .hit1(hit1),
    .data(data)
);

cache_array cache_array(
    .clk(clk),
    .rst(rst),
    .write_en(write_en),
    .index(index),
    .victim_way(victim_way),
    .v_write_in(v_write_in),
    .tag_write_in(tag_write_in),
    .data_write_in(data_write_in),
    .dirty_write_in(dirty_write_in),
    .v_way0(v_way0),
    .v_way1(v_way1),
    .dirty_way0(dirty_way0),
    .dirty_way1(dirty_way1),
    .tag_way0(tag_way0),
    .tag_way1(tag_way1),
    .data_way0(data_way0),
    .data_way1(data_way1)
);
wire [1:0] index = set_memory;

reg update_en;     // 控制 LRU 更新
reg [31:0] data_write_in;
reg [27:0] tag_write_in;
reg v_write_in;
reg dirty_write_in;
wire victim_way; // 來自 LRU，用來決定淘汰哪個 way
wire victim_dirty = (victim_way == 1'b0) ? dirty_way0 : dirty_way1;
wire [31:0] victim_data = (victim_way == 1'b0) ? data_way0 : data_way1;
wire [27:0] victim_tag = (victim_way == 1'b0) ? tag_way0 : tag_way1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        read_memry   <= 0;
        update_en    <= 0;
        write_en     <= 0;
        v_write_in   <= 0;
        dirty_write_in <= 0;
        next_state <= S_IDLE; 
        write_memory <= 0;
        read_memry <= 0;
        update <= 0;

    end else begin
        
        case (next_state)
            S_DONE:      next_state <= S_IDLE;
            S_HIT_READ: begin
                read_memry <= hit1 ? data_way1 : data_way0;
                update_en <= 1;
                next_state <= S_DONE;               
            end
            S_CHECK: begin
                if (hit_all)
                    next_state <= (rEn ? S_HIT_READ : S_HIT_WRITE);
                else
                    next_state <= S_FIND_VIC;
            end
            S_IDLE: begin
                if (rEn || wEn)
                    next_state <= S_CHECK;
                    $display("| wEn=%b |rEn=%b |",wEn,rEn);
            end
            S_HIT_WRITE: begin
                next_state <= S_DONE;
                update_en <= 1;
                v_write_in <= 1;
                dirty_write_in <= 1;
                tag_write_in <= tag_memory;
                data_write_in <= data;  // or from external wdata port
              
            end
            S_FIND_VIC:begin
               $display("|find vic, victim_dirty=%h | victim_way=%b | dirty_way0-%b |dirty_way1=%b |",victim_dirty,victim_way,dirty_way0,dirty_way1);
               next_state <= (victim_dirty ? S_WB : S_ALLOC);
            end
            S_WB: begin
                write_memory <= victim_data;
                $display("WB , write_memory=%h",write_memory);
                update       <= {victim_tag, index, 2'b00}; // 寫回記憶體地址
                if (mem_ready) next_state <= S_PRE_ALLOC;
                $display("Victim_way=%b, dirty0=%b, dirty1=%b → victim_dirty=%b", 
                victim_way, dirty_way0, dirty_way1, victim_dirty);

            end
            
            S_ALLOC: begin
                tag_write_in     <= tag_memory;
                data_write_in    <= refill;
                v_write_in       <= 1;
                dirty_write_in   <= 0;
                write_en <= 1;
                if (mem_ready) next_state <= S_DONE;
            end 
            S_PRE_ALLOC: begin 
                next_state <= S_ALLOC;  // 給 victim_way 一個 clock cycle 的穩定時間
            end
            default: begin
                update_en       <= 0;
                v_write_in      <= 0;
                dirty_write_in  <= 0;
                write_en        <= 0;
                tag_write_in    <= 0;
                data_write_in   <= 0;
                next_state <= S_IDLE;
                $display("default");
            end
        endcase
    end
end
endmodule
