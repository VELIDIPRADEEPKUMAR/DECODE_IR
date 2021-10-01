
 module IR_test(input IR,cry_clk,
                output [3:0]LED,  
	             output wire  [7:0] dig,
                output wire [3:0] sel   );
 
                reg  [15:0] addr;
					// reg  [7:0]  command;
					 wire [31:0] data;
					 wire        load,rep,clk;
					 wire [15:0] BCD; 
					 wire [6:0] SSD;
					 reg  [3:0] BIN;
					 reg  [9:0] counter;
					 wire [1:0] state;
					 
					
					 supply0 tr,reset;
					 
				assign 	 dig = {1'b1,SSD};
					
			/////////////////////////////////////
			clk clk1(cry_clk,clk);
			DECODE_IR IR1(IR,clk,data,load,rep,state);
			BIN_BCD D(BCD,data[15:8],clk);
			decoder d(sel,counter[9:8]);
			BCD_SSD ssd1(SSD,BIN);
//			BCD_SSD ssd2(SSD[13:7],4'b0010);
//			BCD_SSD ssd3(SSD[20:14],4'b0011);
//			BCD_SSD ssd4(SSD[27:21],4'b0111);
			///////////////////////////////////
			decoder L(LED,state);
			
	 always@(posedge clk) counter <= counter + 1'b1;		
	 
		//	always@(posedge clk) 
		//	begin 
		//	counter <= counter + 1'b1;
		//	if(load) begin
		//	         addr <= data[31:16];
		//				command <= data[15:8];
		//				end
		//	end
			        
////////////////////////////////////////////////////////////////////////			
			always@(*) 
			begin
			
			case(counter[9:8])
			
			   2'b00    :  BIN = BCD[3:0];   
			   2'b01    :  BIN = BCD[7:4];  
				2'b10    :  BIN = BCD[11:8]; 
				2'b11    :  BIN = BCD[15:12]; 
				
		   endcase 
				
				end	
endmodule


/// decoder 
module decoder(output reg [3:0] out,
               input [1:0] in    );
				
			always@(*) 
	         begin
			  
			   case(in)
			
		      2'b00    :  out = 4'b1110;
			   2'b01    :  out = 4'b1101;
				2'b10    :  out = 4'b1011;
				2'b11    :  out = 4'b0111;
		      endcase 
				end
endmodule 
			

/// BCD TO SEVEN SEGMENT DISPLAY 

module BCD_SSD( seg , bcd );
     
     //Declare inputs,outputs and internal variables.
     input [3:0] bcd;
     output reg [6:0] seg;

//always block for converting bcd digit into 7 segment format
    always @(bcd)
    begin
        case (bcd) //case statement
            0 : seg = 7'b1000000;
            1 : seg = 7'b1111001;
            2 : seg = 7'b0100100;
            3 : seg = 7'b0110000;
            4 : seg = 7'b0011001;
            5 : seg = 7'b0010010;
            6 : seg = 7'b0000010;
            7 : seg = 7'b1111000;
            8 : seg = 7'b0000000;
            9 : seg = 7'b0010000;
				
            default : seg = 7'b1111111; 
        endcase
    end
    
endmodule
 
 
 
