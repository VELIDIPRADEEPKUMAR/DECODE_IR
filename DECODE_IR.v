/********************************************************
Auther      :-  velidi pradeep kumar 
date        :-  28/8/2021 
orgnisation :-  IIITDM KANCHIPURAM
description :- This design will decode NEC pulse distance 
               encoded ir signal
**********************************************************/

 module DECODE_IR(input  IR,clk,reset,
                  output reg [31:0] data,		
						output reg load ,rep ,
					   output [1:0] led	);
						
			parameter RESET = 2'b00;
			parameter S_H   = 2'b01;
			parameter D_L   = 2'b10;
			parameter D_H   = 2'b11;
			
			reg [14:0] counter;
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
							       rst = 1'b1;
								    if((counter > 17995)&(counter < 18005)) next_state = S_H;  // 9000ms
								    else   begin  next_state = RESET; load = 1'b1; end
								    end
							else   next_state = RESET;
			            end
			
			S_H       : begin 
			            if(IR) begin 
							       next_state = S_H;
									 if(counter > 9010) begin load = 1'b1; next_state = RESET; end // 4500us
									 end
						   else   begin
						          rst = 1'b1;
									 if((counter > 8995)&(counter < 9005)) next_state = D_L;  // 4500ms
									 else if((counter > 4495)&(counter < 4505)) begin next_state = RESET; rep = 1'b1; end //2250ms
								    else next_state = RESET;
									 end
							end
			
			D_L       : begin 
			            if(IR) begin 
							       rst = 1'b1;
									 if((counter > 1120)&(counter < 1130)) next_state = D_H;    // 562.5us
									 else next_state = RESET;
									 end
							else   next_state = D_L;
							end
			
			D_H       : begin 
			            if(IR) begin 
							       next_state = D_H;
									 if(counter > 34000) begin load = 1'b1; next_state = RESET; end // 1700us
									 end
							else begin
							     rst = 1'b1;
								  if((counter > 1120)&(counter < 1130)) begin L_0 = 1'b1; next_state = D_L; end     // 562.5us
								  else if((counter > 3370)&(counter < 3380))begin L_1 = 1'b1; next_state = D_L; end // 1.6875ms
								  else next_state = RESET;
								  end
							end
		   endcase	
			
			end
			
///////////////////////// data path ///////////////////////////////			
			
			always@(posedge clk)
			begin 
			if(reset) begin 
			          data <= 32'b0;
			          counter <= 15'b0;
			         // state <= 2'b0;
			          end
			else    begin
			if(L_0) data <= {data[30:0],1'b0};
			else if(L_1) data <= {data[30:0],1'b1};
			else data <= data;
			
			if(rst) counter <= 15'b0;
			else counter <= counter + 15'b000_0000_0000_0001;
			       end
			
			end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
						
						
endmodule 