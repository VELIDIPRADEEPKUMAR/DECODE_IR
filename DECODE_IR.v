/********************************************************
Auther      :-  velidi pradeep kumar 
date        :-  28/8/2021 
orgnisation :-  IIITDM KANCHIPURAM
description :- This design will decode NEC pulse distance 
               encoded ir signal
**********************************************************/

 module DECODE_IR(input  IR,clk,
                  output reg [31:0] data,		
						output reg load ,rep ,
					   output [1:0] led);
						
			parameter RESET = 2'b00;
			parameter S_H   = 2'b01;
			parameter D_L   = 2'b10;
			parameter D_H   = 2'b11;
			
			reg [13:0] counter;
			reg [1:0]  state,next_state;
			reg rst,L_1,L_0;
			
			assign led = state;
			
			
			always@(posedge clk) state <= next_state;
			
         
//////////////////////////next state /////////////////////////////////
			
			always@(*) begin
			
			rst  = 1'b0;
			L_0  = 1'b0;
			L_1  = 1'b0;
			load = 1'b0;
			rep  = 1'b0;
			
			case(state)
			
			RESET     : begin 
			            if(IR) begin 
							       
								    if((counter > 8000) &(counter < 10000)) begin next_state = S_H; rst = 1'b1;end  // 9000us 
								    else   begin  next_state = RESET; load = 1'b1; rst = 1'b1;end
								    end
							else   next_state = RESET;
			            end
			
			S_H       : begin 
			            if(IR) begin 
							       next_state = S_H;
									 if(counter > 4400) begin load = 1'b1; next_state = RESET; end // 4500us
									 end
						   else   begin
						          
									 if((counter > 4200)&(counter < 4900)) begin next_state = D_L; rst = 1'b1; end  // 4500us
									 else if((counter > 2000)&(counter < 2600)) begin next_state = RESET; rep = 1'b1; rst = 1'b1; end //2250us
								    else begin next_state = RESET; rst = 1'b1; end
									 
									 end
							end
			
			D_L       : begin 
			            if(IR) begin 
							       
									 if((counter > 400)&(counter < 1000)) begin next_state = D_H; rst = 1'b1; end    // 562.5us
									 else begin  next_state = RESET; rst = 1'b1; end
									 
									 end
							else   next_state = D_L;
							end
			
			D_H       : begin 
			            if(IR) begin 
									 if(counter > 5000) begin load = 1'b1; next_state = RESET; end // 5000us
									 else next_state = D_H;
									 end
							else begin
							     
								  if((counter > 400)&(counter < 1100)) begin L_0 = 1'b1; next_state = D_L; rst = 1'b1; end     // 562.5us
								  else if((counter > 1100)&(counter < 2300))begin L_1 = 1'b1; next_state = D_L; rst = 1'b1; end // 1.6875ms
								  else begin next_state = RESET; rst = 1'b1; end
								  
								  end
							end
		   endcase	
			
			end
			
///////////////////////// data path ///////////////////////////////			
			
			always@(posedge clk)
			begin 
			if(rst) counter <= 14'b0;
			else counter <= counter + 14'b000_0000_0000_0001;
			end
			
			always@(posedge (L_0|L_1) ) data <= {data[30:0],!L_0};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
						
						
endmodule 