`timescale 1ns / 1ps
module testbench #(parameter Ii = 8);
reg [Ii-1:0] DATA; reg Trans_clear, Reci_clear, RegEnable, StartLD, clk; wire [Ii-1:0] DISPLAY; wire FLAG_state;
reg [Ii-1:0] DATA1; reg Trans_clear1, Reci_clear1, RegEnable1, StartLD1; wire [Ii-1:0] DISPLAY1; wire FLAG_state1;
wire LINE, LINE1;
fsm1 DUT (.DATA(DATA),.clk(clk),.RECIEVING(LINE1),.Trans_clear(Trans_clear),.Reci_clear(Reci_clear),.RegEnable(RegEnable),.StartLD(StartLD),
.DISPLAY(DISPLAY),.FLAG_state(FLAG_state),.SENDING(LINE));
fsm2 DUT1 (.DATA1(DATA1),.clk(clk),.RECIEVING1(LINE),.Trans_clear1(Trans_clear1),.Reci_clear1(Reci_clear1),.RegEnable1(RegEnable1),.StartLD1(StartLD1),
.DISPLAY1(DISPLAY1),.FLAG_state1(FLAG_state1),.SENDING1(LINE1));

always #10 clk = ~clk; //flip the clk every 10 unit time = 20ns is a pulse width for 50MHz: 1/50000000 ns

reg [7:0] error;
reg expected;
//block for checking transmission from device 1 and recieving by device 2. 
task audit;
begin 
    expected = (DATA == DISPLAY1);
    if (!expected || FLAG_state1) begin
        $display ("%-15t %-18s 8'b%-11b 8'b%-13b 8'b%-13b %-13b [ **FAILED** ]", $time, "Dev 1 -> Dev 2", DATA, DATA, DISPLAY1, FLAG_state1);
        error = error + 1;
    end else begin
        $display ("%-15t %-18s 8'b%-11b 8'b%-13b 8'b%-13b %-13b [   PASSED   ]", $time, "Dev 1 -> Dev 2", DATA, DATA, DISPLAY1, FLAG_state1);
    end
end
endtask

reg expected1;
//block for checking transmission from device 2 and recieving by device 1.
task audit1;
begin 
    expected1 = (DATA1 == DISPLAY);
    if (!expected1 || FLAG_state) begin
        $display ("%-15t %-18s 8'b%-11b 8'b%-13b 8'b%-13b %-13b [ **FAILED** ]", $time, "Dev 2 -> Dev 1", DATA1, DATA1, DISPLAY, FLAG_state);
        error = error + 1;
    end else begin
        $display ("%-15t %-18s 8'b%-11b 8'b%-13b 8'b%-13b %-13b [   PASSED   ]", $time, "Dev 2 -> Dev 1", DATA1, DATA1, DISPLAY, FLAG_state);
    end
end
endtask

//test cases
initial begin   ////without initialising the system got confused and stuck, never crossed the 20ns, never completed a full bit period eithr
    clk = 0;
    error = 0;
    $dumpfile ("UART.vcd");
    $dumpvars (0, testbench);
    Trans_clear = 1; Reci_clear = 1; //clear everything
    Trans_clear1 = 1; Reci_clear1 = 1; //clear everything
    DATA = 8'b0; RegEnable = 0; StartLD = 0; //hard reset
    DATA1 = 8'b0; RegEnable1 = 0; StartLD1 = 0; //hard reset
    //for table making. 
    $display("\n===============================================================================================");
    $display("                                 UART BI-DIRECTIONAL TESTBENCH                                 ");
    $display("===============================================================================================");
    $display("%-15s %-18s %-13s %-15s %-15s %-13s %-15s", "Time (ns)", "Direction", "Sent (TX)", "Expected", "Received (RX)", "Parity Flag", "Status");
    $display("-----------------------------------------------------------------------------------------------");
    //$monitor ("| %-8t | %-10b | %-10b | %-6b | %-10b | %-10b | %-6b |", $time, DATA, DISPLAY1, FLAG_state1, DATA1, DISPLAY, FLAG_state);  ---> makes the consol messy
    //waiting 40ns after hard reset for settling
    #40 
    Trans_clear = 0; Reci_clear = 0; //withdraw, else everything will be cleared again and again
    Trans_clear1 = 0; Reci_clear1 = 0; //withdraw, else everything will be cleared again and again
    RegEnable = 1; RegEnable1 = 1;  //starting the register
    #20 
    DATA = 8'b10101000; StartLD = 1'b1;
    #20 
    StartLD = 1'b0; //back to 0, or else the register will countiuously feed data to the shift register
    #1150000 
    audit; 
    
    DATA = 8'b11111001; StartLD = 1'b1;
    #20 
    StartLD = 1'b0; //back to 0, or else the register will countiuously feed data to the shift register
    #1150000 
    audit; 
    
    DATA1 = 8'b10101000; StartLD1 = 1'b1;
    #20 
    StartLD1 = 1'b0; //back to 0, or else the register will countiuously loading data from the shift register
    #1150000 
    audit1; 
    
    DATA1 = 8'b11111001; StartLD1 = 1'b1;
    #20 
    StartLD1 = 1'b0; //back to 0, or else the register will countiuously loading data from the shift register
    #1150000 
    audit1;

    $display("===============================================================================================");
    if (error == 0) begin
        $display("[STATUS] Simulation completed with 0 errors. All UART frames matched!");
    end else begin
        $display("[STATUS] Simulation finished with %0d error(s). Check failed rows above.", error);
    end
    $display("===============================================================================================\n");
    #20 $finish;
end
endmodule
