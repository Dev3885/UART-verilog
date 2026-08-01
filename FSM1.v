////////controller for device 1/////////

module fsm1 #(parameter Ii = 8)
(input wire [Ii-1:0] DATA, input wire clk, RECIEVING, Trans_clear, Reci_clear, RegEnable, StartLD, output wire [Ii-1:0] DISPLAY, output wire FLAG_state, SENDING);
wire [Ii-1:0] line; wire ResetT;
wire T_trigger;
// the ports that are not in use, leave them blank; those used connect them to something.
/////Transmitter Line/////
counter DU0T (.clk(clk),.EN(RegEnable),.sent(ResetT),.clear(Trans_clear),.count(),.countingdone(T_trigger));    
register DUT (.enable(RegEnable),.Data(DATA),.Q(line));
shiftregisterPISO DU1T(.data(line),.load(StartLD),.countingdone(T_trigger),.clear(Trans_clear),.clk(clk),
.q(SENDING),.parity(),.bitcount(),.start(),.stop(),.transmission(ResetT));
/////RCIEVER LINE/////
wire [Ii-1:0] store; wire Ctrigger, spike;
Rcounter RD (.clk(clk),.clear(Reci_clear),.CStart(Ctrigger),.rcount(),.count_pos(),.sample(spike),.tick());
shiftregisterSIPO RD1 (.clk(clk),.Rin(RECIEVING),.clear(Reci_clear),.shift(spike),.idal(Ctrigger),.Rout(store),.recieved(),.flag(FLAG_state),.rbitcount());
Rregister RD2 (.En(RegEnable),.D(store),.out(DISPLAY));
endmodule


////////controller for device 2////////

module fsm2 #(parameter Ii = 8)
(input wire [Ii-1:0] DATA1, input wire clk, RECIEVING1, Trans_clear1, Reci_clear1, RegEnable1, StartLD1, output wire [Ii-1:0] DISPLAY1, output wire FLAG_state1, SENDING1);
wire [Ii-1:0] line1; wire ResetT1;
wire T_trigger1;
/////Transmitter Line/////
counter2 DU0T (.clk(clk),.EN(RegEnable1),.sent(ResetT1),.clear(Trans_clear1),.count(),.countingdone(T_trigger1));    
register2 DUT (.enable(RegEnable1),.Data(DATA1),.Q(line1));
shiftregisterPISO2 DU1T(.data(line1),.load(StartLD1),.countingdone(T_trigger1),.clear(Trans_clear1),.clk(clk),
.q(SENDING1),.parity(),.bitcount(),.start(),.stop(),.transmission(ResetT1));
/////RCIEVER LINE/////
wire [Ii-1:0] store1; wire Ctrigger1, spike1;
Rcounter2 RD (.clk(clk),.clear(Reci_clear1),.CStart(Ctrigger1),.rcount(),.count_pos(),.sample(spike1),.tick());
shiftregisterSIPO2 RD1 (.clk(clk),.Rin(RECIEVING1),.clear(Reci_clear1),.shift(spike1),.idal(Ctrigger1),.Rout(store1),.recieved(),.flag(FLAG_state1),.rbitcount());
Rregister2 RD2 (.En(RegEnable1),.D(store1),.out(DISPLAY1));
endmodule
