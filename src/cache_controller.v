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
parameter S_IDLE = 3'b000,
          S_CHECK = 3'b001,
          S_HIT_READ = 3'b010,
          S_HIT_WRITE = 3'b011,
          S_FIND_VIC = 3'b100,
          S_WB = 3'b101,
          S_ALLOC = 3'b110,
          S_DONE = 3'b111;

reg [2:0] state, next_state;


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
reg wE0, wE1;       // 控制哪一路要寫入
reg [31:0] data_write_in;
reg [27:0] tag_write_in;
reg v_write_in;
reg dirty_write_in;
wire victim_way; // 來自 LRU，用來決定淘汰哪個 way
wire victim_dirty = (victim_way == 1'b0) ? dirty_way0 : dirty_way1;
wire [31:0] victim_data = (victim_way == 1'b0) ? data_way0 : data_way1;
wire [27:0] victim_tag = (victim_way == 1'b0) ? tag_way0 : tag_way1;


always @(*) begin
    next_state = state;
    case (state)
        S_IDLE:
            if (rEn || wEn)
                next_state = S_CHECK;
        S_CHECK:
            if (hit_all)
                next_state = (rEn ? S_HIT_READ : S_HIT_WRITE);
            else
                next_state = S_FIND_VIC;
        S_HIT_READ:  next_state = S_DONE;
        S_HIT_WRITE: next_state = S_DONE;
        S_FIND_VIC:  next_state = (victim_dirty ? S_WB : S_ALLOC);
        S_WB:        if (mem_ready) next_state = S_ALLOC;
        S_ALLOC:     if (mem_ready) next_state = S_DONE;
        S_DONE:      next_state = S_IDLE;
        default:     next_state = S_IDLE;
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        read_memry   <= 0;
        update_en    <= 0;
        wE0          <= 0;
        wE1          <= 0;
        v_write_in   <= 0;
        dirty_write_in <= 0;
    end else begin
        case (state)
            S_HIT_READ: begin
                read_memry <= hit1 ? data_way1 : data_way0;
                update_en <= 1;
            end

            S_HIT_WRITE: begin
                update_en <= 1;
                v_write_in <= 1;
                dirty_write_in <= 1;
                tag_write_in <= tag_memory;
                data_write_in <= data;  // or from external wdata port
                wE0 <= hit0;
                wE1 <= hit1;
            end
            S_FIND_VIC:begin
               
            end
            S_WB: begin
                write_memory <= victim_data;
                update       <= {victim_tag, index, 2'b00}; // 寫回記憶體地址
            end
            
            S_ALLOC: begin
                tag_write_in     <= tag_memory;
                data_write_in    <= refill;
                v_write_in       <= 1;
                dirty_write_in   <= 0;
                wE0 <= (victim_way == 0);
                wE1 <= (victim_way == 1);
            end 
            default: begin
                update_en       <= 0;
                v_write_in      <= 0;
                dirty_write_in  <= 0;
                wE0             <= 0;
                wE1             <= 0;
                tag_write_in    <= 0;
                data_write_in   <= 0;
            end
        endcase
    end
end



endmodule
