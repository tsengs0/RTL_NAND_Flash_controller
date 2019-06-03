module program_nand #(parameter PACKET_LENGTH = 1024)(

	start_program,

	RnB_n,
	clock,
	reset, 
	cmd_reg_host,
	data_bus_n,
	cmd_cnt,
	packet_count,
	counter_add,
	cmd_prgm,
                                    cmd_prgm_2,
                                    cmd_rd_st,
                                    cmd_write,
                                    add_latch,
                                    add_write_en,
                                    prgm_data_latch,
                                    prgm_data_en
);


input [7:0]cmd_reg_host; // the command reg that stores the data coming from the host

input RnB_n;
input clock;
input reset, start_program;
output reg cmd_prgm, cmd_prgm_2, cmd_rd_st,  cmd_write, add_latch, add_write_en,  prgm_data_latch,
                                    prgm_data_en;
output [15:0] data_bus_n;
input [1:0] cmd_cnt;
input [2:0] counter_add;
input [9:0] packet_count;

parameter IDLE = 4'b0000,
		  CMD_PRGM = 4'b0001,
		  CMD_PRGM_2 = 4'b0010,
		  CMD_RD_ST = 4'b0011,
		  CMD_WRITE = 4'b0100,
		  ADD_CYCLE = 4'b0101,
		  ADD_WRITE = 4'b0110,
		  PRGM_CYCLE = 4'b0111,
		  PRGM_WRITE = 4'b1000,
		  waitRB0 = 4'b1001,
		  waitRB1 = 4'b1010;
		 

reg [3:0] cstate, nstate;

reg [15:0] data_bus_n;

always@(posedge clock)
	begin	
		if(reset)	
			cstate <= IDLE;
			
		
		else
			cstate <= nstate;
	end
	
	
	//output and next state logic
always@(*)
	begin
			
			case(cstate)
				IDLE : begin
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								data_bus_n[7:0] <= 8'hzz;

						//default signal values
						if(start_program)
							begin
								if(cmd_reg_host[7:4] == 4'h8)
									nstate <= CMD_PRGM;
								else if(cmd_reg_host[7:4] == 4'h7)
									nstate <= CMD_RD_ST;
							end
						else 
								nstate <= IDLE;
						
						
					end

				CMD_PRGM : begin
								cmd_prgm <= 1'b1;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								nstate <= CMD_WRITE;	
								data_bus_n[7:0] <= 8'h80;
					
							end
							
				CMD_PRGM_2 : begin
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b1;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								nstate <= CMD_WRITE;					
								data_bus_n[7:0] <= 8'h10;
								end
				CMD_RD_ST : begin
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b1;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								nstate <= CMD_WRITE;
								data_bus_n[7:0] <= 8'h70;
								
					
							end
							
				CMD_WRITE : begin
							
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b1;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								//data_bus_n <= 8'hzz;
								if(cmd_cnt >= 2'b01 && RnB_n == 1'b0)
								
										nstate <= waitRB0;
								else if (cmd_cnt >= 2'b11)
										nstate <= IDLE;
										
								else 
										nstate <= ADD_CYCLE;
										
							end
							
				ADD_CYCLE : begin
							//make write enable high again
							cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b1;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								//data_bus_n <= 8'hzz;


									nstate <= ADD_WRITE;
							
						
							end 
				ADD_WRITE : begin
							cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b1;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
							//	data_bus_n <= 8'hzz;
						
							if (counter_add >= 3'b100)
								nstate <= PRGM_CYCLE;
							else 
								nstate <= ADD_CYCLE;
							end
							
				PRGM_CYCLE : begin
							cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b1;
								prgm_data_en <= 1'b0;
							//make write enable high again
								//data_bus_n <= 8'hzz;
 
									nstate <= PRGM_CYCLE;
							end 
				PRGM_WRITE : begin
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b1;
								//data_bus_n <= 8'hzz;
								
								if(packet_count >= PACKET_LENGTH)
										nstate <= CMD_PRGM_2;
								else 
										nstate <= PRGM_CYCLE;
							end
							
				waitRB0 : begin
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								data_bus_n[7:0] <= 8'hzz;
								
								if(RnB_n == 1'b1)
									nstate <= waitRB1;
								else 
									nstate <= waitRB0;
						end
						
				waitRB1 : begin
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								data_bus_n[7:0] <= 8'hzz;
								nstate <= CMD_RD_ST;
						end 
				default : begin
							
								cmd_prgm <= 1'b0;
								cmd_prgm_2 <= 1'b0;
								cmd_rd_st <= 1'b0;
								cmd_write <= 1'b0;
								add_latch <= 1'b0;
								add_write_en <= 1'b0;
								prgm_data_latch <= 1'b0;
								prgm_data_en <= 1'b0;
								data_bus_n[7:0] <= 8'hzz;
								nstate <=IDLE;
						end
		endcase
	end
	

		
endmodule					
								
							
								
			
						
							
							

			
						
							
					
							
		
