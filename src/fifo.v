module sync_fifo #(parameter size = 8, data_width=8)
(
    input wr_en, clk, rst, rd_en,
    input [data_width -1 : 0]  data_in,
    output [data_width -1 : 0]  data_out,
    output full, empty
);

// Criando memória e ponteiros
reg [data_width - 1 : 0] fifo[0 : size-1];
reg [$clog2(size) : 0] wr_ptr;
reg [$clog2(size) : 0] rd_ptr;

// Wires auxiliares para indexar a memória (sem o bit extra de MSB)
wire [$clog2(size)-1 : 0] wr_addr;
wire [$clog2(size)-1 : 0] rd_addr;

// Atribuindo apenas a parte baixa dos ponteiros aos endereços
assign wr_addr = wr_ptr[$clog2(size)-1 : 0];
assign rd_addr = rd_ptr[$clog2(size)-1 : 0];

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
    end else begin
        if (wr_en & !full) begin
            fifo[wr_addr] <= data_in;
            wr_ptr <= wr_ptr+1;
        end
        if (rd_en & !empty) begin
            rd_ptr <= rd_ptr+1;
        end
    end
 end
    
// O dado apontado por rd_ptr fica sempre disponível na saída   
    assign data_out = fifo[rd_addr];
// Vazio: Todos os bits (incluindo o MSB extra) são exatamente iguais
    assign empty = (wr_ptr == rd_ptr);

// Cheio: O MSB (bit extra) é diferente, mas o resto do endereço é igual
    assign full  = (wr_ptr[$clog2(size)] != rd_ptr[$clog2(size)]) && 
                   (wr_ptr[$clog2(size)-1 : 0] == rd_ptr[$clog2(size)-1 : 0]);

endmodule