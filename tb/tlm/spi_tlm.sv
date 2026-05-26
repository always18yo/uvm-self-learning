//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//***************************************************************************************************************
class spi_tlm extends uvm_sequence_item;

 `uvm_object_utils(spi_tlm)
 
  //
  // NEW
  //
  rand bit [31:0] addr;     // address
  rand bit [31:0] wdata;    // write data   
  rand bit        wr_rd;    // 1 - write, 0 - read
  rand bit        do_reset; // 1 - reset, 0 - no action 
  rand bit        do_wait;  // 1 - wait a number of clocks specified in the driver, 0 - no action

  function new(string name = "spi_tlm");
    super.new(name);
  endfunction
  
  
endclass
